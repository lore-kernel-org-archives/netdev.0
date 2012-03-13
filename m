From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/1] net: phylib: add error checking if no phy found
Date: Tue, 13 Mar 2012 15:33:35 +0100
Message-ID: <4F5F5ABF.5030103@openwrt.org>
References: <1331636302-18256-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
	timur@freescale.com, rdunlap@xenotime.net, kernel@pengutronix.de
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331636302-18256-1-git-send-email-b29396@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Le 03/13/12 11:58, Dong Aisheng a =C3=A9crit :
> From: Dong Aisheng<dong.aisheng@linaro.org>
>
> Signed-off-by: Dong Aisheng<dong.aisheng@linaro.org>
> ---
>   drivers/net/phy/mdio_bus.c |   11 ++++++++++-
>   1 files changed, 10 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 88cc5db..d8e044d 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -101,6 +101,7 @@ static struct class mdio_bus_class =3D {
>   int mdiobus_register(struct mii_bus *bus)
>   {
>   	int i, err;
> +	u32 phynum =3D 0;
>
>   	if (NULL =3D=3D bus || NULL =3D=3D bus->name ||
>   			NULL =3D=3D bus->read ||
> @@ -134,12 +135,20 @@ int mdiobus_register(struct mii_bus *bus)
>   			if (IS_ERR(phydev)) {
>   				err =3D PTR_ERR(phydev);
>   				goto error;
> +			} else if (phydev !=3D NULL) {
> +				phynum++;
>   			}
>   		}
>   	}
>
> +	if (!phynum) {
> +		err =3D -ENODEV;
> +		printk(KERN_ERR "%s: no phys found\n", bus->name);
> +		goto error;
> +	}

I am not sure if this is a good idea to change it, especially if:
- the MII bus probing is also done later (quite some drivers do this)
- if we want to attach a fixed PHY because we could not probe one at=20
registration time

> +
>   	bus->state =3D MDIOBUS_REGISTERED;
> -	pr_info("%s: probed\n", bus->name);
> +	pr_info("%s: %d phys probed\n", bus->name, phynum);
>   	return 0;
>
>   error:
