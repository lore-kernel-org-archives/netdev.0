From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Micrel KSZ8864RMN 4-port managed switch support
Date: Wed, 02 Apr 2014 09:28:59 -0700
Message-ID: <1396456139.32040.9.camel@joe-AO722>
References: <1396453816-32348-1-git-send-email-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Frederic LAMBERT <frdrc66@gmail.com>, kernel@pengutronix.de
To: Philipp Zabel <p.zabel@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396453816-32348-1-git-send-email-p.zabel@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-02 at 17:50 +0200, Philipp Zabel wrote:
> This patch adds support for the Micrel KSZ8864RMN switch to the spi_ks8995
> driver. The KSZ8864RMN switch has a wider 256-byte register space.

trivia:

> diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
[]
> @@ -317,9 +341,14 @@ static int ks8995_probe(struct spi_device *spi)
>  		goto err_drvdata;
>  	}
>  
> -	dev_info(&spi->dev, "KS89%02X device found, Chip ID:%01x, "
> -			"Revision:%01x\n", ids[0],
> -			get_chip_id(ids[1]), get_chip_rev(ids[1]));
> +	if (get_chip_id(ids[1]) == CHIPID_M) {
> +		dev_info(&spi->dev,
> +			 "KS8995 device found, Chip ID:%01x, Revision:%01x\n",

Using %01x is kind of nonsensical.  %x seems more sensible.

> +			 get_chip_id(ids[1]), get_chip_rev(ids[1]));
> +	} else {
> +		dev_info(&spi->dev, "KSZ8864 device found, Revision:%01x\n",
> +			 get_chip_rev(ids[1]));
> +	}

here too
