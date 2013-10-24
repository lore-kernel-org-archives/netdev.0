From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the skb
Date: Thu, 24 Oct 2013 14:01:52 +0200
Message-ID: <20131024120152.GO929@neomailbox.net>
References: <20131023.161603.1190144528425577653.davem@davemloft.net>
 <1382564190-334-1-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="yklP1rR72f9kjNtc"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:15518 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab3JXMCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 08:02:34 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73A5@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--yklP1rR72f9kjNtc
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 24, 2013 at 09:43:38AM +0100, David Laight wrote:
> > Subject: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the =
skb
> > @@ -820,7 +823,10 @@ int __netpoll_rx(struct sk_buff *skb, struct netpo=
ll_info *npinfo)
> >=20
> >  		len -=3D iph->ihl*4;
> >  		uh =3D (struct udphdr *)(((char *)iph) + iph->ihl*4);
> > +		offset =3D (unsigned char *)(uh + 1) - skb->data;
> >  		ulen =3D ntohs(uh->len);
> > +		data_len =3D skb->len - offset;
> > +		source =3D ntohs(uh->source);
> >=20
> >  		if (ulen !=3D len)
> >  			goto out;
> > @@ -834,9 +840,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpol=
l_info *npinfo)
> >  			if (np->local_port && np->local_port !=3D ntohs(uh->dest))
> >  				continue;
> >=20
> > -			np->rx_hook(np, ntohs(uh->source),
> > -				       (char *)(uh+1),
> > -				       ulen - sizeof(struct udphdr));
> > +			np->rx_skb_hook(np, source, skb, offset, data_len);
> >  			hits++;
> >  		}
> >  	} else {
>=20
> From a code optimisation point of view you probably don't want to be
> calculating the source, offset and length early.
> It is quite likely that the local variables will have to be written
> to the stack (because of the function calls) - so it is almost
> certainly more efficient to calculate them just before the call.

I thought that computing them once outside the loop was better than
re-computing them during each iteration.

Having them outside makes it also clear that they always have the same valu=
e.


Regards,

--=20
Antonio Quartulli

--yklP1rR72f9kjNtc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSaQwwAAoJEADl0hg6qKeOoUEQALDRFaVc+9QrlyQ7EuGdbivR
3KiTE2gy9USfnRhab8U/y2EX601hOFIf6YzOaO021XjiwSCFsCtxsjyF8gcTdWL9
z42uCOUdEFgx3hcO5AfQyaKvYF7/sTG8yWEvPj33fyUU07f30qhCjOsVG+cpxOTv
JWKJ10bYTCclYhVIwA+k/iZO9YbKzs/n+d7rPJz6v/OCardp6tnsvEckQcE2YK5s
MwX6Km5sFsIO7/vk84ia9lRzmox4Rn/3wws3Cp/LiTMchc3vGmSyTJuYJcPuuF32
qfrN8YmNAkdC8ypDf3esOunMGnGZvq2Ui0o3hw8MDR5/uyWEGODFjuLspI1Qhr1B
mncDoO/RTLDMPZjVhyxgTbmCPFPqh8H6hJrSNsup/hzFYrjQTAx2OLEUQouqFYrd
uJ4/cTWzqzp1PaUWb9tTvRslkmRa+/pJvhJPKhZjd2qAjRb6HNbK91DJAjv08iMd
zE1UULPQfB9Ze+vgb0tcFJ1fojYV361SHqpL157s/0eqpyUS4dw3Zjkl4tZWxLG0
UQ93cwpNY6NHinyyRRgbBNz99QUb4NSFDqQgEHzFpzkuvVeCq3pjjt6sLowZULt2
JcEeZ4h09t41qMG4X/2rrrW/szymx/iC757T54EH5DcjpB2i32xA+rSOu41KXewY
unfz9KZJyupfDJX282hQ
=4s40
-----END PGP SIGNATURE-----

--yklP1rR72f9kjNtc--
