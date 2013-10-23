From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Wed, 23 Oct 2013 14:44:01 +0200
Message-ID: <20131023124401.GC1535@neomailbox.net>
References: <20131022.025038.1046903740187748879.davem@davemloft.net>
 <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com>
 <20131022101127.GJ1544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739F@saturn3.aculab.com>
 <20131022171314.GL1544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A1@saturn3.aculab.com>
 <20131023102848.GB1535@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Y5rl02BVI9TCfPar"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:9298 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab3JWMon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 08:44:43 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73A4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Y5rl02BVI9TCfPar
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 23, 2013 at 12:18:32PM +0100, David Laight wrote:
> > My idea is to use the following API:
> >=20
> > rx_skb_hook(struct netpoll *np, int source, struct sk_buff *skb, int le=
n);
> >=20
> > Any suggestion or objection?
>=20
> Don't you need to pass the offset of the udp data?

Yes, you are right. I just forgot it. Therefore we have:

rx_skb_hook(struct netpoll *np, int source, struct sk_buff *skb, int offset,
	    int len);

where offset is going to be =3D (udp_hdr + 1) - skb->data
and len =3D skb->len - offset

Regards,

--=20
Antonio Quartulli

--Y5rl02BVI9TCfPar
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZ8SRAAoJEADl0hg6qKeOWJoQAIvSMZakLyazB3IrY1sMh9SK
oBcaxkajRm1HTfggUi97lR7Pfha31trj1YlthhSabLdWKpgusdjqqChr7GLSz/mD
j+WYaMj1Vv1n3zkhJa1quBgEfkiz/oSQ5lpbCEJF4S2OW2q8PnQd6GG7pVAFZDY/
3FFc1ZcZuughNogXu8H1BV79rnCAWzBFB5ksLqIEvrDa1CPEteRbZWg17apBC1Nf
8FWjeTqxTfLSQPi8NrBB6MMaj66zR77WixVgme5PngqZjl/axgU98oDjB+jxUOFo
OQZhx7z1/el7vladVUsEOrE1P7IbdRx2sXQgQSPlyYdU7KhziFQpqU/SJ9G9Mg+W
saZgY4cxiIC7zkP5LgI3feUUzsOLHdQpD1mSQKs0oY6K5bOQvR60CCconyku0HVp
r3iohIjI/IPFoXqLjE9yv+WKp9V0N22HeNgOvxHB1DgcQV6O+uBkc5gUADkh8gN2
P9CmGtIw/tiLKw75onvQiwf01VjxgmOnXAZehCbdaoW4HLFvGNGi4ugRj9WioaRF
QzJi2cBJaC2bpIvO3JjMMwLjdFKbfRARbk8ypBzx7K5q4fBDc6ifA3pOGmBpQOEf
ZtmCBA04F6Q3sPSmCkZUiBMF+RMXcRI5FXdXAaR/uIhcKge3dQQYJVv1IeFrHppH
+uP2UlOyfSdlc/qqDBDe
=Sanm
-----END PGP SIGNATURE-----

--Y5rl02BVI9TCfPar--
