From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] igb: use ARRAY_SIZE to replace calculating sizeof(a)/sizeof(a[0])
Date: Thu, 23 Jul 2015 06:52:33 -0700
Message-ID: <1437659564-48822-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55273 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbbGWNwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:50 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Use the ARRAY_SIZE macro rather than calculating sizeof(a)/sizeof(a[0]).
Also directly replace the code rather than using an unnecessary define.

Reported-by: Maninder Singh <maninder1.s@samsung.com>
Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c1bb64d..987c9de 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1,5 +1,5 @@
 /* Intel(R) Gigabit Ethernet Linux driver
- * Copyright(c) 2007-2014 Intel Corporation.
+ * Copyright(c) 2007-2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -36,9 +36,6 @@ static s32  igb_set_master_slave_mode(struct e1000_hw *hw);
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] = {
 	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
-#define M88E1000_CABLE_LENGTH_TABLE_SIZE \
-	(sizeof(e1000_m88_cable_length_table) / \
-	sizeof(e1000_m88_cable_length_table[0]))
 
 static const u16 e1000_igp_2_cable_length_table[] = {
 	0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
@@ -49,9 +46,6 @@ static const u16 e1000_igp_2_cable_length_table[] = {
 	60, 66, 72, 77, 82, 87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121,
 	83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
 	104, 109, 114, 118, 121, 124};
-#define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
-	(sizeof(e1000_igp_2_cable_length_table) / \
-	 sizeof(e1000_igp_2_cable_length_table[0]))
 
 /**
  *  igb_check_reset_block - Check if PHY reset is blocked
@@ -1700,7 +1694,7 @@ s32 igb_get_cable_length_m88(struct e1000_hw *hw)
 
 	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
 		M88E1000_PSSR_CABLE_LENGTH_SHIFT;
-	if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE - 1) {
+	if (index >= ARRAY_SIZE(e1000_m88_cable_length_table) - 1) {
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -1796,7 +1790,7 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 
 		index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
 			M88E1000_PSSR_CABLE_LENGTH_SHIFT;
-		if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE - 1) {
+		if (index >= ARRAY_SIZE(e1000_m88_cable_length_table) - 1) {
 			ret_val = -E1000_ERR_PHY;
 			goto out;
 		}
@@ -1840,7 +1834,7 @@ s32 igb_get_cable_length_igp_2(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	u16 phy_data, i, agc_value = 0;
 	u16 cur_agc_index, max_agc_index = 0;
-	u16 min_agc_index = IGP02E1000_CABLE_LENGTH_TABLE_SIZE - 1;
+	u16 min_agc_index = ARRAY_SIZE(e1000_igp_2_cable_length_table) - 1;
 	static const u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] = {
 		IGP02E1000_PHY_AGC_A,
 		IGP02E1000_PHY_AGC_B,
@@ -1863,7 +1857,7 @@ s32 igb_get_cable_length_igp_2(struct e1000_hw *hw)
 				IGP02E1000_AGC_LENGTH_MASK;
 
 		/* Array index bound check. */
-		if ((cur_agc_index >= IGP02E1000_CABLE_LENGTH_TABLE_SIZE) ||
+		if ((cur_agc_index >= ARRAY_SIZE(e1000_igp_2_cable_length_table)) ||
 		    (cur_agc_index == 0)) {
 			ret_val = -E1000_ERR_PHY;
 			goto out;
-- 
2.4.3
