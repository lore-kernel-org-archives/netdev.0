From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Export __netdev_alloc_frag() to allow gfp_mask
 flags
Date: Wed, 29 Jul 2015 18:31:56 +0200
Message-ID: <1438187516.20182.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, m-karicheri2@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Reece R. Pollack" <x0183204@ti.com>
To: WingMan Kwok <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-29 at 11:10 -0400, WingMan Kwok wrote:
> This patch makes the function __netdev_alloc_frag() non-static and
> exports it so that drivers that need to specify additional flags,
> such as __GFP_DMA, can use it. The currently exported function,
> netdev_alloc_frag() doesn't allow passing in gfp_mask flags.
> 
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
> Signed-off-by: Reece R. Pollack <x0183204@ti.com>
> ---
>  include/linux/skbuff.h |    1 +
>  net/core/skbuff.c      |    3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)

You can not do this.

__napi_alloc_frag() uses __alloc_page_frag() using a per cpu reserve.

This per cpu reserve would be shared by regular GFP_ATOMIC and your
__GFP_DMA allocations.
