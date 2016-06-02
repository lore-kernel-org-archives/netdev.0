From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix rx-usecs interrupt pacing
 consistency
Date: Thu, 2 Jun 2016 16:30:00 +0300
Message-ID: <575034D8.4040500@linaro.org>
References: <1464873292-17011-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464873292-17011-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02.06.16 16:14, Ivan Khoronzhuk wrote:
> The rx-usecs shouldn't be changed while interface down/up.
> Currently, for instance, if it's set to 100us, after interface
> down/up it's 500us. It's a hidden bug that can lead to lavish
> interrupt pacing time increasing while "down/up" up to max value.
>
> Steps to reproduce:
> - set rx-usecs to be 100us
> - down/up interface
> - read new unexpected rx-usecs
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>
> Based on ti-linux-4.4.y
Please ignore this line, it's added by mistake.
The patch is based on master.


>
>   drivers/net/ethernet/ti/cpsw.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 7b44587..9919cb3 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1352,7 +1352,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   	if (priv->coal_intvl != 0) {
>   		struct ethtool_coalesce coal;
>
> -		coal.rx_coalesce_usecs = (priv->coal_intvl << 4);
> +		coal.rx_coalesce_usecs = priv->coal_intvl;
>   		cpsw_set_coalesce(ndev, &coal);
>   	}
>
>

-- 
Regards,
Ivan Khoronzhuk
