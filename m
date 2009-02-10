From: martin f krafft <madduck@madduck.net>
Subject: pseudo interface with different hwaddr
Date: Tue, 10 Feb 2009 12:25:08 +0100
Message-ID: <20090210112508.GA16497@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from clegg.madduck.net ([193.242.105.96]:54669 "EHLO
	clegg.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbZBJLZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 06:25:16 -0500
Received: from wall.oerlikon.madduck.net (wall.oerlikon.madduck.net [IPv6:2001:41e0:ff12::1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "wall.oerlikon.madduck.net", Issuer "CAcert Class 3 Root" (verified OK))
	by clegg.madduck.net (postfix) with ESMTPS id 81D8E1D409C
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 12:25:10 +0100 (CET)
Received: from piper.oerlikon.madduck.net (piper.oerlikon.madduck.net [IPv6:2001:41e0:ff12:0:211:2fff:fe6b:c869])
	by wall.oerlikon.madduck.net (Postfix) with ESMTPS id 41CAD9F13D
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 12:25:09 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dear netdevs,

I don't know where else to turn to with the following question. If
you know a better mailinglist for users like myself to turn to,
please let me know.

In the meantime, maybe you can help me with the following quest:

I am trying to obtain two DHCP leases on a single physical
interface, because my provider is stupid[0]. I can engineer DHCP
requests in such a way that I get the second lease, but the provider
requires the ethernet frame's source address and the BOOTP's chaddr
field to match and otherwise ignores the DHCP request.

  0. they are two static IPs, but the static IPs only work when they
     are regularly renewed with DHCP. Since I only have one host to
     connect, and I want both IPs on that host anyway, I need to
     pretend to be two hosts.

I'd like to avoid writing my own scapy-based DHCP client for the
second lease and instead use dhclient3, which supports pseudo
interfaces and now sends out two requests, but does not give me
a way to change the chaddr field or the frame's source address and
instead enforces those of the interface for which is was invoked.

I have not yet come up with a way to solve this, but I was thinking
that the most elegant would probably be some sort of pseudo
interface that I could atach to eth0, such that pseudo0 would behave
just like a real network interface to the kernel and software, while
using eth0 to transmit frames from a different MAC. With eth0
configured promisc, it would receive all frames, but let only those
to its hwaddr through (unless it were itself configured promisc).

Does something like this already exist?

Do you know of another way to achieve what I want?

Thanks for your time and attention,

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
drink canada dry! you might not succeed, but it *is* fun trying.
=20
spamtraps: madduck.bogus@madduck.net

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkmRZA4ACgkQIgvIgzMMSnUClwCeI3H2iz0FTXpmuyw+Fs6eRZV1
hKQAoI9/YO8sdTBNN3hWT/D+NDK3gaMq
=KXoK
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--
