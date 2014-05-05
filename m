From: Tero Kristo <t-kristo-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 5/6] ARM: AM43xx: clk: Change the cpts ref clock source
 to dpll_core_m5 clk
Date: Mon, 5 May 2014 15:22:01 +0300
Message-ID: <53678269.2000306@ti.com>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com> <1399012324-20737-6-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>, <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	<bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <balbi-l0cyMroinI0@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<pawel.moll-5wv7dgnIgG8@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	<bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: George Cherian <george.cherian-l0cyMroinI0@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399012324-20737-6-git-send-email-george.cherian-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/02/2014 09:32 AM, George Cherian wrote:
> cpsw_cpts_rft_clk has got the choice of 3 clocksources
>   -dpll_core_m4_ck
>   -dpll_core_m5_ck
>   -dpll_disp_m2_ck
>
> By default dpll_core_m4_ck is selected, witn this as clock
> source the CPTS doesnot work properly. It gives clockcheck errors
> while running PTP.
>
>   clockcheck: clock jumped backward or running slower than expected!
>
> By selecting dpll_core_m5_ck as the clocksource fixes this issue.
> In AM335x dpll_core_m5_ck is the default clocksource.
>
> Signed-off-by: George Cherian <george.cherian-l0cyMroinI0@public.gmane.org>

Acked-by: Tero Kristo <t-kristo-l0cyMroinI0@public.gmane.org>

> ---
>   drivers/clk/ti/clk-43xx.c | 16 ++++++++++++++++
>   1 file changed, 16 insertions(+)
>
> diff --git a/drivers/clk/ti/clk-43xx.c b/drivers/clk/ti/clk-43xx.c
> index 67c8de5..b4877e0 100644
> --- a/drivers/clk/ti/clk-43xx.c
> +++ b/drivers/clk/ti/clk-43xx.c
> @@ -110,9 +110,25 @@ static struct ti_dt_clk am43xx_clks[] = {
>
>   int __init am43xx_dt_clk_init(void)
>   {
> +	struct clk *clk1, *clk2;
> +
>   	ti_dt_clocks_register(am43xx_clks);
>
>   	omap2_clk_disable_autoidle_all();
>
> +	/*
> +	 * cpsw_cpts_rft_clk  has got the choice of 3 clocksources
> +	 * dpll_core_m4_ck, dpll_core_m5_ck and dpll_disp_m2_ck.
> +	 * By default dpll_core_m4_ck is selected, witn this as clock
> +	 * source the CPTS doesnot work properly. It gives clockcheck errors
> +	 * while running PTP.
> +	 * clockcheck: clock jumped backward or running slower than expected!
> +	 * By selecting dpll_core_m5_ck as the clocksource fixes this issue.
> +	 * In AM335x dpll_core_m5_ck is the default clocksource.
> +	 */
> +	clk1 = clk_get_sys(NULL, "cpsw_cpts_rft_clk");
> +	clk2 = clk_get_sys(NULL, "dpll_core_m5_ck");
> +	clk_set_parent(clk1, clk2);
> +
>   	return 0;
>   }
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
