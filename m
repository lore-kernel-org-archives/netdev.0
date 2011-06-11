From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/5] net: ep93xx_eth: drop GFP_DMA from call to
 dma_alloc_coherent()
Date: Sat, 11 Jun 2011 16:25:53 -0700 (PDT)
Message-ID: <20110611.162553.618147586345938739.davem@davemloft.net>
References: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
	<a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
	<6f1c0ce5bbc0c36ce509d6503363c5e9ee3f626b.1307816881.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	hsweeten@visionengravers.com, rmallon@gmail.com, ynezz@true.cz
To: mika.westerberg@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab1FKX1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:27:03 -0400
In-Reply-To: <6f1c0ce5bbc0c36ce509d6503363c5e9ee3f626b.1307816881.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Westerberg <mika.westerberg@iki.fi>
Date: Sat, 11 Jun 2011 21:39:57 +0300

> Commit a197b59ae6e8 (mm: fail GFP_DMA allocations when ZONE_DMA is not
> configured) made page allocator to return NULL if GFP_DMA is set but
> CONFIG_ZONE_DMA is disabled.
> 
> This causes ep93xx_eth to fail:
> 
>  WARNING: at mm/page_alloc.c:2251 __alloc_pages_nodemask+0x11c/0x638()
>  Modules linked in:
>  [<c0035498>] (unwind_backtrace+0x0/0xf4) from [<c0043da4>] (warn_slowpath_common+0x48/0x60)
>  [<c0043da4>] (warn_slowpath_common+0x48/0x60) from [<c0043dd8>] (warn_slowpath_null+0x1c/0x24)
>  [<c0043dd8>] (warn_slowpath_null+0x1c/0x24) from [<c0083b6c>] (__alloc_pages_nodemask+0x11c/0x638)
>  [<c0083b6c>] (__alloc_pages_nodemask+0x11c/0x638) from [<c00366fc>] (__dma_alloc+0x8c/0x3ec)
>  [<c00366fc>] (__dma_alloc+0x8c/0x3ec) from [<c0036adc>] (dma_alloc_coherent+0x54/0x60)
>  [<c0036adc>] (dma_alloc_coherent+0x54/0x60) from [<c0227808>] (ep93xx_open+0x20/0x864)
>  [<c0227808>] (ep93xx_open+0x20/0x864) from [<c0283144>] (__dev_open+0xb8/0x108)
>  [<c0283144>] (__dev_open+0xb8/0x108) from [<c0280528>] (__dev_change_flags+0x70/0x128)
>  [<c0280528>] (__dev_change_flags+0x70/0x128) from [<c0283054>] (dev_change_flags+0x10/0x48)
>  [<c0283054>] (dev_change_flags+0x10/0x48) from [<c001a720>] (ip_auto_config+0x190/0xf68)
>  [<c001a720>] (ip_auto_config+0x190/0xf68) from [<c00233b0>] (do_one_initcall+0x34/0x18c)
>  [<c00233b0>] (do_one_initcall+0x34/0x18c) from [<c0008400>] (kernel_init+0x94/0x134)
>  [<c0008400>] (kernel_init+0x94/0x134) from [<c0030858>] (kernel_thread_exit+0x0/0x8)
> 
> Since there is no restrictions for DMA on ep93xx, we can fix this by just
> removing the GFP_DMA flag from the call.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Tested-by: Petr Stetiar <ynezz@true.cz>

Applied.
