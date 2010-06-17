From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Wed, 16 Jun 2010 18:16:32 -0700 (PDT)
Message-ID: <20100616.181632.27807395.davem@davemloft.net>
References: <1276737229.2847.853.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp,
	mchan@broadcom.com
To: JBottomley@Novell.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1276737229.2847.853.camel@mulgrave.site>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Bottomley <JBottomley@Novell.com>
Date: Wed, 16 Jun 2010 20:13:49 -0500

> However, this code in bnx2.c:
> 
> 		if (!get_dma_ops(&pdev->dev)->sync_single_for_cpu) {
> 			next_rx_buf =
> 				&rxr->rx_buf_ring[
> 					RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> 			prefetch(next_rx_buf->desc);
> 		}
> 
> Looks remarkably fragile: what exactly is it trying to do?
> 
> The commit that causes the problem:
> 
> commit a33fa66bcf365ffe5b79d1ae1d3582cc261ae56e
> Author: Michael Chan <mchan@broadcom.com>
> Date:   Thu May 6 08:58:13 2010 +0000
> 
>     bnx2: Add prefetches to rx path.
> 
> Looks fairly innocuous by the description.
> 
> Should parisc have a get_dma_ops()?  We don't need one because our dma
> ops are per platform not per bus.

I think asking for get_dma_ops() directly in a driver is dodgy at
best, especially one that is meant to compile on any PCI supporting
system.  At least right now.
