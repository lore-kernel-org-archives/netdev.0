From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Wed, 23 Oct 2013 12:28:48 +0200
Message-ID: <20131023102848.GB1535@neomailbox.net>
References: <20131022.025038.1046903740187748879.davem@davemloft.net>
 <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com>
 <20131022101127.GJ1544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739F@saturn3.aculab.com>
 <20131022171314.GL1544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gatW/ieO32f1wygP"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:29013 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab3JWK3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 06:29:33 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73A1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gatW/ieO32f1wygP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 23, 2013 at 09:33:49AM +0100, David Laight wrote:
> ...
> > > I can't remember which value you passed as 'offset' (and my mailer ma=
kes
> > > it hard to find), but to ease the code changes the offset of the udp =
data
> > > would make sense.
> > > In that case you still need to pass the source port.
> >=20
> > I decided not to pass the source port because if the user is really int=
erested
> > in it, it is still possible to get the udp_hdr from the skb and read it=
s value.
>=20
> It just seemed that there was no need to require that the hook re-parse
> the ip header just to find the source port.
> (ok it could assume that the udp header is just before the data)

Also David (M.) pointed out the same. I will keep the port as argument for
rx_hook.

> =20
> > > If you do rx_hook(np, source_port, skb, offset) then if anyone manage=
s to
> > > load an old module (or code that casts the assignement to rx_poll)
> > > at least it won't go 'bang'.
> > > Renaming the structure member will guarantee to generate compile erro=
rs.
> >=20
> > so you suggest to rename rx_hook to something else to warn people about=
 the
> > change?
>=20
> Yes.
>=20

mh..what about rx_skb_hook ? this way we also make it easy to notice the
difference (both in arguments and behaviour).

> > If we go for the "no udp port" approach they will get an error any way =
because
> > of the mismatching arguments.
>=20
> No - you only get a warning when you assign a function pointer of the wro=
ng type.
> And that is true even if you just change the type of the pointer.
> However code might already have a cast on the function pointer (eg becaus=
e the
> hook has 'unsigned char *') - so you won't even get a warning.
> You then get an OOPS when the hook tries to read the buffer.
>=20
> It is a really bad interface...
> There isn't even a flags/options (etc) word that can be used
> to detect enhancements.
>=20


agreed. But I am not sure about what I could do to fix that.

My idea is to use the following API:

rx_skb_hook(struct netpoll *np, int source, struct sk_buff *skb, int len);


Any suggestion or objection?


Regards,


--=20
Antonio Quartulli

--gatW/ieO32f1wygP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZ6TgAAoJEADl0hg6qKeOJwsQAMVSc3VYf/EjX+lV3aYH0tKw
/lfHNr7vBebDpE5XgnmFQDg2WkOQJ/fxAi44xlouIet+xq7RQ/VmBBcUohkW6pC4
yxZdTFJbyTdG4eaAscudiU+C31QPpZBTUuAZd9FYmtPPT+QsCSreIOmZ4JHm55g1
/qkHrzBvB5miCP1MTLsWMlbYv00nBVN4z1awYMfOuchPwdrc5ez8zQeNpNzrZbVs
gNb9YhB7nA8RL1pgnHfajs4VLueLsHVZwU3dQzHwau9XcVfBFU37ViL1rKVzB3Zw
4FeN2Wr1jAVbytMGTD2AUi9neHnE35pnk9fbb809WIu483aYEbOJtt3HuWB5Bzuh
FIgMUnxAvtHAHf4Af5huB9B9PAL2s/K3whaGhpNeGR/vFxI35U+oh34SCbm+EQPk
6aU5jrYN0bdgFkkWFKBj7belFKlSuzC+4szsWt4BLM936ZaSCiWWXE3uNc0Pk0ps
7+Yx8WLLyLOeRZYALmxYU1suzQ24cbUzdezmgFzbK+l9miobPD4Tgt7jPm4NzbKW
4E4uIqG5XMwyROTJ877g60O1MqE6fmCo7hOYgXEu30TdarEnqnXTa9e6DsDXmsjS
FpPT6IzAhJeV6fV01NKx2pIEe0t7Svo7YavDbzlxICPgDE8d9oSqJE5foZupviTg
M9wcgDyLG0GZwZ/oybO4
=f08g
-----END PGP SIGNATURE-----

--gatW/ieO32f1wygP--
