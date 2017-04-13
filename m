From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/16] net/mlx5: Add IPoIB enhanced offloads bits to mlx5_ifc
Date: Thu, 13 Apr 2017 06:36:51 +0300
Message-ID: <20170413033706.19016-2-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41681 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756050AbdDMDhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:37:43 -0400
In-Reply-To: <20170413033706.19016-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

New capability bit: ipoib_enhanced_offloads, indicates new ability for UD
QP to do RSS and enhanced IPoIB offloads and acceleration.

Add underlay_qpn to the TIS and flow_table objects In order to support
SET_ROOT command, to connect between IPoIB QPs and flow steering tables.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 1993adbd2c82..7c50bd39b297 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -872,7 +872,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 
 	u8         compact_address_vector[0x1];
 	u8         striding_rq[0x1];
-	u8         reserved_at_202[0x2];
+	u8         reserved_at_202[0x1];
+	u8         ipoib_enhanced_offloads[0x1];
 	u8         ipoib_basic_offloads[0x1];
 	u8         reserved_at_205[0xa];
 	u8         drain_sigerr[0x1];
@@ -2293,7 +2294,9 @@ struct mlx5_ifc_tisc_bits {
 	u8         reserved_at_120[0x8];
 	u8         transport_domain[0x18];
 
-	u8         reserved_at_140[0x3c0];
+	u8         reserved_at_140[0x8];
+	u8         underlay_qpn[0x18];
+	u8         reserved_at_160[0x3a0];
 };
 
 enum {
@@ -8218,7 +8221,9 @@ struct mlx5_ifc_set_flow_table_root_in_bits {
 	u8         reserved_at_a0[0x8];
 	u8         table_id[0x18];
 
-	u8         reserved_at_c0[0x140];
+	u8         reserved_at_c0[0x8];
+	u8         underlay_qpn[0x18];
+	u8         reserved_at_e0[0x120];
 };
 
 enum {
-- 
2.11.0
