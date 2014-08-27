From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 2/3] ethtool: Add generic options for
 tunables
Date: Tue, 26 Aug 2014 23:59:24 -0700
Message-ID: <1409122764.30127.26.camel@deadeye.wl.decadent.org.uk>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
	  <1408008560-1067-3-git-send-email-_govind@gmx.com>
	 <1408749965.4672.29.camel@deadeye.wl.decadent.org.uk>
	 <alpine.LNX.2.03.1408270247280.28873@ws.cisco>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AiwMgG9mc1MW960+fcto"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, ssujith@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33645 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750842AbaH0G7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:59:35 -0400
In-Reply-To: <alpine.LNX.2.03.1408270247280.28873@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AiwMgG9mc1MW960+fcto
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-08-27 at 03:03 +0530, Govindarajulu Varadarajan wrote:
> On Fri, 22 Aug 2014, Ben Hutchings wrote:
> > On Thu, 2014-08-14 at 14:59 +0530, Govindarajulu Varadarajan wrote:
> >> @@ -257,6 +262,7 @@ struct ethtool_ops {
> >>  				     struct ethtool_eeprom *, u8 *);
> >>  	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
> >>  	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
> >> +	struct ethtool_tunable_ops tunable_ops[ETHTOOL_TUNABLE_MAX];
> >
> > This is OK but if we add a lot of tunables then it bloats up each drive=
r
> > with a (probably quite sparse) array of function pointers.
> >
>=20
> Will fix with David's suggestion.
>=20
> >> +struct ethtool_tunable {
> >> +	u32 cmd;
> >> +	u32 tcmd;
> >> +	u32 len;
> >> +	union {
> >> +		u32 rx_copybreak;
> >> +		u32 data[48];
> >> +	} data;
> > [...]
> >
> > This is not at all generic.  If tunables don't all have the same type,
> > then the type - not just the length - should be explicit.
> >
> > I also think that if the length of a value can vary then we should not
> > declare a data member at all.  So we would have something like:
> >
> > struct ethtool_tunable {
> > 	__u32	cmd;
> > 	__u32	id;
> > 	__u32	type_id;
> > 	__u32	len;
> > 	__u8	data[0];
> > };
> >
> > Then the value buffer would be passed to the driver functions separatel=
y
> > (as for other variable-length command structures).
> >
>=20
> OK. id show be the tunable command type right? Like RX_COPYBREAK, TX_COPY=
BREAK
> etc. What is the type_id?

A number that identifies the type of the tunable (it might be u32, u64,
link-layer address, text, etc.).

Ben.

> > By the way, you must use double-underscore prefixes on fixed-width
> > integer type names in UAPI headers.
> >
>=20
> will fix it.
>=20
> Thanks

--=20
Ben Hutchings
No political challenge can be met by shopping. - George Monbiot

--=-AiwMgG9mc1MW960+fcto
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU/2BzOe/yOyVhhEJAQphghAAlxw4vCvHT7odohwVg5a1LfiAjbSMe8TV
QtlkKU14dx4pQKkLUvtVleRhN2sIuV1e5WbLsuR1Z80qX3OVPBVMrSFeLVxSADIS
4SJbBnmIdHGM6C4UeoEJ3yKibDK8mF60eWZJw4Fem04H1rkLV52J0I76V561NJXs
JsYgrJ5ibe5JtaL83tZ7/8qh8QP/+1shjmiHh8328jzM7dYfN4ECNEQH5R6COKsg
vfY6IOtz182p/cG8ERI6oWERIqCy2CWkN4Jd78OpU5wO+/ueEdonXfAii3a9AH/a
EE/trwg54K3QGPQ042w2DmtkrVn+rb5C3eIuUQ/4x4joBZmb/CKB8+9Zcb2w6UlU
54dCjT23fX1EyKLlvQsvSCogdgKTmrVpveMKdFKgGH5VDDI2oQYSb1kZRyrMeHjt
QsSMlyXkelv3KxRloNg3lwUnIivni1G2dNAhZYQlrMUuxPQDr98ku97syOh82qug
rfmcTZlgzdYsyqC0tto9iEp8+kpKYoqdlHcEKKguRJ6ZpQQaimy/9cTVCtdTjl7I
3u46farArEyShbz2y7n9hLpANWrBwLKOwifstigbLBiS7enwQnc6pXEBs8pIm3DF
aN1JfdggbjdDALARn6h7PS8nAbdE+AqdRrI6nQOngLLquqq5bRjeaX7ilokdmheZ
XZ9n1/fqhyQ=
=oePp
-----END PGP SIGNATURE-----

--=-AiwMgG9mc1MW960+fcto--
