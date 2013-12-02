From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec_main: dma_map() only the length of the skb
Date: Mon, 02 Dec 2013 16:59:44 -0500 (EST)
Message-ID: <20131202.165944.24925233570384450.davem@davemloft.net>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
	<9848F2DB572E5649BA045B288BE08FBE018B5B1A@039-SN2MPN1-022.039d.mgd.msft.net>
	<20131202095255.GA13247@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, netdev@vger.kernel.org,
	Fabio.Estevam@freescale.com, frank.li@freescale.net,
	jim_baxter@mentor.com, m.szyprowski@samsung.com
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018Ab3LBV7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 16:59:46 -0500
In-Reply-To: <20131202095255.GA13247@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 2 Dec 2013 10:52:55 +0100

> On tx submit the driver always dma_map_single() FEC_ENET_TX_FRSIZE (=2048)
> bytes. This works because we don't overwrite any memory after the data buffer,
> we remove it from cache if it was there. So we hurt performace in case the
> mapping of a smaller area makes a difference.
> There is also a bug: If the data area starts shortly before the end of
> RAM say 0xc7fffa10 and the RAM ends at 0xc8000000 then we have enough
> space to fit the data area (according to skb->len) but we would map beyond
> end of ram if we are using 2048. In v2.6.31 (against which kernel this patch
> made) there is the following check in dma_cache_maint():
> 
> |BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(start + size - 1));
> 
> Since the area starting at 0xc8000000 is no longer virt_addr_valid() we
> BUG() during dma_map_single(). The BUG() statement was removed in v3.5-rc1 as
> per 2dc6a016 ("ARM: dma-mapping: use asm-generic/dma-mapping-common.h").
> 
> This patch was tested on v2.6.31 and then forward-ported and compile
> tested only against the net tree. I think it is still worth fixing
> mainline even after the BUG() statement is gone.
> 
> Tested-by: Fugang Duan <B38611@freescale.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Applied, thanks.
