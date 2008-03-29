From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Sat, 29 Mar 2008 02:01:25 +0100
Message-ID: <1206752485.22530.108.camel@johannes.berg>
References: <20080328000013.GA8193@codemonkey.org.uk>
	 <20080328.173414.22278840.davem@davemloft.net>
	 (sfid-20080329_003421_542132_91288803)  <1206752049.22530.105.camel@johannes.berg>
	 (sfid-20080329_005425_911101_73C51928)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vbYAvcNTKW5paPgnml2p"
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42908 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbYC2BBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 21:01:32 -0400
In-Reply-To: <1206752049.22530.105.camel@johannes.berg> (sfid-20080329_005425_911101_73C51928)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vbYAvcNTKW5paPgnml2p
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > You can't flush a workqueue in the device close handler
> > exactly because of this locking conflict.
> >=20
> > Nobody has come up with a suitable way to fix this yet.
>=20
> Maybe we should check which schedule_work users actually lock the rtnl
> within the work function and move them to a uses-rtnl-in-work workqueue
> so that everybody else can have rtnl around flush.

On the other hand, most drivers don't actually care that their work has
run, they just care that it won't run in the future after they give up
resources or similar, hence they can and should use cancel_work_sync()
which doesn't suffer from the deadlock. But that needs actual inspection
because it does change behaviour from "run and wait for it if scheduled"
to "cancel if scheduled".

johannes

--=-vbYAvcNTKW5paPgnml2p
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+2U5KVg1VMiehFYAQIiYhAAoaBZXpLFGZ1k6flM/f+oV2z8S4eh8rDc
tlDDqiHyccNQ5ED4kYjlQqcS+4rhklH+MmN0xLAQi4/WWg3Dq3rENQbLMHBSpZ6G
r7U7FwugF5+MH1hGLLbXuScRA5M62EkB45j3/1ggRpQneI6ZUoYMtbcfef6MKJzT
IsEAN+fZkgOHtz+3uKKl1JbtQSxNfyvVulJxpHxu22GAe+jA8BsqoU2gXJQ9t8pk
aIlyZR5oOsCMNa2nUSz5u+VjXFlBlEA2pAod2BlCNMxbVejMmznLa/fB/OGnAQ3J
GI2uee1/Dzyrih73+zY544TGWy9Adn+VVw0rUf33B3eQJtzjF3aLDBHrfjZiXhO8
2s44HdD1FuJHJdR8gBGYC1EBP/fZS7RSFneVQFlmkdt47kw/3CQx+oOOi3CQTev+
i6jUFxaatGVBQVZxif/Zx+0TK0aQcgxrliKrFu3qhYRO9g4zBVPGQ5Zsodi1o4rd
4sIToTfUTl11fwjwMdFt2Ihx4cJR7eA0un/5w/5ThTrbZzyqbBio+RoCC1yr4H/r
6NjiBoW55vwbPqTsUwhTrcVtDrRDvK2121LvT5KihucH2OKP51pSSJHuUSLwyYZn
FfmPlPOSY9BKjvJxwFKje58aMh777Dz7RfBJwTNAsLyMbyBn7GXbpvdgycdfChIl
vl5xQyFiR+s=
=vXIV
-----END PGP SIGNATURE-----

--=-vbYAvcNTKW5paPgnml2p--

