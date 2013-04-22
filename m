From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 12:43:34 +1000
Message-ID: <20130422124334.92adfce6bdbcba7b08fe83a2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__22_Apr_2013_12_43_34_+1000_PXABuKPIOl6vlyzx"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__22_Apr_2013_12_43_34_+1000_PXABuKPIOl6vlyzx
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/emulex/benet/be_main.c between commit f11a869d4e38
("be2net: take care of __vlan_put_tag return value") from Linus' tree and
commit 86a9bad3ab6b ("net: vlan: add protocol argument to packet tagging
functions") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/emulex/benet/be_main.c
index 2886c9b,811d0a4..0000000
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@@ -759,9 -771,8 +771,9 @@@ static struct sk_buff *be_insert_vlan_i
 =20
  	if (vlan_tx_tag_present(skb)) {
  		vlan_tag =3D be_get_tx_vlan_tag(adapter, skb);
- 		skb =3D __vlan_put_tag(skb, vlan_tag);
 -		__vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 -		skb->vlan_tci =3D 0;
++		skb =3D __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 +		if (skb)
 +			skb->vlan_tci =3D 0;
  	}
 =20
  	return skb;

--Signature=_Mon__22_Apr_2013_12_43_34_+1000_PXABuKPIOl6vlyzx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRdKPWAAoJEECxmPOUX5FE3Z4QAKQpZEsa06tp5n6CkozqKV6W
FD+pCgfe+nL2GGUbsUJ/3xVK4XXCiL437tQQd/91hOf9t76dZLMbjULfKlF3gpvF
dmLWdMuULQ8k/FMf/4ocR28XFHcszPUg8yTICxTS/D38YwM0GXNjrOLljZNjONtv
BqMeN04sCqoIIu3j1BxnO1/n9YPDUx8DYP8A2hcuZMCExaFlRXQIzozaCeXLXohl
bTvHUQQEi+0WnNgH9STfi/cZb9lKjmcHBRQR0hGIvsW82a7y59NDGpfuVIKEzUzv
z+POD6vLkzhbqpSBCGQdcb1fkDZYlO1zyMDhU8OlVGGf+dEtp9IDrYzDvEYTjvII
003KUDm7FUHJ8Zy3pby98DomouCUKpzp2fvTuXwDMmJ0zIB8mAmtGWZQKHHwoyzf
39msC7TX6w0XqIXuN8M4pNTkd8s0iaGxtOITPdot0sw1cvS+Odf9+cETAVsE2gZL
xkvL4jswVgZb5Y871jm/Jk/RsyS/XqDbAsLbaoBSKMOH+Ti9eLYWiaDA+euk6b/o
YT9l00N3YzaUCuofVe4jflqeqXQ6oZqaKGzH7Ma52rE6UuWhKqnLYjHEa9a0DGq+
GARKhlBQYlu6pxXWOFWlDDswQ66YH0ZMaIdQIDIvAYDPTEptOla/3GEK0CLFclVF
UP34nO5Q4YRg7Zm1WzAn
=Lb1t
-----END PGP SIGNATURE-----

--Signature=_Mon__22_Apr_2013_12_43_34_+1000_PXABuKPIOl6vlyzx--
