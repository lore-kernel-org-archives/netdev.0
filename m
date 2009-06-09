From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 19:19:50 +0200
Message-ID: <1244567990.18481.21.camel@johannes.local>
References: <1244556667.4672.18.camel@johannes.local>
	 <4A2E7376.4080407@trash.net> <1244558606.4672.25.camel@johannes.local>
	 <4A2E7929.9070705@trash.net> <1244567063.18481.13.camel@johannes.local>
	 <4A2E979F.9090407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-FBFlXZvxI1P8NZ7SHwm/"
Cc: netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60478 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbZFIRUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 13:20:21 -0400
In-Reply-To: <4A2E979F.9090407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FBFlXZvxI1P8NZ7SHwm/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-09 at 19:10 +0200, Patrick McHardy wrote:

> > ----- >% -----
> > @ ndomatch @
> > identifier ndo, sml;
> > @@
> > struct net_device_ops ndo =3D {
> > .ndo_set_multicast_list =3D sml,
> > };
> > @forall@
> > identifier dev;
> > identifier ndomatch.sml;
> > @@
> > void sml(struct net_device *dev)
>=20
> - void
> + int

Indeed.

> > {
> > ...
> > -return;
> > +return 0;
> > ...
> > }
> > ----- %< -----
> >=20
> > Haven't really tested it though but it seems to do the correct thing fo=
r
> > all drivers I looked at.
>=20
> In case this also adds a return statement at the end if none is
> there already, it looks fine.

Yes, it does. "All" that remains to be done then is to actually fix the
few users of dev_mc_sync(), and the callers, but that's the real work :)

johannes

--=-FBFlXZvxI1P8NZ7SHwm/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKLpmzAAoJEODzc/N7+QmaCLcQAIB5xt+UGlGLjbZ2MswchFgj
HPnSO9Y8yhqU0/ynhNydL20tIh8qv3pAtcbWJJzTQTMBzmu2W9C98lwYyrdhCuFc
fG6DOtbEEPTG8EPCtf8RwWyXRdQ1TyglsosI1X/EkQ6Iymmn69ZC/wUXxFwS8TpQ
pWW77pHtgeq+RZ5hLBzKCxwYOEA9eIXByV4JnPC0mw8oTFcwMF8lFjAhbu/b0PE4
FJeawi6JOnKE0MLeuBz0miSwqs4W/eEKurlmxAlQSRZBQLIWn4esQpSnuoM+dxBp
ICnyWFXOBqRNNscPSgxNgetkXgM1R+ht2EOM+yuXK0D6eKK/H/N0rFiNXcmynY9r
3nsE9yb+VgssnLzqpYrnCKt2SqfEI8c+whrft119fnCHnA7xj3PUzD+DSWj1Wz91
/6lxYzwo/TZjFl20Te7oAZ9bvXxVTVLCkgVSlQMK0Z3SJDov5Llamt4Sw/dD5UDd
cldrowlsr0gzOYH/+b0hJKabnnqO1I/oVph95MpV+73zFTW7nofzr9M1CnqWwIqb
JZghx7qG20/fEiQB/Ogs1c2MYAEI06Q1xeqnKAKRz00EfDnbAg2C83s++hK2Lemq
n7Xcwit3LCijy3C5XoP1BhtNk+YO9qn+2qkzaDHCfGOJOwF8uu77pfk+nIE7LUef
BQPxNuK+UG9MhITYxA4u
=uZ5c
-----END PGP SIGNATURE-----

--=-FBFlXZvxI1P8NZ7SHwm/--

