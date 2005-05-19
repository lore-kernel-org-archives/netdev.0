From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 11:06:25 +0400
Message-ID: <1116486385.21310.82.camel@uganda>
References: <20050518202458.55a63d37.akpm@osdl.org>
	 <E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
	 <20050518222729.007887b8.akpm@osdl.org> <1116484313.21310.78.camel@uganda>
	 <20050518234552.4aef6d02.akpm@osdl.org>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-eWbpboGa4GFliTliSj5n"
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050518234552.4aef6d02.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-eWbpboGa4GFliTliSj5n
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-05-18 at 23:45 -0700, Andrew Morton wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >
> > On Wed, 2005-05-18 at 22:27 -0700, Andrew Morton wrote:
> > > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > >
> > > > Andrew Morton <akpm@osdl.org> wrote:
> > > >  >=20
> > > >  > This is the second report of this happening.
> > > >  >=20
> > > >  > FATAL: Error inserting ipt_ULOG (/lib/modules/2.6.12-rc4-mm1-2/k=
ernel/net/ipv4/netfilter/ipt_ULOG.ko): Cannot allocate memory
> > >=20
> > > Ah yes, thanks.  netlink_kernel_create() has a dumbish return-value p=
rotocol.
> > >=20
> > > >  This probably means that someone has stolen the NETLINK_NFLOG id.
> > >=20
> > > cn_init() uses NETLINK_NFLOG.  Peculiar.
> >=20
> > Yep...
>=20
> Bah.
>=20
> > One may use "unit" module parameter to specify different socket.
>=20
> Is there any reason for being able to do that?

It was created to be able to load several different connector devices=20
from different modules [basically it was module1.ko unit=3D10, module2.ko
unit=3D11 and so on].

> > Should I ask David Miller to allocate new one specially for connector?
>=20
> Dave?
>=20
>=20
> diff -puN include/linux/netlink.h~connector-netlink-id-fix include/linux/=
netlink.h
> --- 25/include/linux/netlink.h~connector-netlink-id-fix	2005-05-18 23:44:=
43.000000000 -0700
> +++ 25-akpm/include/linux/netlink.h	2005-05-18 23:44:43.000000000 -0700
> @@ -14,6 +14,7 @@
>  #define NETLINK_SELINUX		7	/* SELinux event notifications */
>  #define NETLINK_ARPD		8
>  #define NETLINK_AUDIT		9	/* auditing */
> +#define NETLINK_CONNECTOR	10	/* kernel connector */
>  #define NETLINK_ROUTE6		11	/* af_inet6 route comm channel */
>  #define NETLINK_IP6_FW		13
>  #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
> diff -puN drivers/connector/connector.c~connector-netlink-id-fix drivers/=
connector/connector.c
> --- 25/drivers/connector/connector.c~connector-netlink-id-fix	2005-05-18 =
23:44:43.000000000 -0700
> +++ 25-akpm/drivers/connector/connector.c	2005-05-18 23:44:43.000000000 -=
0700
> @@ -33,7 +33,7 @@ MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
>  MODULE_DESCRIPTION("Generic userspace <-> kernelspace connector.");
> =20
> -static int unit =3D NETLINK_NFLOG;
> +static int unit =3D NETLINK_CONNECTOR;
>  static u32 cn_idx =3D CN_IDX_CONNECTOR;
>  static u32 cn_val =3D CN_VAL_CONNECTOR;
> =20
> _
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-eWbpboGa4GFliTliSj5n
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjDrxIKTPhE+8wY0RAl++AJ9fj9qV3rvl/n1q0/93XHGpi/iw8gCdHzxD
ESCobFeRKDOhICPHamwwru0=
=jLHB
-----END PGP SIGNATURE-----

--=-eWbpboGa4GFliTliSj5n--
