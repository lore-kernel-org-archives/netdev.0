From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: avoid unused function warnings
Date: Sat, 27 Aug 2016 01:48:15 +0300
Message-ID: <d26d8354-3ea3-29b0-d40c-253dd023e1e9@cogentembedded.com>
References: <20160826153108.680850-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160826153108.680850-1-arnd@arndb.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/26/2016 06:30 PM, Arnd Bergmann wrote:

> When CONFIG_PM_SLEEP is disabled, we get a couple of harmless warnings:
>
> drivers/net/ethernet/renesas/ravb_main.c:2117:12: error: 'ravb_resume' defined but not used [-Werror=unused-function]
> drivers/net/ethernet/renesas/ravb_main.c:2104:12: error: 'ravb_suspend' defined but not used [-Werror=unused-function]
>
> The simplest solution here is to replace the #ifdef with __maybe_unused
> annotations, which lets the compiler do the right thing by itself.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 0184165b2f42 ("ravb: add sleep PM suspend/resume support")

    That was the patch I didn't review, sorry about that...

> ---
>  drivers/net/ethernet/renesas/ravb_main.c | 14 ++++----------
>  1 file changed, 4 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index cad23ba06904..630536bc72f9 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
> @@ -2166,17 +2165,12 @@ static const struct dev_pm_ops ravb_dev_pm_ops = {
>  	SET_RUNTIME_PM_OPS(ravb_runtime_nop, ravb_runtime_nop, NULL)
>  };
>
> -#define RAVB_PM_OPS (&ravb_dev_pm_ops)
> -#else
> -#define RAVB_PM_OPS NULL
> -#endif
> -
>  static struct platform_driver ravb_driver = {
>  	.probe		= ravb_probe,
>  	.remove		= ravb_remove,
>  	.driver = {
>  		.name	= "ravb",
> -		.pm	= RAVB_PM_OPS,
> +		.pm	= &ravb_dev_pm_ops,

    I guess it's safe to have this pointing to the 'struct dev_pm_ops' filled 
with NULLs? Looking at the PM code left me somewhat unsure...

[...]

MBR, Sergei
