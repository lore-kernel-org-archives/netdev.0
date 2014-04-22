From: David Gibson <dgibson@redhat.com>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Wed, 23 Apr 2014 09:26:06 +1000
Message-ID: <20140423092606.c73425b64d127b8f94469fcb@redhat.com>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
	<1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
	<20140422.141200.1878796491205301689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__23_Apr_2014_09_26_06_+1000_fiRg+AmX=aez_wGQ"
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, benve@cisco.com,
	ssujith@cisco.com, govindarajulu90@gmail.com, neepatel@cisco.com,
	nistrive@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbaDVX00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 19:26:26 -0400
In-Reply-To: <20140422.141200.1878796491205301689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__23_Apr_2014_09_26_06_+1000_fiRg+AmX=aez_wGQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Apr 2014 14:12:00 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 22 Apr 2014 19:03:19 +0100
>=20
> > On Tue, 2014-04-22 at 14:14 +1000, David Gibson wrote:
> >> I believe I've found a problem with netlink handling which can be
> >> triggered on Cisco enic devices with a large number (30-40) of virtual
> >> functions.  I believe this is the cause of a real customer problem
> >> we've seen.
> >>=20
> >>  * When requesting a list of interfaces with RTM_GETLINK, enic devices
> >>    (and currently, _only_ enic devices) report IFLA_VF_PORTS
> >>    information=20
> >>=20
> >>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual function
> >>=20
> >>  * Unlike IFLA_VFINFO_LIST, the ports information is always reported,
> >>    regardless of the setting of the IFLA_EXT_MASK parameter
> > [...]
> >=20
> > So I think you should make reporting of IFLA_VF_PORTS dependent on the
> > same flag as IFLA_VFINFO_LIST.
>=20
> I think that's what we'll have to do.

Ok, makes logical sense.

But does anyone know what tools make use of the IFLA_VF_PORTS
information?  Do they set the IFLA_EXT_MASK already?

--=20
David Gibson <dgibson@redhat.com>

--Signature=_Wed__23_Apr_2014_09_26_06_+1000_fiRg+AmX=aez_wGQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVvqOAAoJEGw4ysog2bOSd9wP/2aWgW4ORf/TSR3eqG2++CHl
l226qvSL/FidiXbzZ0wSu5voUuKN2Bah0w6twqBuFGvQrtfQ6ROVzV6ziGtkQ/rw
VP1zF8SrFr3vbiLeuTHl3AoylsD5iaHPsC+5oZuKf6EUbLv7zWIIzZ0ShOPWaEhH
OVYMc/HlKxVspp/z6Ft0hoGF2Yn/r1G7k5z4qRQU/W1XqcAay+zIoW8TULnoy9qT
CxExGG2pRtJsbOieMMJkbBdPHrCsmULNjMf4KFPHcVjv9J1I8SKJ4FvUDbIAKfXm
iBU5bogGE4v9NJOGrT2sIV9quy8cy2oebg44HdrPzEqnJkCDYxUX9bPeKhAZ1Q51
97O6RicDjEyBuzmu8pxZ34uj72IyA/qgo5vqMyc3ZkbiPD+dW3a+CyJUUv/3Ct4X
lIGycSK9m9th5CHKC+YNojYNrvT2SvhrNSAFu730aM+NPQ6JGJNsu+m0O67/ojbi
m8kuzeXiSxE8SzkU/toH2BT/i7VXNh4ToQgHhZMpduYydOyIFa50Hat70hhyiDWE
rZTkX2y/xaNNSwbyYuyvOAoNscHOOEV1OO0mf9Nh1+4CJ/+ACS87PVjqJNgcRk3s
3B92z4Big/0UhLWFE6MHbpCQEAeYVkOKHL6MM+OCT63Nk36emeR/X2viFfxKUQpu
msFelYB4g5/swJ91odnv
=wble
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Apr_2014_09_26_06_+1000_fiRg+AmX=aez_wGQ--
