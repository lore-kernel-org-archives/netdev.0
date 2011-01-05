From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: r6040: Return proper error for r6040_init_one
Date: Wed, 5 Jan 2011 10:50:45 +0100
Message-ID: <201101051050.45381.florian@openwrt.org>
References: <1294216804.19064.2.camel@mola>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Axel Lin <axel.lin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294216804.19064.2.camel@mola>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 05 January 2011 09:40:04 Axel Lin wrote:
> Return -ENOMEM instead of 0 for the case of mdiobus_alloc and kmalloc
> failure.
>
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Acked-by: Florian Fainelli <florian@openwrt.org>

> ---
>  drivers/net/r6040.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 0b014c89..27e6f6d 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -1153,6 +1153,7 @@ static int __devinit r6040_init_one(struct pci_dev
> *pdev, lp->mii_bus = mdiobus_alloc();
>  	if (!lp->mii_bus) {
>  		dev_err(&pdev->dev, "mdiobus_alloc() failed\n");
> +		err = -ENOMEM;
>  		goto err_out_unmap;
>  	}
> 
> @@ -1165,6 +1166,7 @@ static int __devinit r6040_init_one(struct pci_dev
> *pdev, lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
> if (!lp->mii_bus->irq) {
>  		dev_err(&pdev->dev, "mii_bus irq allocation failed\n");
> +		err = -ENOMEM;
>  		goto err_out_mdio;
>  	}
