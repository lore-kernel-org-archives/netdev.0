From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 04/15] net/mlx5: Add PCIe outbound stalls counters infrastructure
Date: Sun, 20 Aug 2017 16:49:05 +0300
Message-ID: <20170820134916.10222-5-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44767 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751814AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add capability bit in MCAM register and counters to MPCNT register.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index c99daffc3c3c..ba533b39c885 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1854,7 +1854,17 @@ struct mlx5_ifc_pcie_perf_cntrs_grp_data_layout_bits {
 
 	u8         crc_error_tlp[0x20];
 
-	u8         reserved_at_140[0x680];
+	u8         reserved_at_140[0x40];
+
+	u8         outbound_stalled_reads[0x20];
+
+	u8         outbound_stalled_writes[0x20];
+
+	u8         outbound_stalled_reads_events[0x20];
+
+	u8         outbound_stalled_writes_events[0x20];
+
+	u8         reserved_at_200[0x5c0];
 };
 
 struct mlx5_ifc_cmd_inter_comp_event_bits {
@@ -7744,8 +7754,9 @@ struct mlx5_ifc_pcam_reg_bits {
 };
 
 struct mlx5_ifc_mcam_enhanced_features_bits {
-	u8         reserved_at_0[0x7d];
-
+	u8         reserved_at_0[0x7b];
+	u8         pcie_outbound_stalled[0x1];
+	u8         reserved_at_7c[0x1];
 	u8         mtpps_enh_out_per_adj[0x1];
 	u8         mtpps_fs[0x1];
 	u8         pcie_performance_group[0x1];
-- 
2.13.0
