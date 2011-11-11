From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH V2 01/14] clk: add helper functions clk_prepare_enable
 and clk_disable_unprepare
Date: Fri, 11 Nov 2011 09:28:17 +0200
Message-ID: <20111111072817.GB3692@tarshish>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
 <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linux-i2c@vger.kernel.org,
	linux-mmc@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, amit.kucheria@canonical.com,
	linux@arm.linux.org.uk, kernel@pengutronix.de,
	eric.miao@linaro.org, ben-linux@fluff.org, cjb@laptop.org,
	alan@linux.intel.com
To: Richard Zhao <richard.zhao@linaro.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Fri, Nov 11, 2011 at 09:10:16AM +0800, Richard Zhao wrote:
> Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> ---
>  include/linux/clk.h |   19 +++++++++++++++++++
>  1 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/clk.h b/include/linux/clk.h
> index 7213b52..63985f7 100644
> --- a/include/linux/clk.h
> +++ b/include/linux/clk.h
> @@ -107,6 +107,25 @@ static inline void clk_unprepare(struct clk *clk)
>  }
>  #endif
>  
> +static inline int clk_prepare_enable(struct clk *clk)
> +{
> +	int ret;
> +
> +	ret = clk_prepare(clk);
> +	if (!ret)
> +		ret = clk_enable(clk);
> +	if (ret)

Using 'else' here makes the code more readable IMO.

baruch

> +		clk_unprepare(clk);
> +
> +	return ret;
> +}
> +
> +static inline void clk_disable_unprepare(struct clk *clk)
> +{
> +	clk_disable(clk);
> +	clk_unprepare(clk);
> +}
> +
>  /**
>   * clk_get_rate - obtain the current clock rate (in Hz) for a clock source.
>   *		  This is only valid once the clock source has been enabled.
> -- 
> 1.7.5.4

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
