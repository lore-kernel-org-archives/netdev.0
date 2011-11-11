From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V2 01/14] clk: add helper functions clk_prepare_enable
 and clk_disable_unprepare
Date: Fri, 11 Nov 2011 09:49:50 +0100
Message-ID: <20111111084950.GH16886@pengutronix.de>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
 <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linux-i2c@vger.kernel.org,
	linux-mmc@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux@arm.linux.org.uk,
	amit.kucheria@canonical.com, kernel@pengutronix.de,
	ben-linux@fluff.org, cjb@laptop.org, alan@linux.intel.com,
	eric.miao@linaro.org
To: Richard Zhao <richard.zhao@linaro.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> +		clk_unprepare(clk);

As Baruch already pointed out this is hard to read. Also it contains a
bug. When clk_prepare fails clk_unprepare is called afterwards.

Hint: Kernel guys are not afraid of having multiple return statements
in a function, instead they like it when something is handled early
without having to read the rest of the function.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
