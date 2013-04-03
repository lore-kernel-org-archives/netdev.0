From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 3 Apr 2013 17:27:47 +0300
Message-ID: <20130403142747.GK14680@arwen.pp.htv.fi>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-2-git-send-email-kishon@ti.com>
 <20130403134102.GC14680@arwen.pp.htv.fi> <515C3A42.4020404@ti.com>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5242841677062336475=="
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
In-Reply-To: <515C3A42.4020404-l0cyMroinI0@public.gmane.org>
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

--===============5242841677062336475==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yaap9KN+GmBP785v"
Content-Disposition: inline

--yaap9KN+GmBP785v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hi,

On Wed, Apr 03, 2013 at 07:48:42PM +0530, Kishon Vijay Abraham I wrote:
> >>+struct phy *of_phy_xlate(struct phy *phy, struct of_phandle_args *args)
> >>+{
> >>+	return phy;
> >>+}
> >>+EXPORT_SYMBOL_GPL(of_phy_xlate);
> >
> >so you get a PHY and just return it ? What gives ?? (maybe I skipped
> >some of the discussion...)
>=20
> hmm.. this is for the common case where the PHY provider implements
> only one PHY. And both phy provider and phy_instance is represented
> by struct phy *.
>=20
> For the case where PHY provider implements multiple PHYs (here it
> will have a single dt node), the PHY provider will implement it's own
> version of of_xlate that takes *of_phandle_args* as argument and
> finds the appropriate PHY.

got it.

> >>+struct phy *of_phy_get(struct device *dev, int index)
> >>+{
> >>+	int ret;
> >>+	struct phy *phy =3D NULL;
> >>+	struct phy_bind *phy_map =3D NULL;
> >>+	struct of_phandle_args args;
> >>+	struct device_node *node;
> >>+
> >>+	if (!dev->of_node) {
> >>+		dev_dbg(dev, "device does not have a device node entry\n");
> >>+		return ERR_PTR(-EINVAL);
> >>+	}
> >>+
> >>+	ret =3D of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
> >>+		index, &args);
> >>+	if (ret) {
> >>+		dev_dbg(dev, "failed to get phy in %s node\n",
> >>+			dev->of_node->full_name);
> >>+		return ERR_PTR(-ENODEV);
> >>+	}
> >>+
> >>+	phy =3D of_phy_lookup(args.np);
> >>+	if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
> >>+		phy =3D ERR_PTR(-EPROBE_DEFER);
> >>+		goto err0;
> >>+	}
> >>+
> >>+	phy =3D phy->ops->of_xlate(phy, &args);
> >
> >alright, so of_xlate() is optional, am I right ? How about not
>=20
> Not really. of_xlate is mandatory (it's even checked in phy_create).
> Either the PHY provider can implement it's own version or use the
> implementation above (by filling the function pointer).

alright.

> >implementing the above and have a check for of_xlate() being a valid
> >pointer here ?
>=20
> Having the way it is actually mandates the PHY providers to always
> provide of_xlate which IMO is better since some PHY providers wont
> accidentally be using the default implementation.

ok cool, thanks for clarifying.

> >>+		ret =3D -EINVAL;
> >>+		goto err0;
> >>+	}
> >>+
> >>+	if (!phy_class)
> >>+		phy_core_init();
> >
> >why don't you setup the class on module_init ? Then this would be a
> >terrible error condition here :-)
>=20
> This is for the case where the PHY driver gets loaded before the PHY
> framework. I could have returned EPROBE_DEFER here instead I thought
> will have it this way.

looks a bit weird IMO. Is it really possible for PHY to load before ?
Since PHY driver uses symbols from phy-core, modprobe will make sure to
load drivers based on symbol dependency, right ?

> >>+static struct device_attribute phy_dev_attrs[] =3D {
> >>+	__ATTR(label, 0444, phy_name_show, NULL),
> >>+	__ATTR(phy_bind, 0444, phy_bind_show, NULL),
> >
> >you could expose a human-readable 'type' string. BTW, how are you using
> >type ? USB2/USB3/etc ? Have you considered our OMAP5 SerDes pair which
>=20
> Actually not using *type* anywhere. Just used as an additional info
> about the PHY. It's actually not even enum. Maybe I can remove it
> completely.

makes sense.

> >are currently for USB3 and SATA (and could just as easily be used for
> >PCIe)
>=20
> Yeah. Me and Balaji were planning to work on it for having a single
> driver to be used for all the above.

cool :-)

--=20
balbi

--yaap9KN+GmBP785v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRXDxjAAoJEIaOsuA1yqREe80P/0zFgPrzX57SaCJoou/74kDJ
ErH5DVJqRLPYtHXxqBZXwgKNgEw5k76c/BzrpLn+dxlVa56OQwm/VMEFWE7xy7nQ
YTCnu3LOhCZP/GO52AJMm3edqwjhczbQ47tibM8wBiQ9fKF2BsAmF3dYLi8U9ib9
Fc41I0uYabY2aqV5KK/5QRHWE7aKJ4V3OASeQfxEhqnCkp/qCcVK5sa25UpEmsAh
lLWly8ZkGz4sc0Z+QGKBDvPa4vJAQuDlzRkPlrGv7StN66ZF5nHeLgtMK3xmZGpK
sas3fifFBWQH2/G0v9mea9BTogHfxm9LL1HXnIpjrTcI+bCMTl+iCbmtQqQlk3QW
gVThXBqmK2qY6J9IeumCj2zB279myKv9G8xWrW6Hhu3TurbMXep40urflZ4lpIJQ
o+ISMNEOWFXf67Zwm11AUgo4pjsPYfsczgwYOgdGSQJgjG7tESeVT0rebhXRZCe9
ReRIbXpb8i4uwSL/N8+7XcKk+aib+FGHgkT2ZT1y7k1eE1RwoOe+UTgri0PGvPgJ
e9d/c7qQS7NLR8KE/wjUVwXV5XNIYR5objy9AwqfxmmX80HzwcPeFztRjMy3P6Ma
wOrT7vpKrbzJFC/e03E8Z18qcJ+WSvErtsY7NjtSWxaBNg9zQGlf+YUIOGW+zf26
FGXxlNO7N9EPdiHScCkX
=YH90
-----END PGP SIGNATURE-----

--yaap9KN+GmBP785v--

--===============5242841677062336475==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============5242841677062336475==--
