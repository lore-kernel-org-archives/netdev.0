From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Wed, 27 Feb 2008 13:46:14 +0100
Message-ID: <1204116374.6309.5.camel@johannes.berg>
References: <47BAEE3B.7020502@trash.net>
	 (sfid-20080219_145720_362430_7BA05F2C) <1204112235.3729.54.camel@johannes.berg>
	 <47C54DA1.5070402@trash.net> <1204115674.6309.0.camel@johannes.berg>
	 <47C55A98.7000304@trash.net> (sfid-20080227_124239_671757_70D6730A)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-dHnmXpz9Hg55lH6ADjML"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56420 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbYB0Mq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 07:46:26 -0500
In-Reply-To: <47C55A98.7000304@trash.net> (sfid-20080227_124239_671757_70D6730A)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dHnmXpz9Hg55lH6ADjML
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> >> I don't think so, the users field was already initialized properly
> >> before. Is wireless using dev_unicast_sync or dev_mc_sync?
> >=20
> > dev_mc_sync(), we sync all multicast addresses of all interfaces to the
> > master netdev to have a single consistent list. There used to be a
> > custom implementation of that but I replaced it.
>=20
>=20
> I can't see how this bug could be responsible, assuming da_synced
> intially contained a non-zero value it might forget to sync an
> address, but still try to delete it when unsyncing. __dev_addr_delete
> will simply do nothing in this case. But I guess the patch is still
> worth trying.

I don't know how it would cause it either, but seeing that I can't even
reliably reproduce the problem at least that seems like uninitialised
memory could cause it. I guess I'll see if I the problem ever turns up
again after this patch goes in...

johannes

--=-dHnmXpz9Hg55lH6ADjML
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8VblaVg1VMiehFYAQIEMA//cz9K5tEY4cd0qMA0fQ7o8n92HJWILzJD
ndsywcBwaecZ53EwVnSdXOabGb5jK0nnrwSAeEdnylvjcwjXTZYfG3JdXGHudJgD
EsVNJRFSkYAtOQYjek/qg9jtSNVtwPa/rupYBV6kiFPuhrX+HQhrEHAEfsTqnY+K
iQuyymPm9OGp6PJJNAtVFVMKtlZg91OgdI2a6EuCgfZgLdwIxgtoUkGJhheyjIqG
atQ4mlkX3x04+sAmfhLV6RLFvc1/cXPxW1ajvRx9Y/ouZJ7XM1D7nb+BqC0fkIa0
OHTZgzG3YbnFeKL5ew2q5Tnb8JeUft5wzHMyx3dAE7qPtrw3DU70DWO9JYNqcWjF
m/YYlsPuRFqqRrUzHxR6Y/9ddfHWvroN0DA+RFDNDtLrcIWMB2va6Kv1EEu+7Puw
QDr6+QdwlzJklJdVvUVWqyBb8A/KnYPleUgiCeSrMzEL55Cf7h8AgygpLn2Pshab
C1uuWQZ6prTBhoCs2kZ1xboJ3cmXWgY5oZEWwEqJGAVMwHn5ToEiIoGHo8kNtM+k
xwcD6IjaAUDs0FznPpsV/EI8Do/hxtFNzeDguHB0PvPohUdhkO8knLP9giX8ot1o
taTsq96N8bl6spQVB/NrlEm0Is1FFylbst8/Ct/rXGy16D664bOfiTbKYrGjAvkr
9wXh3lcq19E=
=sSNS
-----END PGP SIGNATURE-----

--=-dHnmXpz9Hg55lH6ADjML--

