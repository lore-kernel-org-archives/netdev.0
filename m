From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 16:38:03 +0200
Message-ID: <1183559883.3812.42.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>
	 <468BAF10.6080208@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-B8tNGcRz3jR/phLEYukW"
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56573 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759760AbXGDOhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:37:10 -0400
In-Reply-To: <468BAF10.6080208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-B8tNGcRz3jR/phLEYukW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-04 at 16:30 +0200, Patrick McHardy wrote:

[...]
> The kernel doesn't have any multicast listeners (yet).

Right.

> I wonder if thats really a good idea to use multicast for device
> configuration. Unicast transmissions from userspace to kernel
> are reliable when you don't use MSG_DONTWAIT. For multicasts
> doing the same would mean blocking on each receiver when the
> receive queue is full.

That's a good point actually. Are transmissions from userspace to
userspace also reliable in that case?

In fact, we haven't quite decided yet whether we want all configuration
to be via netlink. I strongly prefer this, but other people say that
userspace<->userspace communication is nothing that nl80211 should be
involved in.

What I initially wanted was to publish something like "Device wlan0 is
managed by netlink pid 12345" (or 0 if the kernel is doing it) and then
configuration would be "send to <number the kernel told you>". However,
that got me into problems when trying to determine "is the process
owning netlink pid 12345 still alive" at which point Herbert suggested
the use of multicast groups (and doing the exclusion "only one manager
per netdev" in userspace instead of the kernel).

johannes

--=-B8tNGcRz3jR/phLEYukW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGi7DL/ETPhpq3jKURAr9tAJ4l03R00QZEzcQTgKd+XHgqhPUc6QCghDNa
vhvk3Pu8EfpheZ9gTVzPkQM=
=SU1N
-----END PGP SIGNATURE-----

--=-B8tNGcRz3jR/phLEYukW--

