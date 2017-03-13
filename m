From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 07/25] linux/mlx5/mlx5_ifc.h: Add underlay_qpn field to PRM objects
Date: Mon, 13 Mar 2017 20:31:18 +0200
Message-ID: <1489429896-10781-8-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49720 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752871AbdCMScB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:01 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add to the TIS and flow_table objects, and to hca capability table.

1. New capability bit: ipoib_enhanced_offloads, indicates new ability for UD
QP to do RSS.
2. In order to support SET_ROOT cmd, to connect between QP to FS table.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 2d197d8a7025..afb6c8ab156a 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -859,7 +859,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 
 	u8         compact_address_vector[0x1];
 	u8         striding_rq[0x1];
-	u8         reserved_at_202[0x2];
+	u8         reserved_at_202[0x1];
+	u8         ipoib_enhanced_offloads[0x1];
 	u8         ipoib_basic_offloads[0x1];
 	u8         reserved_at_205[0xa];
 	u8         drain_sigerr[0x1];
@@ -2217,7 +2218,9 @@ struct mlx5_ifc_tisc_bits {
 	u8         reserved_at_120[0x8];
 	u8         transport_domain[0x18];
 
-	u8         reserved_at_140[0x3c0];
+	u8         reserved_at_140[0x8];
+	u8         underlay_qpn[0x18];
+	u8         reserved_at_160[0x3a0];
 };
 
 enum {
@@ -7906,7 +7909,9 @@ struct mlx5_ifc_set_flow_table_root_in_bits {
 	u8         reserved_at_a0[0x8];
 	u8         table_id[0x18];
 
-	u8         reserved_at_c0[0x140];
+	u8         reserved_at_c0[0x8];
+	u8         underlay_qpn[0x18];
+	u8         reserved_at_e0[0x120];
 };
 
 enum {
-- 
1.8.3.1
