From: Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3 10/14] ARM: mxs: add clk_prepare/clk_unprepare
Date: Mon, 19 Dec 2011 23:21:41 +0100
Message-ID: <201112192321.41560.marek.vasut@gmail.com>
References: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org> <1321008637-19999-11-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	eric.miao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org, cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org,
	alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1321008637-19999-11-git-send-email-richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Signed-off-by: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  arch/arm/mach-mxs/system.c |    2 +-
>  arch/arm/mach-mxs/timer.c  |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/mach-mxs/system.c b/arch/arm/mach-mxs/system.c
> index 20ec3bd..9760a12 100644
> --- a/arch/arm/mach-mxs/system.c
> +++ b/arch/arm/mach-mxs/system.c
> @@ -66,7 +66,7 @@ static int __init mxs_arch_reset_init(void)
> 
>  	clk = clk_get_sys("rtc", NULL);
>  	if (!IS_ERR(clk))
> -		clk_enable(clk);
> +		clk_prepare_enable(clk);
> 
>  	return 0;
>  }
> diff --git a/arch/arm/mach-mxs/timer.c b/arch/arm/mach-mxs/timer.c
> index cace0d2..564a632 100644
> --- a/arch/arm/mach-mxs/timer.c
> +++ b/arch/arm/mach-mxs/timer.c
> @@ -245,7 +245,7 @@ static int __init mxs_clocksource_init(struct clk
> *timer_clk)
> 
>  void __init mxs_timer_init(struct clk *timer_clk, int irq)
>  {
> -	clk_enable(timer_clk);
> +	clk_prepare_enable(timer_clk);
> 
>  	/*
>  	 * Initialize timers to a known state

Hi Richard,

I just came across this, will this also help solve the mxs problem with mutex 
lock begin done in atomic context in clk_enable/disable()?

M
