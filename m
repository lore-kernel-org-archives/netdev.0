From: Fugang Duan <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Thu, 28 Nov 2013 01:18:09 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE0189C105@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
 <9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net>
 <5295F5D3.8020002@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:51570
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754622Ab3K1BSi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 20:18:38 -0500
In-Reply-To: <5295F5D3.8020002@linutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Sent: Wednesday, November 27, 2013 9:38 PM

>To: Duan Fugang-B38611
>Cc: netdev@vger.kernel.org; David S. Miller; Estevam Fabio-R49496; Frank Li;
>Jim Baxter; Marek Szyprowski
>Subject: Re: [PATCH] net: fec_main: dma_map() only the length of the skb
>
>- <frank.li@freescale.net> because MTA complains
>
>On 11/27/2013 02:08 PM, Fugang Duan wrote:
>> In fact, there have one memory copy for enet as below since enet have 16
>bytes data buffer alignment request.
>> if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
>>                 memcpy(fep->tx_bounce[index], skb->data, skb->len);
>>                 bufaddr = fep->tx_bounce[index]; }
>
>This memcpy() is only executed if the buffer isn't properly aligned which
>shouldn't be the rule but an exception. This aligment check is also available
>in v2.6.31 where the BUG_ON() statement was triggered.
>
In fact, the skb->data address is not aligned with FEC_ALIGNMENT, so memcpy() always is called at here.

Thanks,
Andy 
