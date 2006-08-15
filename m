From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: ehea debug output discussion
Date: Tue, 15 Aug 2006 10:02:44 +1000
Message-ID: <1155600164.9047.11.camel@localhost.localdomain>
References: <44D99F38.8010306@de.ibm.com> <20060811215225.GH479@krispykreme>
	 <44DE03B0.1060607@de.ibm.com> <20060813144400.GJ479@krispykreme>
	 <44E06EDA.6040404@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-yClr3cLEzN91t/H7hx9k"
Cc: Anton Blanchard <anton@samba.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>, roland@topspin.com,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44717 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S965033AbWHOADb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 20:03:31 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <44E06EDA.6040404@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yClr3cLEzN91t/H7hx9k
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-08-14 at 14:38 +0200, Jan-Bernd Themann wrote:
> Hi
>=20
> Anton Blanchard wrote:
> > What is going to be done about the debug infrastructure in the ehea
> > driver? The entry and exit traces really need to go, and any other debu=
g
> > you think is important to users needs to go into debugfs or something
> > similar.
> >=20
> > I see a similar issue in the ehca driver that I am in the middle of
> > reviewing.
> >=20
> > Anton
>=20
> This is a statement for the eHEA driver:
>=20
> Most of the debug outputs are redundant and we'll remove them
> (EDEB_EN / EDEB_EX). We can use the standard mechanism for ethernet devic=
es
> (netif_msg_x) in most functions of ehea_main.c as we have the device stru=
ct
> as a parameter available. However, some debug output mechanism is needed
> where the standard mechanism does not work (functions that have no relati=
on
> to the dev struct do not have a dev parameter, for example
> ehea_hcall_9arg_9ret in ehea_phyp.h)
>=20
> The outcome of some internal discussions was that it is not acceptable fo=
r
> our enterprise users of this type of driver on this target system to need=
 a
> recompile / reload of the driver for error analysis, so we need a mechani=
sm
> that allows us to switch on / off debug output at runtime. Therefore, we'=
d
> introduce a stripped down version of EDEB.

Well, it might be better if the driver just worked, then your enterprise
users wouldn't need debugging output ;) ...

But if you think you need that facility then you should look at debugfs,
or relayfs, or just plain old printk, rather than implementing something
new.

cheers

--=20
Michael Ellerman
IBM OzLabs

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-yClr3cLEzN91t/H7hx9k
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBE4Q8kdSjSd0sB4dIRAq5MAKCLOruEjhdfQm+bvOonHv/LKd5DwgCffiWE
LoGSJb4WMSVAXKHYmWk9WMY=
=Ibex
-----END PGP SIGNATURE-----

--=-yClr3cLEzN91t/H7hx9k--

