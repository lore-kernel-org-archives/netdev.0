From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/3] net/mlx4_en: Don't use vlan tag value as an indication for vlan presence
Date: Thu, 25 Oct 2012 13:12:48 +0200
Message-ID: <1351163569-17132-3-git-send-email-ogerlitz@mellanox.com>
References: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Moni Shoua <monis@mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:42965 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757905Ab2JYLM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 07:12:57 -0400
In-Reply-To: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.co.il>

The vlan tag can be zero. This is why it can't serve as an indication
that packet requires VLAN header in the TX flow.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 0a51095..b35094c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -711,7 +711,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bounce)
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
 
-	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tag) {
+	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tx_tag_present(skb)) {
 		*(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
 		op_own |= htonl((bf_index & 0xffff) << 8);
 		/* Ensure new descirptor hits memory
-- 
1.7.1
