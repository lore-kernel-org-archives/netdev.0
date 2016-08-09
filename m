From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix kmemleak false-positive reports
 for sk buffers
Date: Tue, 9 Aug 2016 16:19:37 +0100
Message-ID: <20160809151937.GA15447@e104818-lin.cambridge.arm.com>
References: <20160809120944.23185-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160809120944.23185-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 09, 2016 at 03:09:44PM +0300, Grygorii Strashko wrote:
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 0805855..0456e0e 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -732,6 +732,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
>  		netif_receive_skb(skb);
>  		ndev->stats.rx_bytes += len;
>  		ndev->stats.rx_packets++;
> +		kmemleak_not_leak(new_skb);
>  	} else {
>  		ndev->stats.rx_dropped++;
>  		new_skb = skb;
> @@ -1323,6 +1324,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  				kfree_skb(skb);
>  				goto err_cleanup;
>  			}
> +			kmemleak_not_leak(skb);

Nitpick: I would add a short comment above the kmemleak_not_leak() calls
on why there is a false positive. Otherwise:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
