From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] iaf_packet: use BUG_ON
Date: Wed, 9 Jul 2014 03:50:23 +0530
Message-ID: <20140708222023.GA11829@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON(x) rather than if(x) BUG();

The semantic patch that fixes this problem is as follows:

// <smpl>
@@ identifier x; @@
-if (x) BUG();
+BUG_ON(x);
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: "David S. Miller" <davem@davemloft.net>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 net/packet/af_packet.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b85c67c..cda8552 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -551,8 +551,7 @@ static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
 {
 	struct tpacket_kbdq_core *pkc;
 
-	if (tx_ring)
-		BUG();
+	BUG_ON(tx_ring);
 
 	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
 			GET_PBDQC_FROM_RB(&po->rx_ring);
-- 
1.9.1
