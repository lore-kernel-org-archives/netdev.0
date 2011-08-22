From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: test the just-initialized
 value
Date: Mon, 22 Aug 2011 10:19:48 -0500
Message-ID: <4E527394.4080900@lwfinger.net>
References: <1314021636-11528-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bing Zhao <bzhao@marvell.com>, kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314021636-11528-4-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2011 09:00 AM, Julia Lawall wrote:
> From: Julia Lawall<julia@diku.dk>
>
> Test the just-initialized value rather than some other one.
>
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
>
> //<smpl>
> @r@
> identifier x,y,f!={PTR_ERR,ERR_PTR,ERR_CAST};
> statement S;
> @@
>
> x = f(...);
> (
> if (\(x == NULL\|IS_ERR(x)\)) S
> |
> *if (\(y == NULL\|IS_ERR(y)\))
>   { ... when != x
>     return ...; }
> )
> //</smpl>
>
> Signed-off-by: Julia Lawall<julia@diku.dk>
>
> ---
>   drivers/net/wireless/mwifiex/scan.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
> index b28241c..d3111c9 100644
> --- a/drivers/net/wireless/mwifiex/scan.c
> +++ b/drivers/net/wireless/mwifiex/scan.c
> @@ -1480,7 +1480,7 @@ mwifiex_update_curr_bss_params(struct mwifiex_private *priv,
>   		return -ENOMEM;
>   	}
>   	beacon_ie = kzalloc(ie_len, GFP_KERNEL);
> -	if (!bss_desc) {
> +	if (!beacon_ie) {
>   		dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
>   		return -ENOMEM;
>   	}

The error message should also get the bss_desc => beacon_ie chang.

Larry
