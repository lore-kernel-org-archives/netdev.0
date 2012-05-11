From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] net: of/phy: fix build error when phylib is built as
 a module
Date: Fri, 11 May 2012 10:58:06 -0700
Message-ID: <4FAD532E.401@gmail.com>
References: <20120510.224352.2149006669429730060.davem@davemloft.net> <1336751221-19127-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336751221-19127-1-git-send-email-bjorn@mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/11/2012 08:47 AM, Bj=C3=B8rn Mork wrote:
> CONFIG_OF_MDIO is tristate and will be m if PHYLIB is m.  Use
> IS_ENABLED macro to prevent build error:
>
>   ERROR: "of_mdio_find_bus" [drivers/net/phy/mdio-mux.ko] undefined!
>
> Reported-by: Randy Dunlap<rdunlap@xenotime.net>
> Cc: David Daney<david.daney@cavium.com>
> Signed-off-by: Bj=C3=B8rn Mork<bjorn@mork.no>

I was able to reproduce the failure, and this patch both fixes it and=20
seems correct, so...

Acked-by: David Daney<david.daney@cavium.com>

Sorry about this failure.


> ---
> I wonder if this could be as banal as this?  Not even build tested...
>
> Should be wrapped into commit 25106022 if it works, to ensure
> bisectability.
>
>
>
> Bj=C3=B8rn
>
>   drivers/net/phy/mdio_bus.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 83d5c9f..683ef1c 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -88,7 +88,7 @@ static struct class mdio_bus_class =3D {
>   	.dev_release	=3D mdiobus_release,
>   };
>
> -#ifdef CONFIG_OF_MDIO
> +#if IS_ENABLED(CONFIG_OF_MDIO)
>   /* Helper function for of_mdio_find_bus */
>   static int of_mdio_bus_match(struct device *dev, void *mdio_bus_np)
>   {
