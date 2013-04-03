From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 2/6] usb: phy: omap-usb2: use the new generic PHY
 framework
Date: Wed, 3 Apr 2013 16:48:27 +0300
Message-ID: <20130403134827.GF14680@arwen.pp.htv.fi>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-3-git-send-email-kishon@ti.com>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0292480595452152103=="
Cc: broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org,
 cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org, eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1364993634-6378-3-git-send-email-kishon-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============0292480595452152103==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ik0NlRzMGhMnxrMX"
Content-Disposition: inline

--ik0NlRzMGhMnxrMX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 03, 2013 at 06:23:50PM +0530, Kishon Vijay Abraham I wrote:
> Used the generic PHY framework API to create the PHY. omap_usb2_suspend
> is split into omap_usb_suspend and omap_usb_resume in order to align
> with the new framework.
>=20
> However using the old USB PHY library cannot be completely removed
> because OTG is intertwined with PHY and moving to the new framework
> will break OTG. Once we have a separate OTG state machine, we
> can get rid of the USB PHY library.
>=20
> Signed-off-by: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> ---
>  drivers/usb/phy/omap-usb2.c |   48 +++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 48 insertions(+)
>=20
> diff --git a/drivers/usb/phy/omap-usb2.c b/drivers/usb/phy/omap-usb2.c
> index 844ab68..4e48db4 100644
> --- a/drivers/usb/phy/omap-usb2.c
> +++ b/drivers/usb/phy/omap-usb2.c
> @@ -28,6 +28,7 @@
>  #include <linux/pm_runtime.h>
>  #include <linux/delay.h>
>  #include <linux/usb/omap_control_usb.h>
> +#include <linux/phy/phy.h>
> =20
>  /**
>   * omap_usb2_set_comparator - links the comparator present in the sytem =
with
> @@ -119,9 +120,49 @@ static int omap_usb2_suspend(struct usb_phy *x, int =
suspend)
>  	return 0;
>  }
> =20
> +static int omap_usb_suspend(struct phy *x)
> +{
> +	struct omap_usb *phy =3D dev_get_drvdata(&x->dev);
> +
> +	if (!phy->is_suspended) {
> +		omap_control_usb_phy_power(phy->control_dev, 0);
> +		pm_runtime_put_sync(phy->dev);
> +		phy->is_suspended =3D 1;
> +	}
> +
> +	return 0;
> +}
> +
> +static int omap_usb_resume(struct phy *x)
> +{
> +	u32 ret;
> +	struct omap_usb *phy =3D dev_get_drvdata(&x->dev);
> +
> +	if (phy->is_suspended) {
> +		ret =3D pm_runtime_get_sync(phy->dev);
> +		if (ret < 0) {
> +			dev_err(phy->dev, "get_sync failed with err %d\n",
> +									ret);
> +			return ret;
> +		}
> +		omap_control_usb_phy_power(phy->control_dev, 1);
> +		phy->is_suspended =3D 0;
> +	}
> +
> +	return 0;
> +}
> +
> +static struct phy_ops ops =3D {

const ? Maybe provide a:

#define DEFINE_PHY_OPS(name)	\
const struct phy_ops #name_phy_ops =3D {

macro ? This will force people to add the const keyword :-)

--=20
balbi

--ik0NlRzMGhMnxrMX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRXDMrAAoJEIaOsuA1yqRE9YMQAKAO8yLvo66L/58x/SnJxyrl
3A7JrDkmh/d07zz19R3XrwfvTaYJg/k1NxakWd/iIUSHbeWGTJrmJzS0DlRbHlmr
+DrRSu1DlkfmKPKCB8Z7kajn8osqFSLAhJzw3tfBbcCTV+8ZnzruQbE1BvJJUlGz
W4AVjssYOoI1Dll/qDekz8QgDdPTkZ7rhabCKEXZjGFbq3RDfe/0UtlPLyTZnM0K
LQlIcZymLCUTTpoY0NdAlM6twdMGc5IEFvRjnDJeEN8z6ILVBolt7dbHwo8DxgBT
naFC/t9lV9e+vBegd5bDzNjH1vbC2Hf9Pu5kf+m+bCCqNV/z+ncCCAMXWDBG8JXA
SS0nsdov7CDbr58FGjTY4VcHv6KIWB4wyepak/nCPrDLaVARiB03l/zMZpVZGO7g
mL3TvIeCRvObsszo/F91xMb+eu11XRuwGOt16reur1yupJ/FvDO91HkxBsK63KX0
tXXyXFLtVM1Ias1xH18GN6Nbz6i3b+0ZSE2GBEitXUAFQF6kBB5FzjmzAm6f8M8a
kksgrQchEr/LkPYKapeKiU0fpRXCIO0DaaXT/kFpte1LoOniq3Z5VoYadZpFoLN2
acpWPTSbG0Myxbru4sjY8p1MzcV6XTleDmv5BCmMVo2XRx31k29r7TRa6VSzGidM
oA9NXDSz1r3RpzIuEuRH
=OvUh
-----END PGP SIGNATURE-----

--ik0NlRzMGhMnxrMX--

--===============0292480595452152103==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============0292480595452152103==--
