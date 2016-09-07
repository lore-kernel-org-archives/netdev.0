From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/5] net/mlx5e: Move an_disable_cap bit to a new position
Date: Wed,  7 Sep 2016 19:07:58 +0300
Message-ID: <1473264481-20392-3-git-send-email-saeedm@mellanox.com>
References: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Bodong Wang <bodong@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58425 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751237AbcIGQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:08:36 -0400
In-Reply-To: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bodong Wang <bodong@mellanox.com>

Previous an_disable_cap position bit31 is deprecated to be use in driver
with newer firmware.  New firmware will advertise the same capability
in bit29.

Old capability didn't allow setting more than one protocol for a
specific speed when autoneg is off, while newer firmware will allow
this and it is indicated in the new capability location.

Signed-off-by: Bodong Wang <bodong@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 21bc455..d1f9a58 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -6710,9 +6710,10 @@ struct mlx5_ifc_pude_reg_bits {
 };
 
 struct mlx5_ifc_ptys_reg_bits {
-	u8         an_disable_cap[0x1];
+	u8         reserved_at_0[0x1];
 	u8         an_disable_admin[0x1];
-	u8         reserved_at_2[0x6];
+	u8         an_disable_cap[0x1];
+	u8         reserved_at_3[0x5];
 	u8         local_port[0x8];
 	u8         reserved_at_10[0xd];
 	u8         proto_mask[0x3];
-- 
2.7.4
