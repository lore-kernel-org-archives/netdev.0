From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 13:52:13 +0200
Message-ID: <1209815533.3987.21.camel@johannes.berg>
References: <1209639500.7067.0.camel@johannes.berg>
	 <20080501110341.GD7490@gondor.apana.org.au>
	 <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HAMbGV0fR9LyZuZZG4vU"
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50997 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbYECLw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 07:52:27 -0400
In-Reply-To: <20080502.163334.148944203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HAMbGV0fR9LyZuZZG4vU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> We can't update skb->truesize during arbitray skb->data reallocations,
> because it could corrupt the socket accounting.
>=20
> On the other hand, if we provide ways for users to subvert the socket
> buffer limits, we might as well not try to limit anything.

Why don't we update the socket allocation when doing pskb_expand_head()?
Sure, it could become negative, but is that so bad?

> Take a look at some ethernet drivers that implement TSO in a way that
> requires munging the IP headers for whatever reason.  If they need to
> COW the packet data in order to modify it, they always do this with
> pskb_expand_head(skb, 0, 0, GFP_*) exactly so that they don't modify
> the SKB data size, and exactly so that the skb->truesize value stays
> accurate.

We need more space though. Should we then just increase the built-in
headroom?

johannes

--=-HAMbGV0fR9LyZuZZG4vU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBxR7KVg1VMiehFYAQIG6A/+LN7tnSrj2GWgprqCBlUEo7SJLnGQ7BVE
BiRas6WVxYIUKjquPF5c3qWLaCDMPkRwV1j4tt3dfCXLckGDNMrb/TNESKL+TEqo
psLnzV8gWcjIlfnt4FCb6d0G/N/P0w+R94tQC5Q9c55QTVU7BL9rwXsUmh3NKZx+
N9PmtQrdLne8lzEKTUzRblH28rQ/yffn0blrnZhw7vc0wcYzo1IvdV/LCphSbQwu
VCJhcVmZEQZAi6ezN+yI8Ap/RSzsdL1MVzquVjf1CkU1oeTT7z8vPX19qcqrSJp5
DNn1L3bg5/fTF3bkeMKPKY7hccszC0iuflBA2jHGPGlMpJTxa92DMn10prZMEpM6
DDZ4W+BpjUJtLO9PD921wWk02hrgrQIT/2XFEpLe8oPsE7RLiU+FkQgazgho2Pjb
AlD2ixApQW45H2kM74iYq/4WJU4LdQ73fai04h9CWz6Q5T4O0cVZMCPoO4UXWlr/
Eu6YJ9/500GuM1IrxcqBwZF96sbxRq5zAmaqsHfhHtU3R8JRiielYHgGk4KZhZ+4
VdCeJnh+9S+WXCoTiNLrv/gAGqJFjqJHvNe4OJDA2nhR89WGmRgLZJIDVwHCjW8P
D7hQwV74L0+OPvkOITfZLZpYZU7PTTP9LhzRebG5bC29xw1QLpJiroeOv1mJnhCb
cKTH3ss5qRo=
=wAUQ
-----END PGP SIGNATURE-----

--=-HAMbGV0fR9LyZuZZG4vU--

