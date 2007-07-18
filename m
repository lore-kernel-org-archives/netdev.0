From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 2/3] netlink: allow removing multicast groups
Date: Wed, 18 Jul 2007 15:35:24 +0200
Message-ID: <1184765724.3864.4.camel@johannes.berg>
References: <20070717122706.899784000@sipsolutions.net>
	 <20070717123643.626951000@sipsolutions.net>  <469CE541.9090708@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-f0ekEmJzDZJ6J6GRWHWk"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60767 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbXGRPkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 11:40:24 -0400
In-Reply-To: <469CE541.9090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-f0ekEmJzDZJ6J6GRWHWk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-07-17 at 17:50 +0200, Patrick McHardy wrote:

> Having the caller lock the table would save lots of atomic operation
> in case of netlink_clear_multicast_users.

Good point.

> > +void netlink_clear_multicast_users(int unit, unsigned int group)
>=20
> Same as in the last patch, passing the kernel socket would be nicer IMO.

Changed.

> > +	read_lock(&nl_table_lock);
>=20
> Won't this deadlock? netlink_table_grab takes a write-lock.

I guess it's valid to update a read lock to a write lock? Or I was just
lucky on UP. But moving the lock out of netlink_clear_multicast_users()
made this obvious and I just use the write lock now.

johannes

--=-f0ekEmJzDZJ6J6GRWHWk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnhcc/ETPhpq3jKURAj2TAJ9KJYrRU78CpFSGlZ8BpHJaZ4NLSACeIewJ
+fxkfP5RrJB0+xVbe0p03zw=
=wr73
-----END PGP SIGNATURE-----

--=-f0ekEmJzDZJ6J6GRWHWk--

