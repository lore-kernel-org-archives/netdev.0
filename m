From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 09/12] net/mlx5_core: Make ipv4/ipv6 location more clear
Date: Wed,  6 Jan 2016 23:52:28 +0200
Message-ID: <1452117151-28572-10-git-send-email-saeedm@mellanox.com>
References: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Moni Shoua <monis@mellanox.com>, saeedm@dev.mellanox.co.il,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43928 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752399AbcAFVyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 16:54:00 -0500
In-Reply-To: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Change the mlx5 firmware interface header to make it
more clear which bytes should be used by IPv4 or
IPv6 addresses.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 7f16695..68d73f8 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -298,6 +298,22 @@ struct mlx5_ifc_odp_per_transport_service_cap_bits {
 	u8         reserved_1[0x1a];
 };
 
+struct mlx5_ifc_ipv4_layout_bits {
+	u8         reserved_0[0x60];
+
+	u8         ipv4[0x20];
+};
+
+struct mlx5_ifc_ipv6_layout_bits {
+	u8         ipv6[16][0x8];
+};
+
+union mlx5_ifc_ipv6_layout_ipv4_layout_auto_bits {
+	struct mlx5_ifc_ipv6_layout_bits ipv6_layout;
+	struct mlx5_ifc_ipv4_layout_bits ipv4_layout;
+	u8         reserved_0[0x80];
+};
+
 struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
 	u8         smac_47_16[0x20];
 
@@ -328,9 +344,9 @@ struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
 	u8         udp_sport[0x10];
 	u8         udp_dport[0x10];
 
-	u8         src_ip[4][0x20];
+	union mlx5_ifc_ipv6_layout_ipv4_layout_auto_bits src_ipv4_src_ipv6;
 
-	u8         dst_ip[4][0x20];
+	union mlx5_ifc_ipv6_layout_ipv4_layout_auto_bits dst_ipv4_dst_ipv6;
 };
 
 struct mlx5_ifc_fte_match_set_misc_bits {
-- 
1.7.1
