From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Thu, 28 Nov 2013 12:24:26 +0100
Message-ID: <529727EA.5010405@linutronix.de>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de> <9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net> <5295F5D3.8020002@linutronix.de> <9848F2DB572E5649BA045B288BE08FBE0189C105@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
To: Fugang Duan <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56871 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306Ab3K1LYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 06:24:31 -0500
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE0189C105@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2013 02:18 AM, Fugang Duan wrote:
- <frank.li@freescale.net> because MTA complains (now really)

>> On 11/27/2013 02:08 PM, Fugang Duan wrote:
>>> In fact, there have one memory copy for enet as below since enet have 16
>> bytes data buffer alignment request.
>>> if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
>>>                 memcpy(fep->tx_bounce[index], skb->data, skb->len);
>>>                 bufaddr = fep->tx_bounce[index]; }
>>
>> This memcpy() is only executed if the buffer isn't properly aligned which
>> shouldn't be the rule but an exception. This aligment check is also available
>> in v2.6.31 where the BUG_ON() statement was triggered.
>>
> In fact, the skb->data address is not aligned with FEC_ALIGNMENT, so memcpy() always is called at here.

I am aware of NET_IP_ALIGN. The pointers I mentioned in the log were
from a printk() shortly before that bug triggered. So I am not making
this up :) I am not aware of the load that triggered this.

Anyway, adding this

   WARN_ON(!((unsigned long)skb->data & 0xf));

in my e1000 on v3.12 triggers shortly after boot and according to the
backtrace it comes aoe. So that is at least one user :)
Since that aligment is for IP, I am not sure if non-IP based protocol
are using this. I know however that the workload, that triggered the
problem, is not IP-based.

> 
> Thanks,
> Andy 

Sebastian
