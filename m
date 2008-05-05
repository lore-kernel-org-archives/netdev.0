From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
	destructor
Date: Mon, 05 May 2008 09:31:15 +0200
Message-ID: <1209972675.3655.15.camel@johannes.berg>
References: <1209925940.3655.17.camel@johannes.berg>
	 <20080505.002006.225975612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UrBxpDdnlKfckj0vnXxR"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58650 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbYEEHbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 03:31:23 -0400
In-Reply-To: <20080505.002006.225975612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UrBxpDdnlKfckj0vnXxR
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 00:20 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Sun, 04 May 2008 20:32:20 +0200
>=20
> > This makes the networking layer warn when something tries to
> > charge an skb to a socket that already is charged to another
> > socket (or has a destructor from somewhere else.)
> >=20
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
>=20
> I completely agree that this a correct assertion, that
> absolutely should never happen in the current tree.
>=20
> But if we are going to do this, I'm pretty sure we'll
> need to uninline these two routines.
>=20
> I'll leave it up to you, if you think it's still worthwhile
> with the uninlining, please resubmit :-)

Given that it's a corner case and no regular net drivers would ever want
to do something that could possibly cause this condition to be true,
it's probably not worth it either way. Even mac80211 doesn't run into
it, although it might have helped a bit to remember to add skb_orphan()
to the re-injection.

If we decide to uninline those functions for another reason (used too
much, code size, ...) then we can still do that.

johannes

--=-UrBxpDdnlKfckj0vnXxR
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB63wqVg1VMiehFYAQKTuA//fJRFruAEnLr0/MuCqHIJjkO44UWZBChu
jSdzhkbu7YoriaJ6hTd9wKD1C7Y6TjbZOMA6bcNVocnbf5kFG3NfD/pcU6xPK0s/
4wY/2yvGye9Kny4Up5mfmKWohWqPITcZXHL0SudHeh8bZfekEq1yJ7iXJvLrQDtF
r4wKJUAfY5qzCTY6oyi47HyIVNL1SM1rkWA7CNUrc/mZcb+57iOhn3RSH+xi+1SW
aSRcY48HSJ6w7cY/IChtZv7YYLhGY49riURIrSYdZ4DUMDk8okZIBnweh2PxsxNx
gE7WqigZ1UstwaXFRDL3eklpRaZceHYfVQiylDgo8Kove2B3mDKv5B66pyo9Bv1v
nW7l87JFn6NkefP2QxtZPxvrjuK9Bd58YRfZDDuqIn6MR2Kc141r2+1P4fdqTWeS
0jwPAr0xg+KvB7kh84BTarqN5G5YI5nvAsxFrsJARazV2h8S0J7fXV0rM4vmTmhy
I0teGt0QdUfKQHvozmzEOIFiX84j0HVg55eeMb6+hI55bALDOuOO/mWYa1we6N4F
21XBPUrMnudVZXQAjTp2+vHmA/qcHDFlWY1NvXA/2PekDs1iyPGMRoaJzpqnwiID
PPJnjyYGxiGO375oXEMEbzr+mmm/NoZVQIvVJlQ9Lc5cJwim/xR6Go7MhaQ46Idj
ROlqCNVfm7w=
=4Xmq
-----END PGP SIGNATURE-----

--=-UrBxpDdnlKfckj0vnXxR--

