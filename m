From: David Miller <davem@davemloft.net>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 11 Dec 2014 15:27:56 -0500 (EST)
Message-ID: <20141211.152756.1471877201690056873.davem@davemloft.net>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
	<20141211.151055.817876561546126576.davem@davemloft.net>
	<20141211202507.GS11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, fabio.estevam@freescale.com,
	ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932909AbaLKU2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:28:00 -0500
In-Reply-To: <20141211202507.GS11285@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 11 Dec 2014 20:25:07 +0000

> Would other drivers need fixing for this as well?  Eg, fec_main.c
> does the following, and this driver is used on iMX6 which can also have
> highmem:
> 
> static int
> fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
>                              struct sk_buff *skb,
>                              struct net_device *ndev)
> {
>                 bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
> ...
>                 addr = dma_map_single(&fep->pdev->dev, bufaddr, frag_len,
>                                       DMA_TO_DEVICE);

Probably, yes.
