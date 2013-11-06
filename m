From: Eugene Krasnikov <k.eugene.e@gmail.com>
Subject: Re: [PATCH] wcn36xx: Fix logging macro with unnecessary semicolon
Date: Wed, 6 Nov 2013 07:49:29 +0000
Message-ID: <CAFSJ42YQy96Sko8CuG9BGjHzTV7TkRp2=NVt036APxSKpPB=Ag@mail.gmail.com>
References: <1383684000.4387.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383684000.4387.42.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hm... when it comes to semicolon the patch seems to be good. When it
comes to dynamic debugging i think we should have a separate
discussion about that.
I personally like the whole idea about dynamic debug but if you want
to change it i would suggest to have some kind of framework for all
ath drivers(or maybe all wireless drivers). Because obviously you can
find common code in every driver that defines it's own debug
functions/debug levels and so on. Why not to make a framework with
standard API/levels?

On Tue, Nov 5, 2013 at 8:40 PM, Joe Perches <joe@perches.com> wrote:
> The wcn36xx_err macro should not end in a semicolon as
> there are 2 consecutive semicolons in the preprocessed
> output.
>
> Remove it.
>
> Neaten the logging macros to use a more common style.
> Convert to use pr_debug to enable dynamic debug.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 28 +++++++++++++---------------
>  1 file changed, 13 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> index 58b6383..d157bb7 100644
> --- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> +++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> @@ -53,22 +53,20 @@ enum wcn36xx_debug_mask {
>         WCN36XX_DBG_ANY         = 0xffffffff,
>  };
>
> -#define wcn36xx_err(fmt, arg...)                               \
> -       printk(KERN_ERR pr_fmt("ERROR " fmt), ##arg);
> -
> -#define wcn36xx_warn(fmt, arg...)                              \
> -       printk(KERN_WARNING pr_fmt("WARNING " fmt), ##arg)
> -
> -#define wcn36xx_info(fmt, arg...)              \
> -       printk(KERN_INFO pr_fmt(fmt), ##arg)
> -
> -#define wcn36xx_dbg(mask, fmt, arg...) do {                    \
> -       if (wcn36xx_dbg_mask & mask)                                    \
> -               printk(KERN_DEBUG pr_fmt(fmt), ##arg);  \
> +#define wcn36xx_err(fmt, ...)                                  \
> +       pr_err("ERROR " fmt, ##__VA_ARGS__)
> +#define wcn36xx_warn(fmt, ...)                                 \
> +       pr_warn("WARNING " fmt, ##__VA_ARGS__)
> +#define wcn36xx_info(fmt, ...)                                 \
> +       pr_info(fmt, ##__VA_ARGS__)
> +#define wcn36xx_dbg(mask, fmt, ...)                            \
> +do {                                                           \
> +       if (wcn36xx_dbg_mask & mask)                            \
> +               pr_debug(fmt, ##__VA_ARGS__);                   \
>  } while (0)
> -
> -#define wcn36xx_dbg_dump(mask, prefix_str, buf, len) do {      \
> -       if (wcn36xx_dbg_mask & mask)                                    \
> +#define wcn36xx_dbg_dump(mask, prefix_str, buf, len)           \
> +do {                                                           \
> +       if (wcn36xx_dbg_mask & mask)                            \
>                 print_hex_dump(KERN_DEBUG, pr_fmt(prefix_str),  \
>                                DUMP_PREFIX_OFFSET, 32, 1,       \
>                                buf, len, false);                \
>
>



-- 
Best regards,
Eugene
