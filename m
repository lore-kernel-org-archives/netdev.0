From: Johannes Berg <johannes@sipsolutions.net>
Subject: wireless extensions vs. 64-bit architectures
Date: Tue, 06 Mar 2007 02:27:26 +0100
Message-ID: <1173144447.15891.93.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-69EhBqzK3yp8CXMy0aPc"
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41255 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933290AbXCFNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:16:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-69EhBqzK3yp8CXMy0aPc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Wtf! After struggling with some strange problems with zd1211rw (see some
other mail) I decided to think again about what could possibly cause all
the other problems I'm having with it. The kernel seems fine, but iw*
userspace continually segfaults! And it also seems to be not
reproducible for most other people, I'd asked on IRC once a while.

Well. Some thinking and stracing and thinking later it occurred to me...
Hell! wext is ioctls and includes this gem:

struct  iw_point
{
  void __user   *pointer;       /* Pointer to the data  (in user space) */
  __u16         length;         /* number of fields or size in bytes */
  __u16         flags;          /* Optional params */
};

Of course nobody ever tells you this, but it's used in a shitload of
places.

Btw, did I mention that I'm running a stock debian powerpc 32-bit
userspace on my 64-bit machine. Oh and of course wext doesn't have any
32-in-64 compat code.

/me laughes manically about wext.

And don't tell me the fix is to use the netlink interface to wext.
Actually, I think it may have the same bug, it seems to be operating
with iw_point (or at least its size) too but I can't really tell, the
code's just too clear, I always just see right through it... Oh and I
still insist on removing the whole pile of junk, netlink interface
first.

Isn't there any possibility that we can kill userspace interfaces that
are terminally broken without keeping them for years to come?

Sorry. This is just too frustrating.

johannes
--=20
Now playing: Nightwish (Century Child) - End Of All Hope


--=-69EhBqzK3yp8CXMy0aPc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF7MN+/ETPhpq3jKURAi4IAKCV0f12tSWsSweSwox/EOni7P5m9wCgrBXJ
YBHJDtR9CHqrNbKTfEQP07Q=
=TB7w
-----END PGP SIGNATURE-----

--=-69EhBqzK3yp8CXMy0aPc--

