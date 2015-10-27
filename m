From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Explicitly set no vlan tags in WQE ctrl segment when no vlan is present
Date: Tue, 27 Oct 2015 17:36:19 +0200
Message-ID: <1445960180-3450-2-git-send-email-ogerlitz@mellanox.com>
References: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45130 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750877AbbJ0Pgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 11:36:49 -0400
In-Reply-To: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

We do not set the ins_vlan field to zero when no vlan id is present in the packet.

Since WQEs in the TX ring are not zeroed out between uses, this oversight
could result in having vlan flags present in the WQE ctrl segment when no
vlan is preset.

Fixes: e38af4faf01d ('net/mlx4_en: Add support for hardware accelerated 802.1ad vlan')
Reported-by: Gideon Naim <gideonn@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 494e776..4421bf5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -964,6 +964,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_SVLAN;
 		else if (vlan_proto == ETH_P_8021Q)
 			tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_CVLAN;
+		else
+			tx_desc->ctrl.ins_vlan = 0;
 
 		tx_desc->ctrl.fence_size = real_size;
 
-- 
2.3.7
