From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 04/11] net/mlx5: Support new MR features
Date: Sun,  1 Jan 2017 23:10:20 +0200
Message-ID: <1483305027-2573-5-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42844 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932465AbdAAVKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 16:10:50 -0500
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

This patch adds the following items to IFC file.

1. MLX5_MKC_ACCESS_MODE_KSM enum value for creating KSM memory keys.
KSM access mode used when indirect MKey associated with fixed memory
size entries.

2. null_mkey field that is used to indicate non-present KLM/KSM
entries, where it causes the device to generate page fault event
when trying to access it.

3. struct mlx5_ifc_cmd_hca_cap_bits capability bits indicating
related value/field is supported:
* fixed_buffer_size - MLX5_MKC_ACCESS_MODE_KSM
* umr_extended_translation_offset - translation_offset_42_16
    in UMR ctrl segment
* null_mkey - null_mkey in QUERY_SPECIAL_CONTEXTS

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 4792c85..7c760e5 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -782,11 +782,12 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         log_max_eq[0x4];
 
 	u8         max_indirection[0x8];
-	u8         reserved_at_108[0x1];
+	u8         fixed_buffer_size[0x1];
 	u8         log_max_mrw_sz[0x7];
 	u8         reserved_at_110[0x2];
 	u8         log_max_bsf_list_size[0x6];
-	u8         reserved_at_118[0x2];
+	u8         umr_extended_translation_offset[0x1];
+	u8         null_mkey[0x1];
 	u8         log_max_klm_list_size[0x6];
 
 	u8         reserved_at_120[0xa];
@@ -2569,6 +2570,7 @@ enum {
 	MLX5_MKC_ACCESS_MODE_PA    = 0x0,
 	MLX5_MKC_ACCESS_MODE_MTT   = 0x1,
 	MLX5_MKC_ACCESS_MODE_KLMS  = 0x2,
+	MLX5_MKC_ACCESS_MODE_KSM   = 0x3,
 };
 
 struct mlx5_ifc_mkc_bits {
@@ -3677,6 +3679,10 @@ struct mlx5_ifc_query_special_contexts_out_bits {
 	u8         dump_fill_mkey[0x20];
 
 	u8         resd_lkey[0x20];
+
+	u8         null_mkey[0x20];
+
+	u8         reserved_at_a0[0x60];
 };
 
 struct mlx5_ifc_query_special_contexts_in_bits {
-- 
2.7.4
