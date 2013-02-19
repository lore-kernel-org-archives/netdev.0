From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 2/5] usb: phy: omap-usb2: use the new generic PHY
 framework
Date: Tue, 19 Feb 2013 10:11:57 +0200
Message-ID: <20130219081157.GE23197@arwen.pp.htv.fi>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
 <1361253198-7401-3-git-send-email-kishon@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k3qmt+ucFURmlhDS"
Cc: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <balbi@ti.com>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<arnd@arndb.de>, <santosh.shilimkar@ti.com>,
	<broonie@opensource.wolfsonmicro.com>, <swarren@nvidia.com>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1361253198-7401-3-git-send-email-kishon@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--k3qmt+ucFURmlhDS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 11:23:15AM +0530, Kishon Vijay Abraham I wrote:
> Used the generic PHY framework API to create the PHY. omap_usb2_suspend
> is split into omap_usb_suspend and omap_usb_resume in order to align
> with the new framework.
>=20
> However using the old USB PHY library cannot be completely removed
> because OTG is intertwined with PHY and moving to the new framework
> will break OTG. Once we have a separate OTG state machine, we
> can get rid of the USB PHY library.
>=20
> Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
> ---
>  drivers/usb/phy/omap-usb2.c  |   49 ++++++++++++++++++++++++++++++++++++=
++++++
>  include/linux/usb/omap_usb.h |    3 +++
>  2 files changed, 52 insertions(+)
>=20
> diff --git a/drivers/usb/phy/omap-usb2.c b/drivers/usb/phy/omap-usb2.c
> index 844ab68..924ae59 100644
> --- a/drivers/usb/phy/omap-usb2.c
> +++ b/drivers/usb/phy/omap-usb2.c
> @@ -119,9 +119,48 @@ static int omap_usb2_suspend(struct usb_phy *x, int =
suspend)
>  	return 0;
>  }
> =20
> +static int omap_usb_suspend(struct phy_descriptor *desc)
> +{
> +	struct omap_usb *phy =3D desc_to_omapusb(desc);
> +
> +	if (!phy->is_suspended) {

I wonder if it wouldn't be better to have some refcounting done by phy
framework itself so that this only gets called when phy->refcount =3D=3D 0

> +		omap_control_usb_phy_power(phy->control_dev, 0);

coudln't you move this to ->runtime_suspend() ?

> +		pm_runtime_put_sync(phy->dev);
> +		phy->is_suspended =3D 1;
> +	}
> +
> +	return 0;
> +}
> +
> +static int omap_usb_resume(struct phy_descriptor *desc)
> +{
> +	u32 ret;
> +	struct omap_usb *phy =3D desc_to_omapusb(desc);
> +
> +	if (phy->is_suspended) {
> +		ret =3D pm_runtime_get_sync(phy->dev);
> +		if (ret < 0) {
> +			dev_err(phy->dev, "get_sync failed with err %d\n",
> +									ret);
> +			return ret;
> +		}
> +		omap_control_usb_phy_power(phy->control_dev, 1);

likewise, this could go to ->runtime_resume().

--=20
balbi

--k3qmt+ucFURmlhDS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRIzPNAAoJEIaOsuA1yqREg+0QAKsxwxMggFwI4PN9yXPQ1k+P
NZYFxgp/BpS9KzE9jhinEzv/e7I0l2VR4hCplP7sYpAyBJPvjswtwDWg0ixhJ9QG
vEU3sO6aWDekrlvt+K+wn6q21DaoxmpUL9+t/XrIqOHQvD0HvH04jUdt1Z//VWii
MNn+SuTX8jKq+EKOI8/g/KAiPKIFciCy7G5h8ZjIBe4dRzKRssWdVu5n14Uzk8Hx
APqQ3eKoacbYf5nOd1ZHYedBSOU6mbR/JNYSnAZnqTGr1LCDs3iUXFzjEbN275aF
AeZOJ5hC7dPw8wvCTE5MMYfgWFa2eWiXnVwSK0ZXUWZyV3nl6pJyFUzp1BUi5oiN
UwxW5X4KeD+TuSYduDZRLTy6e+DhBb609sowGl/2WsGE1FzzpNPjo6GtLLH6XDBO
c5Y6xAZbqhTq4aMQbN+ihy7dQI24WOPMP7c2AwzFXjSNh0FZdYf0IpcUscZEZNCv
pgCT47slflKuqIb6vO4hvHNhuv7csK2vrBfmpEYtsLqNW3xJR2Cf6BfJ3xVyp205
srkte+mmNhVinMlSK3iGY/hLDcyFpPXUuKeGZomvuQGF6a4cmlnOZOUrvV9RR5kK
2BsD0t59obU1LwyFRBxJ9Mll1Pfy28TtCGfXQ9WZU7mrRAfNPrFULsV7dhLRqeoQ
xqBvomGY8RCmn7cpvA8C
=LJfB
-----END PGP SIGNATURE-----

--k3qmt+ucFURmlhDS--
