From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/3] netlink: allocate group bitmaps dynamically
Date: Wed, 18 Jul 2007 15:34:13 +0200
Message-ID: <1184765653.3864.1.camel@johannes.berg>
References: <20070717122706.899784000@sipsolutions.net>
	 <20070717123642.918587000@sipsolutions.net>  <469CE431.9070705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-USWOSZoUISc6iZ2e0p7b"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46695 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbXGRPjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 11:39:24 -0400
In-Reply-To: <469CE431.9070705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-USWOSZoUISc6iZ2e0p7b
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-07-17 at 17:45 +0200, Patrick McHardy wrote:

> > --- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-17 14:05:30.2109=
64463 +0200
> > +++ wireless-dev/net/netlink/af_netlink.c	2007-07-17 14:05:30.720964463=
 +0200
> > -static int netlink_alloc_groups(struct sock *sk)
> > +static int netlink_realloc_groups(struct sock *sk)
> >  {
> >  	struct netlink_sock *nlk =3D nlk_sk(sk);
> >  	unsigned int groups;
> > +	unsigned long *new_groups;
> >  	int err =3D 0;
> > =20
> >  	netlink_lock_table();
>=20
>=20
> This is actually a bug in the current code I think, netlink_lock_table
> is a reader lock.

Looks like, changed to netlink_table_grab()


> > +int netlink_change_ngroups(int unit, unsigned int groups)
>=20
>=20
> I think it would be more consistent to pass the kernel socket
> instead of the unit.

Alright, changed. Also added kernel doc for the function.

> This might set the group to a value < 32. I don't expect it matters,
> but when I changed to old code to support > 32 groups I enforced
> a minimum of 32 so anything outside the kernel multicasting on them
> would still work (even though its a really stupid idea). So for
> consistency this should probably also use a minimum of 32.

Huh ok. Fixed, and added to documentation.

johannes

--=-USWOSZoUISc6iZ2e0p7b
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnhbV/ETPhpq3jKURAt5IAJ9TqTe2tIh5UjFSdKXL6AAUEQjgigCePCJS
jVRGi1MwLha4vB3IF3gXjt4=
=pVF5
-----END PGP SIGNATURE-----

--=-USWOSZoUISc6iZ2e0p7b--

