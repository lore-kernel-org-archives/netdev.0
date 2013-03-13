From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Fix null pointer dereference
Date: Wed, 13 Mar 2013 00:51:18 -0700
Message-ID: <1363161078.2099.16.camel@jtkirshe-mobl>
References: <20130312200833.17121.47670.stgit@bling.home>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GRjXyY2zM4ZAbUfQB3eM"
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	ddutile@redhat.com, linux-kernel@vger.kernel.org,
	sassmann@redhat.com
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130312200833.17121.47670.stgit@bling.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GRjXyY2zM4ZAbUfQB3eM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-03-12 at 14:09 -0600, Alex Williamson wrote:
> The max_vfs=3D option has always been self limiting to the number of VFs
> supported by the device.  fa44f2f1 added SR-IOV configuration via
> sysfs, but in the process broke this self correction factor.  The
> failing path is:
>=20
> igb_probe
>   igb_sw_init
>     if (max_vfs > 7) {
>         adapter->vfs_allocated_count =3D 7;
>     ...
>     igb_probe_vfs
>     igb_enable_sriov(, max_vfs)
>       if (num_vfs > 7) {
>         err =3D -EPERM;
>         ...
>=20
> This leaves vfs_allocated_count =3D 7 and vf_data =3D NULL, so we bomb ou=
t
> when igb_probe finally calls igb_reset.  It seems like a really bad
> idea, and somewhat pointless, to set vfs_allocated_count separate from
> vf_data, but limiting max_vfs is enough to avoid the null pointer.
>=20
> Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)=20

I have added the patch to my igb queue, thanks!

--=-GRjXyY2zM4ZAbUfQB3eM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRQC/2AAoJEOVv75VaS+3OXSEP/Ri6NKTEVCBI7WG8ZsQkHAQL
GTMW2cqDSn74udAVD+KpiVwwYcLhVtAQXkjp4Uh8BoKvpDUJY08Mq354dSuqgY9p
JhaMCs9dlvhDJl6qf0o/A2f+zzIkhFbpq8j2qPJzYICkOnq+WPNROABLKMM8CaNk
pLYkDJELBd/Y+QymXApkkEIolngB2uCZxcFKDOJlzKx4KIyY87ATKpllsn21187G
HOiCU/kzWqfRIqwm/paO8LumT/bv+wlrY9U+cViu3tEtmh3K+XL2PYqxakcNG6ds
FhIqtnzTFhtQqA8PUI6OSjU6ccVap/Pd5eA6Ec4Oh/C22/zXuIjHJ0HfmSQsGtJX
xR7yYg3Nb0VJ9lxeQ94KmSxP9krx7GK48WMrFpvWHrb9nxNi/en0xCpnqO/fmEUn
O6Ybqzk1jUVMEISoUj95k1K8Ls8KrUmkWAB8IQa1y/q6bByfRWNTue5XUJ3gDKHy
qGooI36j8CBvQWxydaJuuXprHSHpPaXWMP6jFzhum2Bdu+qKchfXNxTGVPz8bh//
/Ko20L2zENoqp2w4o3vmGneoFXKFy86j9l7e5G9jyW9Dho0VS/EZEndQ3yKG/WNe
s6wTf8KhjBYNcdy07oacCEez0uUoSl6pUd1Xh+3AMHGSB+JMnNWdLoY9YbBCC6zn
wEg70oKcd5lvk0rRGAfb
=+NfL
-----END PGP SIGNATURE-----

--=-GRjXyY2zM4ZAbUfQB3eM--
