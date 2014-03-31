From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 31 Mar 2014 13:34:35 +1100
Message-ID: <20140331133435.67c5f41ea2e1f918730ebbe8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__31_Mar_2014_13_34_35_+1100_=MHuiIRQxQDztSCW"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__31_Mar_2014_13_34_35_+1100_=MHuiIRQxQDztSCW
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/xen-netback/netback.c between commit 1425c7a4e8d3
("xen-netback: BUG_ON in xenvif_rx_action() not catching overflow") from
the net tree and commit 8f13dd961228 ("xen-netback: Use skb->cb for
pending_idx") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/xen-netback/netback.c
index cd0bd95ccc14,cb784fe5220c..000000000000
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@@ -531,13 -539,8 +560,11 @@@ static void xenvif_rx_action(struct xen
  		} else
  			vif->rx_last_skb_slots =3D 0;
 =20
- 		sco =3D (struct skb_cb_overlay *)skb->cb;
-=20
 +		old_req_cons =3D vif->rx.req_cons;
- 		sco->meta_slots_used =3D xenvif_gop_skb(skb, &npo);
+ 		XENVIF_RX_CB(skb)->meta_slots_used =3D xenvif_gop_skb(skb, &npo);
 -		BUG_ON(XENVIF_RX_CB(skb)->meta_slots_used > max_slots_needed);
 +		ring_slots_used =3D vif->rx.req_cons - old_req_cons;
 +
 +		BUG_ON(ring_slots_used > max_slots_needed);
 =20
  		__skb_queue_tail(&rxq, skb);
  	}

--Signature=_Mon__31_Mar_2014_13_34_35_+1100_=MHuiIRQxQDztSCW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTONRAAAoJEMDTa8Ir7ZwVe+0P/2ZSRiHsOT/p2NvodlgkI8aM
AYIf9zp/j5yVkbEfmG3eaiEtjasb1RSr9zSb3yuZNDp8BDzHcONZFhAIlLVDVv07
cU/GCBnzr2H+OTeHvw3ej5oDYS5n00kexrxNKeLYW0iepyhZzjHe5otIwYb7ZWEw
MqRW/1d4xysLZnKYFgZVyIvuOBihy0ZyN7p7i6fLLrD0ybpeEatLF39gprzFN1gi
JrjATXzgif/0locUODKf+O8qxJESv+S7EzPGw3TpgaHgZkshRQygOgDWSls+/BW0
ScGO3gFNBfg7DjtNSzDTc4y2H99QxVeiU2HQ/IpCZpYgJqcLkVY+ZeXHfrxCx5bv
dZ3yfHPBQUQJ/wBKplPHZL1piLLOhSxHA/eEmSsKno20AnDboi0E//Tdo4Z01iag
MCrUhKlU9jcnn8s015puN+Z9GwhSf4nrtnY6OnPhZqzs2fL1p99HfqyR+SNNL7+1
DuMRTHmUb3498f85VFlhQPbk2BmuhRQ8VR1/vDoj8GwFHTSIAtB1FEA5yZA9aEmc
1MGdJLUYXZu7WtNDCGcV/eP5lIg/bTmZ3rqZlVe/0eFb24PGQ2s1bNcC4qtwDqlg
u04LuYbinAbgr7484xOJo7v/81gjQ90o+LjXYMvbhHuAFd0KGkVo0HI//HI6wWhP
wwnpEL/cKZt0ZZb3xZdR
=wFVR
-----END PGP SIGNATURE-----

--Signature=_Mon__31_Mar_2014_13_34_35_+1100_=MHuiIRQxQDztSCW--
