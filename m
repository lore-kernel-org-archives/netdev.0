From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the ipsec tree
Date: Tue, 13 May 2014 13:53:22 +1000
Message-ID: <20140513135322.3dfadb7c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/JYR/4_vn_mDAL19ffHkl+ZP"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	WANG Cong <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/JYR/4_vn_mDAL19ffHkl+ZP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/xfrm6_output.c between commit 5596732fa8c1 ("xfrm: Fix crash
with ipv6 IPsec tunnel and NAT") from the ipsec tree and commit
60ff746739bf ("net: rename local_df to ignore_df") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/xfrm6_output.c
index b930d080c66f,f47c8b153dd3..000000000000
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@@ -114,7 -114,13 +114,7 @@@ int xfrm6_prepare_output(struct xfrm_st
  	if (err)
  		return err;
 =20
- 	skb->local_df =3D 1;
 -	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
 -#ifdef CONFIG_NETFILTER
 -	IP6CB(skb)->flags |=3D IP6SKB_XFRM_TRANSFORMED;
 -#endif
 -
 -	skb->protocol =3D htons(ETH_P_IPV6);
+ 	skb->ignore_df =3D 1;
 =20
  	return x->outer_mode->output2(x, skb);
  }

--Sig_/JYR/4_vn_mDAL19ffHkl+ZP
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTcZc3AAoJEMDTa8Ir7ZwVlNoQAIRlYcONp54ZRsaSBt/9tGz0
+x6X5yp7McVN5fXOoSWLwVD1EF4/Tlv0ShMRoWIA3PSzipVsiLC1JggzYxR4t31y
zZ1O0RExukA1TtZnecNw88waBIlEVPPME1r0jV5PD0miJFiqyRnujH430FKFKlRQ
76PIJy9njRIzZMsvxsz3lHYzCVop6+kk8sjk8CtFOwAr7MeKWx4QSuTYb/Axzj8B
py4e390C8S5I/MojoV9ZT2f9XnHkNLwnKJTA11TrOYI8KzemejK5nzx+J/thz9Ej
65YoeqkKlM3yxwpyW+d0HlB35cFtip7tHU2zbln4LZ2aeAIQ58FRk81qDyhKGViw
75Xbh8k7WDDJqfGr5UiVUsTYtyMDNeuHkK7Vlfcx+jYw+r46rI7hHKczVKtJdCzN
7XY/bSmRCkZtFPfG+44/WGdjK0NDH83N75MDPOmg5rXca5Kmoaaa8ALhFl5/2fmX
H8K4fDT247DPXXHy2kWRAo4KG95FeWD+iLHv/fbrQid8ESmYoQa7kELGLvdZejUU
TEt1rHlawQOYOQ8ZKYYAOCskIXBIhyIRZ1pw88v6n9M7kZ4Rp+QvDtGHqh1CUFOJ
s/07sYFrPNgOm/nu2rwbQimHuASQD21z9qobWVFhxuweCc8oyqWLXMPUt27alwWR
MUd/I2sSQ/uSzTJQ6bEL
=gbre
-----END PGP SIGNATURE-----

--Sig_/JYR/4_vn_mDAL19ffHkl+ZP--
