From: Jan Kiszka <jan.kiszka@web.de>
Subject: d80211: How does TX flow control work?
Date: Tue, 02 Jan 2007 14:08:21 +0100
Message-ID: <459A5945.80909@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig88F30CE55D9CE04106ABD24E"
Cc: Jiri Benc <jbenc@suse.cz>, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:48810 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754828AbXABNIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 08:08:24 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig88F30CE55D9CE04106ABD24E
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi,

can someone explain how TX flow control in d80211 is supposed to work? I
failed to understand the full design so far.

What I (think to) understand is that a low-level drivers call
ieee80211_stop_queue() if they run out of buffers. That flips a
per-queue bit (IEEE80211_LINK_STATE_XOFF), prevents that any further
frame is passed to the low-level TX routine, and can cause that up to
*one* packet per queue is stored in
ieee80211_local::pending_packets[queue]. But it looks to me like nothing
prevents ieee80211_tx() being invoked even in case that there is already
some stuff in that single-packet storage.

That in turn triggers WARN_ONs in ieee80211_tx() under high load for me
(with rt2500usb). And it should also cause orphaned skbs because the
storage is overwritten in that case. Either I'm blind or something is
fishy...

Jan


--------------enig88F30CE55D9CE04106ABD24E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFmllFniDOoMHTA+kRAi6pAJ4q+mM0iq+dgQPh7a4/OJoLarzVGACggPuz
vaCKEPZ0C9WCavzqXYYmWXs=
=CI7U
-----END PGP SIGNATURE-----

--------------enig88F30CE55D9CE04106ABD24E--
