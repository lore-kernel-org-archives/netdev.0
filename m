From: David Gibson <dgibson@redhat.com>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Wed, 23 Apr 2014 11:12:03 +1000
Message-ID: <20140423111203.3e8cf3a9a12acb1d95b3635a@redhat.com>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
	<1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
	<20140422.141200.1878796491205301689.davem@davemloft.net>
	<20140423092606.c73425b64d127b8f94469fcb@redhat.com>
	<20140422170438.00006b45@unknown>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__23_Apr_2014_11_12_03_+1000_9X=4Bdc0H+1DyM5y"
Cc: David Miller <davem@davemloft.net>, <ben@decadent.org.uk>,
	<netdev@vger.kernel.org>, <benve@cisco.com>, <ssujith@cisco.com>,
	<govindarajulu90@gmail.com>, <neepatel@cisco.com>,
	<nistrive@cisco.com>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485AbaDWBMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 21:12:33 -0400
In-Reply-To: <20140422170438.00006b45@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__23_Apr_2014_11_12_03_+1000_9X=4Bdc0H+1DyM5y
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Apr 2014 17:04:38 -0700
Greg Rose <gregory.v.rose@intel.com> wrote:

> On Wed, 23 Apr 2014 09:26:06 +1000
> David Gibson <dgibson@redhat.com> wrote:
>=20
> > On Tue, 22 Apr 2014 14:12:00 -0400 (EDT)
> > David Miller <davem@davemloft.net> wrote:
> >=20
> > > From: Ben Hutchings <ben@decadent.org.uk>
> > > Date: Tue, 22 Apr 2014 19:03:19 +0100
> > >=20
> > > > On Tue, 2014-04-22 at 14:14 +1000, David Gibson wrote:
> > > >> I believe I've found a problem with netlink handling which can be
> > > >> triggered on Cisco enic devices with a large number (30-40) of
> > > >> virtual functions.  I believe this is the cause of a real
> > > >> customer problem we've seen.
> > > >>=20
> > > >>  * When requesting a list of interfaces with RTM_GETLINK, enic
> > > >> devices (and currently, _only_ enic devices) report IFLA_VF_PORTS
> > > >>    information=20
> > > >>=20
> > > >>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual
> > > >> function
> > > >>=20
> > > >>  * Unlike IFLA_VFINFO_LIST, the ports information is always
> > > >> reported, regardless of the setting of the IFLA_EXT_MASK
> > > >> parameter
> > > > [...]
> > > >=20
> > > > So I think you should make reporting of IFLA_VF_PORTS dependent
> > > > on the same flag as IFLA_VFINFO_LIST.
> > >=20
> > > I think that's what we'll have to do.
> >=20
> > Ok, makes logical sense.
> >=20
> > But does anyone know what tools make use of the IFLA_VF_PORTS
> > information?  Do they set the IFLA_EXT_MASK already?
> >=20
>=20
> So far as I know only the IP route tool 'ip link' sets that.  In fact,
> that's the reason I had to add it some number of years and months ago
> was because there were tools that didn't expect to get all the
> additional VF info and those tools were getting borked by all the
> additional goo sent up for VFs.
>=20
> Beyond that who knows what anyone's been up to with other tools in
> other places?

And therein lies the problem.  I don't even know what the IFLA_VF_PORTS
info is for, but presumably something uses it.  If they stop receiving
it, they can be expected to break horribly.

--=20
David Gibson <dgibson@redhat.com>

--Signature=_Wed__23_Apr_2014_11_12_03_+1000_9X=4Bdc0H+1DyM5y
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVxNjAAoJEGw4ysog2bOSGjEQAIQUmkN9nlbZ8IHyA+m2U328
3Lj6nd5X7xmtgF/jKz4R1xKKCHSesUaBzL1QMP7zRarwcJTLVH5+eK4xTD+3sLKt
D20K0HQ3Dizhoyw/CE/bRgQ4HCuCqpTl/PdntAoV84Uskyo9aMaUI0pyNCx8oslm
PfxkoauIWw4Vbge9tAGHpa1s4ICyTyHruzmd+losf+u5HoSNx3H6mOke/HU3BnUg
qYhDNwLcwr5Svn9LRDmC/CgXDUvC43/k5Gz4qao6+aEJRawUzda6H0WquH8J2vfz
b+5GZ+dIXKSCDeA7C3R7yu8mrLhAtkJv0cRp4+rn+H8em7vcB32QDxqeJWW6Cjp3
j+VjYaZNJnf/9VL1m9gZ7PC+kgxCR+vq03rux+HHZspr4wW1fhsT3lBq/fQesw99
7wxLv74gF/Ug5pknX3Q4Cp66e0qrxxKsvr86U2hqNPMTP+eLCAVZxokFuAPGCP/h
3e3iVVpF5uOi5V3IPgb2BCBuvF6SGCAPiu+FMsYHG+XNPacVCQcX/rpQX8YuHvhk
X37/YQxZM/Yz8fkNTJL4/y8z3uXi44sZBtntH1tgYJ3bOcpdIamQQz9oew36pSw2
XIS773U4rXO9xEIE531imuKlx/TVfU7lINN6BjAbg7P3pt1YC6qw8dOVCeJzItQH
eDwLGmFyPSThLGzCDVUk
=r8fD
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Apr_2014_11_12_03_+1000_9X=4Bdc0H+1DyM5y--
