From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/3] drivers/net: convert BUG_TRAP to generic WARN_ON
Date: Fri, 25 Jul 2008 15:46:58 +0300
Message-ID: <1216990020-2716-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45539 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbYGYMrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:47:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes legacy reinvent-the-wheel type thing. The generic
machinery integrates much better to automated debugging aids
such as kerneloops.org (and others), and is unambiguous due to
better naming. Non-intuively BUG_TRAP() is actually equal to
WARN_ON() rather than BUG_ON().

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/bnx2x_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0263bef..93c9503 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -814,7 +814,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, stru=
ct bnx2x_fastpath *fp,
 	}
=20
 	/* release skb */
-	BUG_TRAP(skb);
+	WARN_ON(!skb);
 	dev_kfree_skb(skb);
 	tx_buf->first_bd =3D 0;
 	tx_buf->skb =3D NULL;
@@ -837,9 +837,9 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastp=
ath *fp)
 	used =3D SUB_S16(prod, cons) + (s16)NUM_TX_RINGS;
=20
 #ifdef BNX2X_STOP_ON_ERROR
-	BUG_TRAP(used >=3D 0);
-	BUG_TRAP(used <=3D fp->bp->tx_ring_size);
-	BUG_TRAP((fp->bp->tx_ring_size - used) <=3D MAX_TX_AVAIL);
+	WARN_ON(used < 0);
+	WARN_ON(used > fp->bp->tx_ring_size);
+	WARN_ON((fp->bp->tx_ring_size - used) > MAX_TX_AVAIL);
 #endif
=20
 	return (s16)(fp->bp->tx_ring_size) - used;
@@ -4374,7 +4374,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 			}
 			ring_prod =3D NEXT_RX_IDX(ring_prod);
 			cqe_ring_prod =3D NEXT_RCQ_IDX(cqe_ring_prod);
-			BUG_TRAP(ring_prod > i);
+			WARN_ON(ring_prod <=3D i);
 		}
=20
 		fp->rx_bd_prod =3D ring_prod;
--=20
1.5.2.2

