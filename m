From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Make a few functions static
Date: Wed, 08 Aug 2007 10:22:11 -0700
Message-ID: <20070808172211.12242.44053.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4557 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937623AbXHHRWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 13:22:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After moving code around we can reduce namespace usage
by making a few functions static.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h  |    2 --
 drivers/net/e1000e/lib.c    |    2 +-
 drivers/net/e1000e/netdev.c |    2 +-
 drivers/net/e1000e/phy.c    |   10 ++++++----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 65c31d3..a1394d6 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -365,7 +365,6 @@ extern struct e1000_info e1000_ich9_info;
 extern struct e1000_info e1000_es2_info;
 
 extern s32  e1000_commit_phy(struct e1000_hw *hw);
-extern s32  e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
 
 extern bool e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 
@@ -438,7 +437,6 @@ extern s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success);
 extern s32 e1000_phy_reset_dsp(struct e1000_hw *hw);
 extern s32 e1000_check_downshift(struct e1000_hw *hw);
-extern s32 e1000_wait_autoneg(struct e1000_hw *hw);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index d11b518..3bbe63e 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2289,7 +2289,7 @@ bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
  *
  *  Writes the command header after does the checksum calculation.
  **/
-s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
+static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
 				  struct e1000_host_mng_command_header *hdr)
 {
 	u16 i, length = sizeof(struct e1000_host_mng_command_header);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c8d50cc..dd4eca6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -48,7 +48,7 @@
 char e1000_driver_name[] = "e1000e";
 const char e1000_driver_version[] = DRV_VERSION;
 
-const struct e1000_info * e1000_info_tbl[] = {
+static const struct e1000_info *e1000_info_tbl[] = {
 	[board_82571]		= &e1000_82571_info,
 	[board_82572]		= &e1000_82572_info,
 	[board_82573]		= &e1000_82573_info,
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index d7947b0..1ccbad7 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -28,8 +28,10 @@
 
 #include "e1000.h"
 
-static s32  e1000_get_phy_cfg_done(struct e1000_hw *hw);
-static s32  e1000_phy_force_speed_duplex(struct e1000_hw *hw);
+static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
+static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
+static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
+static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
@@ -1281,7 +1283,7 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
  *  Waits for auto-negotiation to complete or for the auto-negotiation time
  *  limit to expire, which ever happens first.
  **/
-s32 e1000_wait_autoneg(struct e1000_hw *hw)
+static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
 	u16 i, phy_status;
@@ -1760,7 +1762,7 @@ s32 e1000_commit_phy(struct e1000_hw *hw)
  *  During driver activity, SmartSpeed should be enabled so performance is
  *  maintained.  This is a function pointer entry point called by drivers.
  **/
-s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
+static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 {
 	if (hw->phy.ops.set_d0_lplu_state)
 		return hw->phy.ops.set_d0_lplu_state(hw, active);
