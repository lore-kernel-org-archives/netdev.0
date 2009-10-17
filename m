From: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Sat, 17 Oct 2009 22:43:02 +0900
Message-ID: <20091017224028V.fujita.tomonori@lab.ntt.co.jp>
References: <20091009164100.85a36188.akpm@linux-foundation.org>
	<20091013021818.GA3898@localhost.localdomain>
	<20091013091017.GA18431@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org,
	paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	LW-bxm8fMRDkQLDiMYJYoSAnRvVK+yQ3ZXh@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-altix-sJ/iWh9BUns@public.gmane.org
To: akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091013091017.GA18431-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Oct 2009 18:10:17 +0900
Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> My user space testing exposed off-by-one error find_next_zero_area
> in iommu-helper. Some zero area cannot be found by this bug.
> 
> Subject: [PATCH] Fix off-by-one error in find_next_zero_area
> 
> Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  lib/iommu-helper.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
> index 75dbda0..afc58bc 100644
> --- a/lib/iommu-helper.c
> +++ b/lib/iommu-helper.c
> @@ -19,7 +19,7 @@ again:
>  	index = (index + align_mask) & ~align_mask;
>  
>  	end = index + nr;
> -	if (end >= size)
> +	if (end > size)

I think that this is intentional; the last byte of the limit doesn't
work.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
