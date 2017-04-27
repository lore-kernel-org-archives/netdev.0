From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 3/3] bnx2x: Get rid of useless temporary variable
Date: Thu, 27 Apr 2017 16:37:01 +0300
Message-ID: <20170427133701.72701-3-andriy.shevchenko@linux.intel.com>
References: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:51616 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752094AbdD0NhG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 09:37:06 -0400
In-Reply-To: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>

Replace pattern

 int status;
 ...
 status = func(...);
 return status;

by

 return func(...);

No functional change intented.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 6d11a958200f..7dd83d0ef0a0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10618,22 +10618,19 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 
 static int bnx2x_8485x_format_ver(u32 raw_ver, u8 *str, u16 *len)
 {
-	int status = 0;
 	u32 num;
 
 	num = ((raw_ver & 0xF80) >> 7) << 16 | ((raw_ver & 0x7F) << 8) |
 	      ((raw_ver & 0xF000) >> 12);
-	status = bnx2x_3_seq_format_ver(num, str, len);
-	return status;
+	return bnx2x_3_seq_format_ver(num, str, len);
 }
 
 static int bnx2x_848xx_format_ver(u32 raw_ver, u8 *str, u16 *len)
 {
-	int status = 0;
 	u32 spirom_ver;
+
 	spirom_ver = ((raw_ver & 0xF80) >> 7) << 16 | (raw_ver & 0x7F);
-	status = bnx2x_format_ver(spirom_ver, str, len);
-	return status;
+	return bnx2x_format_ver(spirom_ver, str, len);
 }
 
 static void bnx2x_8481_hw_reset(struct bnx2x_phy *phy,
@@ -12484,13 +12481,12 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 static int bnx2x_populate_phy(struct bnx2x *bp, u8 phy_index, u32 shmem_base,
 			      u32 shmem2_base, u8 port, struct bnx2x_phy *phy)
 {
-	int status = 0;
 	phy->type = PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN;
 	if (phy_index == INT_PHY)
 		return bnx2x_populate_int_phy(bp, shmem_base, port, phy);
-	status = bnx2x_populate_ext_phy(bp, phy_index, shmem_base, shmem2_base,
+
+	return bnx2x_populate_ext_phy(bp, phy_index, shmem_base, shmem2_base,
 					port, phy);
-	return status;
 }
 
 static void bnx2x_phy_def_cfg(struct link_params *params,
-- 
2.11.0
