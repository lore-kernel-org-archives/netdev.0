From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v3] net: phy: fix uninitalized WOL parameters in
 phy_ethtool_get_wol
Date: Thu, 13 Mar 2014 02:21:45 +0000
Message-ID: <1394677305.20857.29.camel@deadeye.wl.decadent.org.uk>
References: <1394484661-4554-2-git-send-email-sebastian.hesselbarth@gmail.com>
	 <1394578975-12588-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cJ6XNnnryeEvTdHkSyDc"
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394578975-12588-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cJ6XNnnryeEvTdHkSyDc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 00:02 +0100, Sebastian Hesselbarth wrote:
> phy_ethtool_get_wol is a helper to get current WOL settings from
> a phy device. When using this helper on a PHY without .get_wol
> callback, struct ethtool_wolinfo is never set-up correctly and
> may contain misleading information about WOL status.
>=20
> To fix this, always zero relevant fields of struct ethtool_wolinfo
> regardless of .get_wol callback availability.

Sorry, I still disagree with this.

You're trying to make phy_ethtool_get_wol() do two subtly different
things:
- Provide an implementation of ethtool_ops::get_wol, leaving the net
  driver only to look up phy_device
- Provide a standalone function for executing ETHTOOL_GWOL on a
  phy_device

You may notice that phy_suspend() already sets wol.cmd =3D ETHTOOL_GWOL.
So it seems to me like it's taking responsibility for initialising the
structure like ethtool_get_wol() does.  The bug is then that
phy_suspend() doesn't clear the rest of the structure.  That is not the
responsibility of phy_ethtool_get_wol().

Ben.

> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changelog:
> v1->v2:
> - clear whole struct ethtool_wolinfo
> - check for non-NULL phy_device
> v2->v3:
> - only clear ->supported and ->wolopts (Suggested by Ben Hutchings)
>=20
> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/phy.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 19c9eca0ef26..94234a91a50f 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1092,7 +1092,9 @@ EXPORT_SYMBOL(phy_ethtool_set_wol);
> =20
>  void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolin=
fo *wol)
>  {
> -	if (phydev->drv->get_wol)
> +	wol->supported =3D wol->wolopts =3D 0;
> +
> +	if (phydev && phydev->drv->get_wol)
>  		phydev->drv->get_wol(phydev, wol);
>  }
>  EXPORT_SYMBOL(phy_ethtool_get_wol);

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-cJ6XNnnryeEvTdHkSyDc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyEWOee/yOyVhhEJAQoQtxAAnaZ6iZcw/qt6LK/r9YoH89oFKHmBFsSO
k/4qX4TuYvoPgLgipZXLZj6HH0PlZIFA3bo/E9wkIhxb9VDtulsHnjcI6PLOwnA5
+SxuO/Wquv3bcZaPVzHiqoM11bmxJP3EuSEU8GPYrgf43e1qifEetHFRvdBiZSNW
Sk8fBzv0sWqru+wpfZr/vFe8veU4I1eucBfgiiKhMFbMxMw7gIEmd2w/r2VV3HEG
/L5ljIoTEvuYJ2ajjbGSsag4C6DayHlce+CM7MYAOyWdj0onktFiBsHvYaFAbX0j
zfXLPQFWJdn4K7D0GCGn3am/Lqm36hchJQkZe7FCuYWhKRtIMcgGuCX9uVUygeri
W+hpkc3G4pO24CczmspUIy4S5RCRNc3bKZxejYRpu2F9zBgdLK4M/bgOWUdQOcBa
2GfkARIvH27z/J4BzV9NgKtrpwqnzO7fQ/GN3lU/sVIvbfgd+ydoD5N2fd/JvySI
PROMJaZgmF+1uLE9ICNUglbdC7cJXo/yHOjp7ALIPQmjLd+kAxpApk//oIQYBwl9
U7ClZ1ribbmJo5Zk2Tq7HKUdnPILpWOcKxBVNJ2ceQ0cREepS1RTLTqqqqFbGxlD
/R9DpPZv/J4DtMYqsAhTfxrdDP6qX+EYq4fJe2AGb4BFrTGo2RTEo85TP7Y5ZJqf
zz3O/+NKR3Y=
=gFGA
-----END PGP SIGNATURE-----

--=-cJ6XNnnryeEvTdHkSyDc--
