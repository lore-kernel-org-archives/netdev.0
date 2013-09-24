From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the ipsec-next tree with the net-next
 tree
Date: Tue, 24 Sep 2013 12:16:29 +1000
Message-ID: <20130924121629.f818475ddf308b0494cfce2a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__24_Sep_2013_12_16_29_+1000_e=XcjafQ3mHIc/b7"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fan Du <fan.du@windriver.com>, Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__24_Sep_2013_12_16_29_+1000_e=XcjafQ3mHIc/b7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Steffen,

Today's linux-next merge of the ipsec-next tree got a conflict in
include/net/xfrm.h between commit d511337a1eda ("xfrm.h: Remove extern
from function prototypes") from the net-next tree and commit aba826958830
("{ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode
callback") from the ipsec-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/xfrm.h
index 7657461,c7afa6e..0000000
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@@ -1493,39 -1495,35 +1499,39 @@@ static inline int xfrm4_rcv_spi(struct=20
  	return xfrm4_rcv_encap(skb, nexthdr, spi, 0);
  }
 =20
 -extern int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb=
);
 -extern int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb=
);
 -extern int xfrm4_output(struct sk_buff *skb);
 -extern int xfrm4_output_finish(struct sk_buff *skb);
 -extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned sh=
ort family);
 -extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned =
short family);
 -extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *=
handler);
 -extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier=
 *handler);
 -extern int xfrm6_extract_header(struct sk_buff *skb);
 -extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 -extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
 -extern int xfrm6_transport_finish(struct sk_buff *skb, int async);
 -extern int xfrm6_rcv(struct sk_buff *skb);
 -extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 -			    xfrm_address_t *saddr, u8 proto);
 -extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned s=
hort family);
 -extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned=
 short family);
 -extern __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *sad=
dr);
 -extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address=
_t *saddr);
 -extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb=
);
 -extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb=
);
 -extern int xfrm6_output(struct sk_buff *skb);
 -extern int xfrm6_output_finish(struct sk_buff *skb);
 -extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *sk=
b,
 -				 u8 **prevhdr);
 +int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 +int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 +int xfrm4_output(struct sk_buff *skb);
 +int xfrm4_output_finish(struct sk_buff *skb);
 +int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short fam=
ily);
 +int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short f=
amily);
- int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
- int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
++int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler=
);
++int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handl=
er);
 +void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
 +int xfrm6_extract_header(struct sk_buff *skb);
 +int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 +int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
 +int xfrm6_transport_finish(struct sk_buff *skb, int async);
 +int xfrm6_rcv(struct sk_buff *skb);
 +int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 +		     xfrm_address_t *saddr, u8 proto);
 +int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short fa=
mily);
 +int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler,
 +			    unsigned short family);
 +__be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
 +__be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *sad=
dr);
 +int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 +int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 +int xfrm6_output(struct sk_buff *skb);
 +int xfrm6_output_finish(struct sk_buff *skb);
 +int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 +			  u8 **prevhdr);
 +void xfrm6_local_error(struct sk_buff *skb, u32 mtu);
 =20
  #ifdef CONFIG_XFRM
 -extern int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
 -extern int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optv=
al, int optlen);
 +int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
 +int xfrm_user_policy(struct sock *sk, int optname,
 +		     u8 __user *optval, int optlen);
  #else
  static inline int xfrm_user_policy(struct sock *sk, int optname, u8 __use=
r *optval, int optlen)
  {

--Signature=_Tue__24_Sep_2013_12_16_29_+1000_e=XcjafQ3mHIc/b7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSQPYBAAoJEECxmPOUX5FEAAkP/RTzkYo+TecOO+NmvGDnQ/eC
cyti2nnNXJgxGVD7B9fdJgk1KQCedXvYR5OxkIe02FR984r431WPwlQ+rV0Ti4D5
lBUlC/gWfKTeZSuWzCjohmgdeDIBwuURgYrf0XXQR5ktPGx9izvjkr24e7WWBanD
OsNNL9T8osg8nBECvDwhiLrsA6Th67lWsYtDNdSq0gwoNih+RecUpU+MlQ4STI7v
h9ND22Thyb01ywLC19jHKSvVHtBD8DlTO+8nyqF/VCA81W2gTSUcmwKk7wQufwbL
uvfsHEw0IF7NcOs/2SiLSMFNNqku1hhtqiGEhAOlUTmSEWhh2epvEEjKYmNaqnF3
HfcN4OcjlX35plJf9LjzzCpzK2nLtzaPxizaw6G+bucmQKJTzAY7tB12pDd4cfom
6xGtq0c5Ii9KZGwlIiGUqZI2l5PRRHSBvGNBmLwbpIsiWGp8NhqwNk5oSt448/yE
5GiTj3vrKra6mEugYtbpNtJgqrYcrEvgN2Ff6xvtGasmhxwY2Oi9Bp9RFroIckji
FsCh6Rk+34Rfar/oZCXAOsOjCppN4ZXVF2UQ1xRUAVh0Ak+JBeZxbBZuR84TM34q
u1+AEfxPUxO1JUURKkJbaY7DrrYhBVLGwhG7I+pPpxJfB1oTWAuOhb4I8SNX+yMo
5jSbOH8lsJ8vJ8O7eaCC
=mWrv
-----END PGP SIGNATURE-----

--Signature=_Tue__24_Sep_2013_12_16_29_+1000_e=XcjafQ3mHIc/b7--
