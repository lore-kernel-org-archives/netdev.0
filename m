From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V3 4/5] net/mlx4_en: Support software timestamping
Date: Tue, 23 Apr 2013 19:06:50 +0300
Message-ID: <1366733211-10228-5-git-send-email-amirv@mellanox.com>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:60518 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932168Ab3DWQHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 12:07:00 -0400
In-Reply-To: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel software timestamping requires that the driver calls skb_tx_timestamp
just before passing the skb to the HW MAC layer. This patch adds this call.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index b0a2d2b..4e6877a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -752,6 +752,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bounce)
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
 
+	skb_tx_timestamp(skb);
+
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tx_tag_present(skb)) {
 		*(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
 		op_own |= htonl((bf_index & 0xffff) << 8);
-- 
1.7.8.2
