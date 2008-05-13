From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/T] [NET] make pskb_expand_head warn when called with
	invalid state
Date: Tue, 13 May 2008 10:32:08 +0200
Message-ID: <1210667528.3646.28.camel@johannes.berg>
References: <1209924962.3655.8.camel@johannes.berg>
	 <1210002047.8245.31.camel@johannes.berg>
	 <1210003274.8245.35.camel@johannes.berg>
	 <20080512.221513.178144312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8+bbiIRdA0p2Lfdax5gT"
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41723 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757323AbYEMIcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 04:32:20 -0400
In-Reply-To: <20080512.221513.178144312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8+bbiIRdA0p2Lfdax5gT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


> > > [23194.608077] [ccf9bba0] [c02735a0] pskb_expand_head+0x58/0x1f8 (unr=
eliable)
> > > [23194.608082] [ccf9bbc0] [c02737a4] __pskb_pull_tail+0x64/0x374
> >=20
> > It's actually not really a false positive. What is happening is that
> > __pskb_pull_tail does (follow 'eat'):
>  ...
> > which of course changes the true size of the skb without accounting it
> > to the socket. Now, the reason this hasn't been known before is that th=
e
> > data size doesn't change because the stuff that is copied into the
> > header is removed from the data_len... or something like that, I think.

> Is this from a kernel with your GSO wireless patches applied by
> chance? :-)

Yes, but I'm pretty sure it wasn't using that code path since the
interface was down when this occurred.

> FWIW, the only practical case where this can occur is for an SG+CSUM
> device which cannot handle DMA'ing highmem pages, and we get such a
> page via sendfile() or similar.

That's well possible since I'm using sungem and it says "no highdma" but
"sg/hwcsum" for my hardware, and I do have highmem.
=EF=BB=BF
> I think we need to do some more fixups and auditing before we can
> enable this pskb_expand_head() assertion, and the same goes for
> your more-accurate skb_truesize_check().

Yeah, looks like.

johannes

--=-8+bbiIRdA0p2Lfdax5gT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASClSBqVg1VMiehFYAQJ6Ig//eAOfoDq2+DQx3xHrHD9Q8gcMcsxn2WFN
ESxwkiDRXMv82db/6XEp89+KGDqdf4zJf0g90+lgLWgsEmVE+zDV6gliW2VWye1T
3xLx2ZbFms8X5vba7nqzKUe68SKlEZrWgvxIpw2WIJwXkiCS/X82XsHugOgkwl+M
fcMD2lQTL8Z8IpPYqci+CNpFv1YMLRYG9/zzeoqLSXuGfhKNwMHryISSco6YOADl
wBCFFKSvijCKIk3K0lbnAk0BQ2rFImyNm6ja+QrtxclOoM55f0x766uykfLG5BzU
+kBkB5qPuw/TuoQv81IgjVpgQkODbfdhiX8xdw1xBPg38IAM+nqrnCbygEZfhBUJ
g2Vabn2wqAzN1fwvLRw3i2n3eXHhvX4G2Moa3gMFhUBWubsJvF8yFssnmuSaUppZ
Yd71rqlKDjm6jPuHCSMlPl0OVYUW31ATlQAYuoPKTqsnZTdRFlNaT9EtCTsRwTl3
L67QewuYiWDconk++XL3c3ZuKcu5zF2JLRMDqxoRzp7ONsmy+EvS9HId7o12CS6u
abLtem7ygCXFCv/5FwjMgpSU7n/ifzOBZ2hBko1nnwhJM/5/jkCQRjT1Qhy9MKhK
HgjBJnSe8Eh+CdWJTGjKZuDfMUZD12Go5V+NKU40hm7/7nVbsibGYtR49xrRAPcD
bBbOm5Gf52c=
=bg0O
-----END PGP SIGNATURE-----

--=-8+bbiIRdA0p2Lfdax5gT--

