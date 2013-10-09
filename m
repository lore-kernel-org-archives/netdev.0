From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 10/16] batman-adv: use CRC32C instead of CRC16 in TT code
Date: Wed, 9 Oct 2013 16:35:00 +0200
Message-ID: <20131009143500.GH3544@neomailbox.net>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
 <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7384@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="w3uUfsyyY1Pqa/ej"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:18991 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770Ab3JIOf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 10:35:26 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7384@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--w3uUfsyyY1Pqa/ej
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 09, 2013 at 03:11:08PM +0100, David Laight wrote:
> > CRC32C has to be preferred to CRC16 because of its possible
> > HW native support and because of the reduced collision
> > probability. With this change the Translation Table
> > component now uses CRC32C to compute the local and global
> > table checksum.
> ...
> > -/* Calculates the checksum of the local table of a given orig_node */
> > -static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
> > +/**
> > + * batadv_tt_global_crc - calculates the checksum of the local table b=
elonging
> > + *  to the given orig_node
> > + * @bat_priv: the bat priv with all the soft interface information
> > + */
> > +static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
> >  				     struct batadv_orig_node *orig_node)
> ...
> >  	for (i =3D 0; i < hash->size; i++) {
> >  		head =3D &hash->table[i];
> > @@ -1435,27 +1437,24 @@ static uint16_t batadv_tt_global_crc(struct bat=
adv_priv *bat_priv,
> >  							     orig_node))
> >  				continue;
> >=20
> ...
> > +			crc ^=3D crc32c(0, tt_common->addr, ETH_ALEN);
> >  		}
>=20
> Are you really generating CRC32 of a pile of ethernet MAC addresses
> and the XORing the CRC together?
> That gives the same answer as XORing together the MAC addresses and
> then doing a CRC of the final value.

I was not sure about this since the CRC32 is not a linear operation. However
this routine is not on the fast path, so we can also live with this order.

> So it gives you almost no protection against corruption at all.

The corruption check is for the entire global table.
The global table is the union of the local tables of all the other nodes (e=
ach
node has a local and a global table).

The resulting value (the xor of the CRCs) is then compared to the value
sent by whom originated this piece of global table.

In this way each batman-adv node is sure to have the entries that the node
really generated in its local table.

(sorry for using the word table several times..)

Does this clarify? or have I misunderstood your objection?

>=20
> ...
> > -/* Calculates the checksum of the local table */
> > -static uint16_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
> > +/**
> > + * batadv_tt_local_crc - calculates the checksum of the local table
> > + * @bat_priv: the bat priv with all the soft interface information
> > + */
> > +static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
> >  {
> ...
>=20
> This looks like a clone of the previous routine.
> Surely you can avoid the code duplication.

Some parts are the same, true. But this was already like this.
We can surely try to improve it later on with another patch.


Regards,


--=20
Antonio Quartulli

--w3uUfsyyY1Pqa/ej
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSVWmUAAoJEADl0hg6qKeO2sEQAMYqnChCAJF3HCo84TRPOIJ9
WunrxIZtf3TDKHG22mwsD1KTAR7UpsmCSFYwttBQI+DbCeLjTs/BS0KkQgkDq20v
mo+3lrydUT7tLmJrFDJL/7MMFqtqgMyVnAwpkud4vWPoOCpcIw8O1WAiMUauoP2x
jrwFiq4GGbDdprlSmNzfV1dLrfRZY/g2sv+d6aEX1MrLOjwXbH7eKI82qe5yydOF
AGPNY7xyPl8EqqLMoDdYecQ4MtNgOucMy5D5QUDjFN061VMuvwlQ+S3TxqhAVd+V
QvSFjY+Yt1aPfC1ZIGdea9EvK07r3N3z/GBSeaUktgRMiWrRNgxTA+G48N/1hiEJ
2JZkXHE6ZxgI7Mu1WFbKkjcjW1wlvmCr+2D2Ctp/VJiC+3V8vtv+UO9ROeLzS8jg
9t1AMy+8ehs+RCIEuGp97LhjXpG9wq2WGm2GJJuihHjNugdUZq9Kd8udwt7qFr34
KTGp0BSlLi4oSrXr7dgp4IZqPR/2qU/1hxbMk02/ducvf6zqxXSTI3fLy1PFXM6k
o1vPTou+LJnO4698iCwMwxd4LXmZaChJMyGOqwKSUhFX68EmAXBJB6woH4N+mIY1
I0jbS3Ob4nr5tfMA0jCml8BVkcehKUdNwZkLXzQAkatRwiHd078l6mPc3L0JCnet
UGsmO8W6RbLTE0ih+JXh
=qRwy
-----END PGP SIGNATURE-----

--w3uUfsyyY1Pqa/ej--
