From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 15 Jan 2015 13:47:35 +1100
Message-ID: <20150115134735.1e4612c6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/oZs.80FKNEj1RzEYMAS6ixp"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Vrabel <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/oZs.80FKNEj1RzEYMAS6ixp
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/xen-netfront.c between commit 900e183301b5 ("xen-netfront:
use different locks for Rx and Tx stats") from the net tree and commit
a55e8bb8fb89 ("xen-netfront: refactor making Tx requests") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/xen-netfront.c
index d8c10764f130,01a4350eb313..000000000000
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@@ -562,18 -518,15 +517,15 @@@ static u16 xennet_select_queue(struct n
 =20
  static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
  {
- 	unsigned short id;
  	struct netfront_info *np =3D netdev_priv(dev);
 -	struct netfront_stats *stats =3D this_cpu_ptr(np->stats);
 +	struct netfront_stats *tx_stats =3D this_cpu_ptr(np->tx_stats);
- 	struct xen_netif_tx_request *tx;
- 	char *data =3D skb->data;
- 	RING_IDX i;
- 	grant_ref_t ref;
- 	unsigned long mfn;
+ 	struct xen_netif_tx_request *tx, *first_tx;
+ 	unsigned int i;
  	int notify;
  	int slots;
- 	unsigned int offset =3D offset_in_page(data);
- 	unsigned int len =3D skb_headlen(skb);
+ 	struct page *page;
+ 	unsigned int offset;
+ 	unsigned int len;
  	unsigned long flags;
  	struct netfront_queue *queue =3D NULL;
  	unsigned int num_queues =3D dev->real_num_tx_queues;

--Sig_/oZs.80FKNEj1RzEYMAS6ixp
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUtypPAAoJEMDTa8Ir7ZwVkcYP/1vLa6WhxEaf0bx1uORWbj+X
Ge2oxR79aYJs7fiD5Ps6Pe/SUUhB6rukBk9OQbidsc3Fk1A+TdmNOm8wI+vnoNmQ
G/DV3wB3nbGJoOVBZR27I4BlLGJKlqv+gw2gPiRYfFAQz1VSiuyjwrVJlkfxmIxC
QfkLaxHGV2Ccv0hsMLKougFuck0EsiYIYPpE6YMpX4qJAoNml/hCBGYFiEJOe6/h
pfoSg2zjyiR7PVSlGe4IJ4WpXLIRAWuPiXK+3mWpCqo/hpB4Ke2P2m5UZoFmvUsa
Ja24UfXQ8BZuNUU3ewqLoMCRX5uOn2KcEDfQdKnx6rju/4vYk0Kuka1TYn2onQZS
dIQl3q6YWpngpwc/qJlYwV8oFUk/23PxL/zjHfaJanGELM1sUInfPGao0K9vG786
ksMtXkxuJ7X5awj35d3+vWb5z9h1o5gyAib69ILW++iJfl5LfJtm+VUyW7w9DLOM
uhvesTkZaQSfnqs/BUClyencELim6b8seugXX0lx/ThMguG2zHCMC3DecmrzrBCn
ZsHs8xVC8eKu9Dr96HhTnlM02ATsGN7LQnxTt8YwvfqnvN1gF0jnm7LwMcDKKs9+
lX8XHzbZtgXrWGxPS6MPrQDRdwdksLTjvSCvjpf1wMfjMcnlbKDdBh8Je4W4KFw/
T3cDqIbQJ/Lh7r6mx6L5
=E0ux
-----END PGP SIGNATURE-----

--Sig_/oZs.80FKNEj1RzEYMAS6ixp--
