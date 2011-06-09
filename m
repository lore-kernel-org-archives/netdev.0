From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 4/5] net: ep93xx_eth: drop GFP_DMA from call to
 dma_alloc_coherent()
Date: Thu, 9 Jun 2011 15:59:54 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3820B8623@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <c2142b13f03e2d183a4f28b9b2b8fc81b30530a8.1307040443.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>,
	"ryan@bluewatersys.com" <ryan@bluewatersys.com>
To: Mika Westerberg <mika.westerberg@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail160.messagelabs.com ([216.82.253.99]:39390 "EHLO
	mail160.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311Ab1FIU77 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:59:59 -0400
In-Reply-To: <c2142b13f03e2d183a4f28b9b2b8fc81b30530a8.1307040443.git.mika.westerberg@iki.fi>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, June 02, 2011 12:00 PM, Mika Westerberg wrote:
>
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

If this is a bug fix maybe it should be submitted as a separate patch.  Russell could
apply it now to fix the problem.

Regardless,

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
