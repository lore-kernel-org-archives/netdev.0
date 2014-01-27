From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on
 attached PHY
Date: Mon, 27 Jan 2014 10:18:24 +0000
Message-ID: <1390817904.2735.127.camel@deadeye.wl.decadent.org.uk>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
	 <1390795167-6677-2-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tXMGAH4+qIyy6f7SGZ8a"
Cc: linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>,
	Marc Gauthier <marc-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
To: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390795167-6677-2-git-send-email-jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-tXMGAH4+qIyy6f7SGZ8a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 07:59 +0400, Max Filippov wrote:
> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but doe=
s
> not disable advertisement when PHY supports them. This results in
> non-functioning network when the MAC is connected to a gigabit PHY connec=
ted
> to a gigabit switch.
>=20
> The fix is to disable gigabit speed advertisement on attached PHY
> unconditionally.
>=20
> Signed-off-by: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/ethoc.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 4de8cfd..0aa1a05 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -712,6 +712,8 @@ static int ethoc_open(struct net_device *dev)
>  		netif_start_queue(dev);
>  	}
> =20
> +	priv->phy->advertising &=3D ~(ADVERTISED_1000baseT_Full |
> +				    ADVERTISED_1000baseT_Half);
>  	phy_start(priv->phy);
>  	napi_enable(&priv->napi);
> =20

This is not sufficient to disable gigabit speeds; the supported mask
should also be limited.  And it should be done even before the net
device is registered.

Rather than poking into the phy_device structure directly from this
driver, I think you should add a function in phylib for this purpose.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-tXMGAH4+qIyy6f7SGZ8a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuYycOe/yOyVhhEJAQp34Q//TPzwP4h/FhMmDjv9CRo03LRIzf5+qMZ1
rkGc83qDljET4urKIkNrFkDKpx/v5lDdfpvdzsx5uWIe03dT6v+UerF9AoALqVYG
dg3dJ4sDq1FPAkh+umLXUQt9P5K1i0d8HVw/m3mLXuadUuZgMdrUt3aIXFYADVES
ZpskHcc/egMXmnkbBtn/JwLeO97OZDEsPWkLOkuEclP+E7N6ME/OxVz4H5XvWJrK
YSmd29WnfYURwqjTETTp9fpAToTJZGG8glt1ffrh3AZvmuEnQDkYbbL0rrFSteYB
I0qmlY8ZEb5XlsWe9kT87Ohp4SpwKAnZD3kv3ItOGWucuMBIyvsdkW7rJcQudH72
dtffrLIUgFT30LUHK7/11R+cZNffWlUachCfJpz+nZjMDqVnvzyvKnxzjiHHOP8s
YPvg0Jj+fMXdDdmNETmsgGpjjGlwlhXjGAlxVjVdvqdTaDaIZuHLrmB6pdcpuMoV
ST6+UilrC8ZhGyqpZ3ZOqdl9w41yhGVMlPUcXtaliM0wXgnG65PM3xK/iXBoMSdP
mvP4XX37HDB/1++Ba9WoxgN9UhMxXcKFS5Cql/ClcCknAd3Q15x8SSBQjHjE+Y6E
CdIr/Z3x/2gKqtNsonaaXtqUdkpe0dhXBuSBWXhdTYIyLxn9J6RlAWd40elDH7aJ
dXJSG6sQplg=
=n2kR
-----END PGP SIGNATURE-----

--=-tXMGAH4+qIyy6f7SGZ8a--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
