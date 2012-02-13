From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: fix truesize calculation when merging active
 tail into lro skb
Date: Mon, 13 Feb 2012 13:43:02 -0800
Message-ID: <1329169382.2307.14.camel@jtkirshe-mobl>
References: <20120213135248.GA23457@sir.fritz.box>
	 <1329142322.2494.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cyzzGJOgqhX1LWjBF7ML"
Cc: Christian Brunner <chb@muc.de>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47177 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960Ab2BMVnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:43:06 -0500
In-Reply-To: <1329142322.2494.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cyzzGJOgqhX1LWjBF7ML
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-02-13 at 15:12 +0100, Eric Dumazet wrote:
> Le lundi 13 f=C3=A9vrier 2012 =C3=A0 14:52 +0100, Christian Brunner a =C3=
=A9crit :
> > I'm seeing some page allocation failures with the ixgbe driver under he=
avy
> > load. While looking after it, I came accoss the truesize handling. I su=
spect,
> > that there is a small misstake in ixgbe_merge_active_tail(). (But I'm n=
ot
> > really sure).
> >=20
> > Truesize allocation of the skb may be larger than skb->len, because
> > ixgbe is allocating PAGE_SIZE/2 for received fragments. Hence we=20
> > should use the truesize of the tail when merging.
> >=20
> > Signed-off-by: Christian Brunner <chb@muc.de>
> > ---
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
> > index a42b0b2..c4d25af 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -1222,7 +1222,7 @@ static inline struct sk_buff *ixgbe_merge_active_=
tail(struct sk_buff *tail)
> > =20
> >  	head->len +=3D tail->len;
> >  	head->data_len +=3D tail->len;
> > -	head->truesize +=3D tail->len;
> > +	head->truesize +=3D tail->truesize;
> > =20
> >  	IXGBE_CB(tail)->head =3D NULL;
> > =20
>=20
> You forgot CC Intel guys, but they usually catch netdev traffic :)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>=20
>=20

Thanks Eric for bringing this to my attention.

Thanks Christian for the patch, I have added it to my queue.

--=-cyzzGJOgqhX1LWjBF7ML
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPOYPmAAoJEOVv75VaS+3OlKsQAKCD3iT8m8TLuSSUeoJQT9jo
sKEdPW8E2p8P17mBk4CnZFeFzTaNqkjEbxBZLVV7fcRmjR/SfpkYa2n96uy5OqJD
bIpBmF/qXx+kaue3E5B8dnkFmm0aLizlKFzwv2B49Mm0PweMXn9SBRUlLmAypzkm
OGIpOdTavCarD6XI4AwonlQwTZNx93wKVwYJIdbbRf1ikY4fk78S5HG7kSuJFAHV
+UOATOiAeavSXbpvmGnuxeg/ph71nJOeZxLNzETyyyrvLeu/gtwyqZrswM1QGnVH
5XHv7GO5jYLFKwzuSbbe4eNi+eaHGgPSPnU/baj5uqraUpirE3p6TzpgArAwWt01
jBSsbcS2Xx6bL5o913m3PBzZx8IbSxugQgNt1sHdklEeIhp3AwjSFo++ihw5e/NG
SoF/f/tD/YPb5lbbAScx5s11KLFaAf9gryN4Fwap9krqoOtY0dRwVHccqIonJuZw
H3PGzh1+WvBZG2LKDKfvyGcnk/V1ZJPKI0Tybc24pjiSbazTrt2+WLMSVVZdkJMw
OccTj47xrxszZzH9d/Q7WpX/iz1V3d+18s6s7vX6gU9x8YzVkNRML1fywgoUfgZn
uz1oiZ3WtPgNIralR/n4OC2YadU0ntnEJh16DgAF1CpMKtXOOl4cSO2GtuHItMhR
2GmqGrwwI0bUu1N56g5j
=n3IV
-----END PGP SIGNATURE-----

--=-cyzzGJOgqhX1LWjBF7ML--
