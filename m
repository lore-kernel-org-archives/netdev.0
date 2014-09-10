From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/4] net/mlx4: Use the correct VSD mask in UPDATE_QP
Date: Wed, 10 Sep 2014 16:41:54 +0300
Message-ID: <1410356516-23594-3-git-send-email-ogerlitz@mellanox.com>
References: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45902 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750925AbaIJNmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:42:10 -0400
In-Reply-To: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

When doing VGT->VST->VGT state changes, we used an incorrect mask
for the vlan-stripping-disable (VSD) flag, hence the vlan related policy
for user-space Raw Ethernet QPs open by VFs wasn't really applied.

Fix that, by using the correct mask.

Fixes: f0f829b ('net/mlx4_core: Add immediate activate for VGT->VST->VGT')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 1089367..f87a4a3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4818,7 +4818,7 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 			MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
 
 	upd_context = mailbox->buf;
-	upd_context->qp_mask = cpu_to_be64(MLX4_UPD_QP_MASK_VSD);
+	upd_context->qp_mask = cpu_to_be64(1ULL << MLX4_UPD_QP_MASK_VSD);
 
 	spin_lock_irq(mlx4_tlock(dev));
 	list_for_each_entry_safe(qp, tmp, qp_list, com.list) {
-- 
1.7.1
