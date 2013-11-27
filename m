From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Wed, 27 Nov 2013 14:38:27 +0100
Message-ID: <5295F5D3.8020002@linutronix.de>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de> <9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
To: Fugang Duan <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:46198 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab3K0Nib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 08:38:31 -0500
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- <frank.li@freescale.net> because MTA complains

On 11/27/2013 02:08 PM, Fugang Duan wrote:
> In fact, there have one memory copy for enet as below since enet have 16 bytes data buffer alignment request.
> if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
>                 memcpy(fep->tx_bounce[index], skb->data, skb->len);
>                 bufaddr = fep->tx_bounce[index];
> }

This memcpy() is only executed if the buffer isn't properly aligned
which shouldn't be the rule but an exception. This aligment check is
also available in v2.6.31 where the BUG_ON() statement was triggered.

> 
> So, the bug you describe at commit log shouldn't exist.
> 
> Anyway, it is better to use the real packet size for the mapping.
> 
> 
> I will do overnight stress test for the patch tomorrow.

Thanks.

> 
> Thanks,
> Andy
> 

Sebastian
