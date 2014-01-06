From: Thomas Haller <thaller@redhat.com>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Mon, 06 Jan 2014 16:41:49 +0100
Message-ID: <1389022909.23397.4.camel@weing>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
	 <20140102172949.GF22494@order.stressinduktion.org>
	 <20140104104331.GB9295@minipsycho.orion>
	 <20140104105515.GA25828@order.stressinduktion.org>
	 <20140104110557.GD9295@minipsycho.orion>
	 <20140104111546.GB25828@order.stressinduktion.org>
	 <1388834511.7407.5.camel@weing>
	 <20140104113543.GC25828@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Rf3zEAKNNfaHopbGed8r"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755218AbaAFPmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 10:42:05 -0500
In-Reply-To: <20140104113543.GC25828@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Rf3zEAKNNfaHopbGed8r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-01-04 at 12:35 +0100, Hannes Frederic Sowa wrote:
> On Sat, Jan 04, 2014 at 12:21:51PM +0100, Thomas Haller wrote:
> > > > >Also, I saw that NetworkManager switched to install autoconf addre=
sses
> > > > >as /128, doesn't this break with IFA_F_MANAGETEMPADDR, as you expe=
ct a /64
> > > > >prefixlen?
> > > >=20
> > > > /64 is required
> > >=20
> > > Ok, currently NM seems to "violate" that as it installs autoconf addr=
esses
> > > with 128 prefixlen, so IFA_F_MANAGETEMPADDR should not work on them.
> > > (currently observed on Fedora 20).
> >=20
> > True, I noticed that too. I think that is a bug in NM to add the
> > addresses as /128. Probably, we will fix that soon.
>=20
> The change could be valid. Otherwise currently NM could not correctly han=
dle
> prefix information in RAs in some cases:
>=20
> It is possible to let the client generate an autonomously address in a
> prefix which is actually not on-link (L=3D0). Kernel would automatically
> create prefix route by mistake, if NM tries to install such an address
> with /64 prefix. This does not happen if the prefix address uses 128
> prefixlen.
>=20
> Would be great to have feedback on this, as this could be easily solved b=
y an
> additional ifa_flag.
>=20
> Greetings,
>=20
>   Hannes
>=20


Hi Hannes,


good point. I think, the user-space application (NetworkManager) should
add the autoconf addresses as /64. But the kernel should not generate
any routes in that case. It's up to the application to add them
(depending on the on-link flag).


What do you think about something like:



diff --git i/net/ipv6/addrconf.c w/net/ipv6/addrconf.c
index 6c16345..5a4c382 100644
--- i/net/ipv6/addrconf.c
+++ w/net/ipv6/addrconf.c
@@ -2433,8 +2433,11 @@ static int inet6_addr_add(struct net *net, int ifind=
ex,
 			    valid_lft, prefered_lft);
=20
 	if (!IS_ERR(ifp)) {
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
-				      expires, flags);
+		if (ifa_flags & IFA_F_MANAGETEMPADDR =3D=3D 0) {
+			addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
+					      expires, flags);
+		}
+
 		/*
 		 * Note that section 3.1 of RFC 4429 indicates
 		 * that the Optimistic flag should not be set for


--=-Rf3zEAKNNfaHopbGed8r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJSys69AAoJECnCNm5N/Fco3poP/ixyg4Zjbz04g6sjPDJldSOf
GXOysDA+jTKQHExhmhm7lB+Nd9TRnYTLadyq1vCKW7m9X89EkX77DXPl4dFaEsdc
nAiTqpqNYAe+EaYQndAeILYWtPXmHFZRARB25jtSiW2y7kk9Y0GN5UTwnGsoCP6c
VwyzVs4LYcQbcZO0f1hmbi86y+IZh1FJAQemZgnW+IrBBWHerpANu122CCZdcueW
xiT+vozIYFIXokWEf02JekVmuZQyjMyOcoHihQoSYJpD+4t2XVZDY+bNqHGIS27y
ACEru23wd1cx0I3sOTHJR1fd9t9tXnGjVfV7ttrVNd1I9BW0lTZMpUuUk80q3dWN
MqBPjfEn9OiFR3FSGrOotE1mJxh35kgHj6CdgxKzLHIt7erb2KlMW/v7m/KHJR8b
9mac7Jke97Tu6Ra1jjNeEm823PJiGhCF+PFjreesM38N4JOOvl14FSkNw50B2546
9l4sfQMCc7R+/Sugu8SqFvlZoquo3kI7C+xuiXfOnpzrNAXlVt4A0BpbC30EUdUT
rJMLKSTs8jR31NZuuvouowdFfFTRlEn227RSPRTAFsNKieqG7ToKIhD+hox6wqOx
uppvYEMiAmUB95VLYRQW2bcgCEDTA+g7QKBVXeHf+wH48CEgu+K6FCAegYY8nGmW
JcfJ4W1LUqd0YzdJ3p8z
=9KJq
-----END PGP SIGNATURE-----

--=-Rf3zEAKNNfaHopbGed8r--
