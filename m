From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: of_mdio: fix behavior on missing phy device
Date: Tue, 07 May 2013 21:55:45 +0400
Message-ID: <51894021.1070900@cogentembedded.com>
References: <1367920171-20264-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	David Miller <davem@davemloft.net>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367920171-20264-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07-05-2013 13:49, Sebastian Hesselbarth wrote:

> of_mdiobus_register creates a phy_device even if get_phy_device failed
> to create it previously. This causes indefinite polling on non-existent
> PHYs. This fix makes of_mdio_register rely on get_phy_device to
> properly create the device or fail otherwise.

> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <rob.herring@calxeda.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: devicetree-discuss@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org
> ---
>   drivers/of/of_mdio.c |   11 ++++-------
>   1 file changed, 4 insertions(+), 7 deletions(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 23049ae..d5a57a9 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -84,13 +84,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>   		phy = get_phy_device(mdio, addr, is_c45);
>

    This empty line is not needed -- would be good to drop it, while at 
this.

>   		if (!phy || IS_ERR(phy)) {
> -			phy = phy_device_create(mdio, addr, 0, false, NULL);
> -			if (!phy || IS_ERR(phy)) {
> -				dev_err(&mdio->dev,
> -					"error creating PHY at address %i\n",
> -					addr);
> -				continue;
> -			}
> +			dev_err(&mdio->dev,
> +				"cannot get PHY at address %i\n",
> +				addr);
> +			continue;
>   		}
>
>   		/* Associate the OF node with the device structure so it
>
