From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 27 Feb 2012 12:11:25 +1100
Message-ID: <20120227121125.007c32f9aa7be2470d9e3356@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__27_Feb_2012_12_11_25_+1100_kvoyOHFIPttzh9C."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__27_Feb_2012_12_11_25_+1100_kvoyOHFIPttzh9C.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/sfc/rx.c between commit ff3bc1e75275 ("sfc: Fix
assignment of ip_summed for pre-allocated skbs") from Linus' tree and
commit db3395697cad ("sfc: Replace efx_rx_buffer::is_page and other
booleans with a flags field") from the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/sfc/rx.c
index fc52fca,506d246..0000000
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@@ -156,10 -155,11 +155,10 @@@ static int efx_init_rx_buffers_skb(stru
  		if (unlikely(!skb))
  			return -ENOMEM;
 =20
 -		/* Adjust the SKB for padding and checksum */
 +		/* Adjust the SKB for padding */
  		skb_reserve(skb, NET_IP_ALIGN);
  		rx_buf->len =3D skb_len - NET_IP_ALIGN;
- 		rx_buf->is_page =3D false;
+ 		rx_buf->flags =3D 0;
 -		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 =20
  		rx_buf->dma_addr =3D pci_map_single(efx->pci_dev,
  						  skb->data, rx_buf->len,
@@@ -493,9 -494,8 +493,9 @@@ static void efx_rx_packet_gro(struct ef
  	} else {
  		struct sk_buff *skb =3D rx_buf->u.skb;
 =20
- 		EFX_BUG_ON_PARANOID(!checksummed);
+ 		EFX_BUG_ON_PARANOID(!(rx_buf->flags & EFX_RX_PKT_CSUMMED));
  		rx_buf->u.skb =3D NULL;
 +		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 =20
  		gro_result =3D napi_gro_receive(napi, skb);
  	}

--Signature=_Mon__27_Feb_2012_12_11_25_+1100_kvoyOHFIPttzh9C.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPStg9AAoJEECxmPOUX5FEi6IQAKGamR3N6tjk0ieKIHQS8EvO
G7b9sjOY82hpOj6nPkgpZOp3+TcLbiS9LE3GAVA8StjAHVAGfSLfKeQP6CsZnKqH
8GoS7uvFluPksCJU1fBThpizOmF8CZru9GEmtKZP/NE2dItGIjzSTheHvlY4z8ch
qFZHzyz0xO7gVaSREm5eOQ/QB2sUBeGVnDzgMFVk/I5brM4n8ON019vqIb9IF+i0
QlTg7uMp+6HrtzigNjPfZZWpJA7o1DcnxiJCdQPbYjVSedy6duI9/q8qqN6C35gh
rbLKzHGFPeM/gb9xCnm/EIBt6dxfU0gTwSU7k/+LUoMBngKJR6QmB8HYG3oI0s9f
HUjvI6BxtIMRe7sOF/X2hYO1SPRHUVphpymCna9Ncuql4ISn8FCcNertxUeeeqdJ
FI5sW35S8UeLi4BS66ex28IkiCq5V2DFVgrAyXDwxp2fwLUTb3J7feJ/MMjp3Uh6
G7Z/sYM5ByALLotUnMLh6qmWV+eTz7gxvgWRv19PsYtGxeqbLxd68vz/xk5xmlJt
1zEZwj76/TuHciivDAoFMdOUDyYvQJIoOVBtoaty+juh2649d4FcOvMNB5471iev
dNBWpjNT2XZv7XVRl1Xz1T61aA5xn4ejC7XUertBr9LLDOUPFpVlqV+sZfZDD7Uc
QGK9DWwRV9e4pAtwFBFl
=yX6V
-----END PGP SIGNATURE-----

--Signature=_Mon__27_Feb_2012_12_11_25_+1100_kvoyOHFIPttzh9C.--
