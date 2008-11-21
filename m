From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 09/14] e1000e: fix possible buffer overflow
Date: Fri, 21 Nov 2008 11:01:28 -0800
Message-ID: <20081121190128.32313.90707.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:37002 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757409AbYKUTBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:01:52 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Put in missing bounds checking of an array.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/es2lan.c |    5 +++++
 drivers/net/e1000e/phy.c    |    5 +++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index db51114..b5250fd 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -104,6 +104,8 @@
  */
 static const u16 e1000_gg82563_cable_length_table[] =
 	 { 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
+#define GG82563_CABLE_LENGTH_TABLE_SIZE \
+		ARRAY_SIZE(e1000_gg82563_cable_length_table)
 
 static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw);
 static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask);
@@ -721,6 +723,9 @@ static s32 e1000_get_cable_length_80003es2lan(struct e1000_hw *hw)
 		return ret_val;
 
 	index = phy_data & GG82563_DSPD_CABLE_LENGTH;
+	if (index >= GG82563_CABLE_LENGTH_TABLE_SIZE + 5)
+		return E1000_ERR_PHY;
+
 	phy->min_cable_length = e1000_gg82563_cable_length_table[index];
 	phy->max_cable_length = e1000_gg82563_cable_length_table[index+5];
 
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index cb7d71e..d3aa6b7 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -41,6 +41,8 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
 	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+#define M88E1000_CABLE_LENGTH_TABLE_SIZE \
+		ARRAY_SIZE(e1000_m88_cable_length_table)
 
 static const u16 e1000_igp_2_cable_length_table[] =
 	{ 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, 0, 0, 0, 3,
@@ -1442,6 +1444,9 @@ s32 e1000e_get_cable_length_m88(struct e1000_hw *hw)
 
 	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
 		M88E1000_PSSR_CABLE_LENGTH_SHIFT;
+	if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE + 1)
+		return E1000_ERR_PHY;
+
 	phy->min_cable_length = e1000_m88_cable_length_table[index];
 	phy->max_cable_length = e1000_m88_cable_length_table[index+1];
 

