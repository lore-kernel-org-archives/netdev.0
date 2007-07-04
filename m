From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 16:56:46 +0200
Message-ID: <1183561006.3812.47.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>
	 <468BAF10.6080208@trash.net> <1183559883.3812.42.camel@johannes.berg>
	 <468BB327.5050709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XUUNqpdYa2dpYUxjdpXV"
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37747 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbXGDO4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:56:20 -0400
In-Reply-To: <468BB327.5050709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XUUNqpdYa2dpYUxjdpXV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-04 at 16:48 +0200, Patrick McHardy wrote:

> Yes, although in both cases you have no guarantee how long its
> going to take, someone else could be flooding the receive queue.
> For userspace this is more likely to be a real problem though
> since the kernel will keep processing the queue as long as packets
> are in it, while userspace could be scheduled away.

Right, but in the case of wireless you'll have different problems if
that happens, namely your wireless card won't be reassociating etc. I
don't think it'll be a problem in practice.

> I'm not so sure myself whether netlink is really a good idea for
> userspace<->userspace communication because of the above reason.
> IIRC Herbert had the same doubts some time ago, I wonder what
> made him change his mind.

Hm. The reason I wanted it initially is that this way we can guarantee
that userspace programs work in either case and also that we have better
control over the various APIs.

> There is a notifier for userspace unicast socket releases, would adding
> another one for multicast groups help?

Huh I think that notifier is enough in fact. It'll be called if a
userspace process closes a socket or such, right? Might get a lot of
events for generic netlink but that should be acceptable since it'd only
need to check .pid to start with.

johannes

--=-XUUNqpdYa2dpYUxjdpXV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGi7Uu/ETPhpq3jKURAo4uAJ9xAdH3fg2ULzfUubUYv279VjdMiQCgg6Ib
gaDl5mdQp0LqEn9qAxHiNi0=
=mT5L
-----END PGP SIGNATURE-----

--=-XUUNqpdYa2dpYUxjdpXV--

