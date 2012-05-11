From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net: of/phy: fix build error when phylib is built as
 a module
Date: Fri, 11 May 2012 16:50:17 -0700
Message-ID: <4FADA5B9.1060303@xenotime.net>
References: <20120510.224352.2149006669429730060.davem@davemloft.net> <1336751221-19127-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, paul.gortmaker@windriver.com,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, david.daney@cavium.com
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1336751221-19127-1-git-send-email-bjorn@mork.no>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/11/2012 08:47 AM, Bj=C3=B8rn Mork wrote:

> CONFIG_OF_MDIO is tristate and will be m if PHYLIB is m.  Use
> IS_ENABLED macro to prevent build error:
>=20
>  ERROR: "of_mdio_find_bus" [drivers/net/phy/mdio-mux.ko] undefined!
>=20
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Cc: David Daney <david.daney@cavium.com>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.


> ---
> I wonder if this could be as banal as this?  Not even build tested...
>=20
> Should be wrapped into commit 25106022 if it works, to ensure
> bisectability.
>=20
>=20
>=20
> Bj=C3=B8rn
>=20
>  drivers/net/phy/mdio_bus.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 83d5c9f..683ef1c 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -88,7 +88,7 @@ static struct class mdio_bus_class =3D {
>  	.dev_release	=3D mdiobus_release,
>  };
> =20
> -#ifdef CONFIG_OF_MDIO
> +#if IS_ENABLED(CONFIG_OF_MDIO)
>  /* Helper function for of_mdio_find_bus */
>  static int of_mdio_bus_match(struct device *dev, void *mdio_bus_np)
>  {



--=20
~Randy
