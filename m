From: Amir Vadai <amirv@dev.mellanox.co.il>
Subject: [PATCH 3/3] net/mlx4_en: bug fix for the case of vlan id 0 and UP 0
Date: Tue, 15 Nov 2011 11:14:06 +0200
Message-ID: <1321348446-29605-4-git-send-email-amirv@mellanox.com>
References: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Oren Duer <oren@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58272 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391Ab1KOJOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 04:14:38 -0500
Received: by mail-bw0-f46.google.com with SMTP id 11so6906612bke.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 01:14:37 -0800 (PST)
In-Reply-To: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

When using vlan 0 and UP 0, vlan header wasn't placed.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 9b4ca4c..150383e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -565,7 +565,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 		inl->byte_count = cpu_to_be32(1 << 31 | (skb->len - spc));
 	}
 	tx_desc->ctrl.vlan_tag = cpu_to_be16(*vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!(*vlan_tag);
+	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * (!!vlan_tx_tag_present(skb));
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 }
 
@@ -676,7 +676,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Prepare ctrl segement apart opcode+ownership, which depends on
 	 * whether LSO is used */
 	tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!vlan_tag;
+	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!vlan_tx_tag_present(skb);
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 						MLX4_WQE_CTRL_SOLICITED);
-- 
1.7.5.4
