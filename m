From: Fugang Duan <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Mon, 2 Dec 2013 02:14:17 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE018B5B56@039-SN2MPN1-022.039d.mgd.msft.net>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
 <9848F2DB572E5649BA045B288BE08FBE018B5B1A@039-SN2MPN1-022.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
To: Fugang Duan <fugang.duan@freescale.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:1399
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752341Ab3LBCOV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Dec 2013 21:14:21 -0500
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE018B5B1A@039-SN2MPN1-022.039d.mgd.msft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <fugang.duan@freescale.com>
Data: Monday, December 02, 2013 10:05 AM + 800

>To: Sebastian Andrzej Siewior; netdev@vger.kernel.org
>Cc: David S. Miller; Estevam Fabio-R49496; Frank Li; Jim Baxter; Marek
>Szyprowski
>Subject: RE: [PATCH] net: fec_main: dma_map() only the length of the skb
>
>From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>Data: Wednesday, November 27, 2013 8:44 PM
>
>>To: netdev@vger.kernel.org
>>Cc: David S. Miller; Estevam Fabio-R49496; Frank Li; Duan
>>Fugang-B38611; Jim Baxter; Marek Szyprowski; Sebastian Andrzej Siewior
>>Subject: [PATCH] net: fec_main: dma_map() only the length of the skb
>>
>>On tx submit the driver always dma_map_single() FEC_ENET_TX_FRSIZE
>>(=2048) bytes. This works because we don't overwrite any memory after
>>the data buffer, we remove it from cache if it was there. So we hurt
>>performace in case the mapping of a smaller area makes a difference.
>>There is also a bug: If the data area starts shortly before the end of
>>RAM say
>>0xc7fffa10 and the RAM ends at 0xc8000000 then we have enough space to
>>fit the data area (according to skb->len) but we would map beyond end
>>of ram if we are using 2048. In v2.6.31 (against which kernel this
>>patch
>>made) there is the following check in dma_cache_maint():
>>
>>|BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(start + size - 1));
>>
>>Since the area starting at 0xc8000000 is no longer virt_addr_valid() we
>>BUG() during dma_map_single(). The BUG() statement was removed in
>>v3.5-rc1 as per 2dc6a016 ("ARM: dma-mapping: use asm-generic/dma-mapping-
>common.h").
>>
>>This patch was tested on v2.6.31 and then forward-ported and compile
>>tested only against the net tree. I think it is still worth fixing
>>mainline even after the BUG() statement is gone.
>>
>>Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>>Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>>---
>>
[...]
>It pass weekend stress test, and performance have little change for imx6q
>sabresd platform(cpu frequence is 799MHz, set cpufreq governor to performance):
>The previous tx bandwidth for tcp: 427Mhz After the patch, tx bandwidth for tcp:
>440Mhz.

427Mhz -> 427Mbps
440Mhz -> 440Mbps

>It means dma map memory size can impact networking performance.
>
>
>
>Tested-by: Fugang Duan <B38611@freescale.com>
>
>Thanks,
>Andy
>

Sorry, it is slip of the pen.
