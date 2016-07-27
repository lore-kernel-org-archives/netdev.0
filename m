From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Wed, 27 Jul 2016 16:35:14 +1000
Message-ID: <20160727163514.564bfe29@canb.auug.org.au>
References: <20160727161533.5c5d1702@canb.auug.org.au>
	<20160726.231959.811328304777471297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, isubramanian@apm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160726.231959.811328304777471297.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, 26 Jul 2016 23:19:59 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>
> Fixed thusly:
> 
> ====================
> From 36232012344b8db67052432742deaf17f82e70e6 Mon Sep 17 00:00:00 2001
> From: "David S. Miller" <davem@davemloft.net>
> Date: Tue, 26 Jul 2016 23:19:29 -0700
> Subject: [PATCH] xgene: Fix build warning with ACPI disabled.
> 
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_phy_connect':
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:759:22: warning: unused variable 'adev' [-Wunused-variable]
> 
> Fixes: 8089a96f601b ("drivers: net: xgene: Add backward compatibility")
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> index 8a2a221..7714b7d 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -756,7 +756,6 @@ int xgene_enet_phy_connect(struct net_device *ndev)
>  	struct device_node *np;
>  	struct phy_device *phy_dev;
>  	struct device *dev = &pdata->pdev->dev;
> -	struct acpi_device *adev;
>  	int i;
>  
>  	if (dev->of_node) {
> @@ -781,7 +780,7 @@ int xgene_enet_phy_connect(struct net_device *ndev)
>  		pdata->phy_dev = phy_dev;
>  	} else {
>  #ifdef CONFIG_ACPI
> -		adev = acpi_phy_find_device(dev);
> +		struct acpi_device *adev = acpi_phy_find_device(dev);
>  		if (adev)
>  			pdata->phy_dev =  adev->driver_data;

Looks good to me, thanks.

-- 
Cheers,
Stephen Rothwell
