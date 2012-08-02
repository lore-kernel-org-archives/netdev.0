From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: use build_skb()
Date: Thu, 02 Aug 2012 13:29:48 -0700
Message-ID: <1343939388.2132.44.camel@jtkirshe-mobl>
References: <1343922692.9299.231.camel@edumazet-glaptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RYOJRXLseuYKF3KdhEtg"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16398 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753078Ab2HBU3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 16:29:49 -0400
In-Reply-To: <1343922692.9299.231.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RYOJRXLseuYKF3KdhEtg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-08-02 at 17:51 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> By using netdev_alloc_frag() & build_skb() instead of legacy
> netdev_alloc_skb_ip_align() calls, we reduce number of cache misses in
> RX path and size of working set.
>=20
> For a given rx workload, number of 'inuse' sk_buff can be reduced to a
> very minimum, especially when packets are dropped by our stack.
>=20
> (Before this patch, default sk_buff allocation was 2048 sk_buffs in rx
> ring buffer)
>=20
> They are initialized right before being delivered to stack, so can
> stay
> hot in cpu caches.
>=20
> Ethernet header prefetching is more effective (old prefetch of
> skb->data
> paid a stall to access skb->data pointer)
>=20
> I have 15% performance increase in a RX stress test, removing SLUB
> slow
> path in the profiles.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |    8 ++
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   14 ++--
>  drivers/net/ethernet/intel/igb/igb_main.c    |   56 ++++++++++-------
>  3 files changed, 49 insertions(+), 29 deletions(-)=20

Thanks Eric, I have added this as well to my queue.

NOTE- you had some trailing whitespace errors in igb.h which I cleaned
up before adding to my queue.

--=-RYOJRXLseuYKF3KdhEtg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQGuM8AAoJEOVv75VaS+3OEskQAJ+xT1rKuwSXs+rupca2vaK+
grtBZZcizsiwIQrtv7kMPhx7Wu4tJjwWGVX7NPCq3hn9Z0qt+jWxtP443yFJZDBx
WTddmQcr4uwWjiemcNWeNCZMmYVMpeGdYA56T7QXrzejAf+nHEpbv9Vb7jctpCKt
uNQdFYv43MwrQH8Rn49o4brY1CK3+lr8a+3mHckAuyzm3/OeVr+UbavQSwB2RwUX
EroCrLR6qGzjl1nYYZNh7Mf0h7PLCPCL1iM+YGBTo/WSkBeDACPLwe4RJdLRT1bD
tyc8ocWyMYcaMveuWdyZihaiaM5MzC665xSLy5Sbcn4hVAnp43YXuUjII7lZWbyE
CjMBN1hxiQv5UmV7rQFL7ynyf+RMJCmQkPuuOD554y73FTJ5SP4SYfwA4KBQ2p8q
fzHSpERrofuVEzQd+8eS6iCEcQ09xjOtKyhLjnIRNr41yEjL/14/4gG4lOG+3WhI
tReEaLHWRMmybjIBP0WimmvAbvLioHhpWyMGI6ab34PAmUfiVW5FjTJVFsKI1coR
Qh2PYtacWai6F5imVoeJf3cPJR5PeSPrqkq7uyscIiGqcJo/QP+AR1AtrI3e4SjV
ojslsgX/wP10GlV3wMh/g5Mgh42AgF+v3ij9cSQV0bdASAJhAW1SpVBxym0xZsGW
vRzrKbvup6TZJWRow4Uy
=XfR3
-----END PGP SIGNATURE-----

--=-RYOJRXLseuYKF3KdhEtg--
