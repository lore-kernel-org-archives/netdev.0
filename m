From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/2] e1000e: Add Jumbo Frame support to 82583 devices
Date: Tue, 12 Jul 2011 19:10:11 -0700
Message-ID: <1310523012-25391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26837 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756842Ab1GMCKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 22:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds support for the Jumbo Frames feature on 82583 devices.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 8295f21..480f259 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -431,8 +431,6 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
 	case e1000_82573:
-	case e1000_82574:
-	case e1000_82583:
 		if (pdev->device == E1000_DEV_ID_82573L) {
 			adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
 			adapter->max_hw_frame_size = DEFAULT_JUMBO;
@@ -2104,10 +2102,11 @@ struct e1000_info e1000_82583_info = {
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
+				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.flags2			= FLAG2_DISABLE_ASPM_L0S,
 	.pba			= 32,
-	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_bm,
-- 
1.7.6

