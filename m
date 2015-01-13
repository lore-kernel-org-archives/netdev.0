From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] infiniband: mlx5: avoid a compile-time warning
Date: Tue, 13 Jan 2015 18:30:59 +0200
Message-ID: <20150113163059.GB7414@mtldesk30>
References: <2267004.49D0qFBpL1@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2267004.49D0qFBpL1@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Acked-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

On Tue, Jan 13, 2015 at 05:09:43PM +0100, Arnd Bergmann wrote:
> The return type of find_first_bit() is architecture specific,
> on ARM it is 'unsigned int', while the asm-generic code used
> on x86 and a lot of other architectures returns 'unsigned long'.
> 
> When building the mlx5 driver on ARM, we get a warning about
> this:
> 
> infiniband/hw/mlx5/mem.c: In function 'mlx5_ib_cont_pages':
> infiniband/hw/mlx5/mem.c:84:143: warning: comparison of distinct pointer types lacks a cast
>      m = min(m, find_first_bit(&tmp, sizeof(tmp)));
> 
> This patch changes the driver to use min_t to make it behave
> the same way on all architectures.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> 
> diff --git a/drivers/infiniband/hw/mlx5/mem.c b/drivers/infiniband/hw/mlx5/mem.c
> index b56e4c5593ee..611a9fdf2f38 100644
> --- a/drivers/infiniband/hw/mlx5/mem.c
> +++ b/drivers/infiniband/hw/mlx5/mem.c
> @@ -81,7 +81,7 @@ void mlx5_ib_cont_pages(struct ib_umem *umem, u64 addr, int *count, int *shift,
>  		for (k = 0; k < len; k++) {
>  			if (!(i & mask)) {
>  				tmp = (unsigned long)pfn;
> -				m = min(m, find_first_bit(&tmp, sizeof(tmp)));
> +				m = min_t(unsigned long, m, find_first_bit(&tmp, sizeof(tmp)));
>  				skip = 1 << m;
>  				mask = skip - 1;
>  				base = pfn;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
