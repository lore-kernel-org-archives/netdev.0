From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/5] e1000e: don't accumulate PHY statistics on PHY
	read failure
Date: Thu, 07 Jan 2010 18:31:16 -0800
Message-ID: <20100108023115.31476.56779.stgit@localhost.localdomain>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:51272
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752714Ab0AHCbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 21:31:34 -0500
In-Reply-To: <20100108023033.31476.4034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 10aa0ec..c45965a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3315,24 +3315,24 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	if ((hw->phy.type == e1000_phy_82578) ||
 	    (hw->phy.type == e1000_phy_82577)) {
 		e1e_rphy(hw, HV_SCC_UPPER, &phy_data);
-		e1e_rphy(hw, HV_SCC_LOWER, &phy_data);
-		adapter->stats.scc += phy_data;
+		if (!e1e_rphy(hw, HV_SCC_LOWER, &phy_data))
+			adapter->stats.scc += phy_data;
 
 		e1e_rphy(hw, HV_ECOL_UPPER, &phy_data);
-		e1e_rphy(hw, HV_ECOL_LOWER, &phy_data);
-		adapter->stats.ecol += phy_data;
+		if (!e1e_rphy(hw, HV_ECOL_LOWER, &phy_data))
+			adapter->stats.ecol += phy_data;
 
 		e1e_rphy(hw, HV_MCC_UPPER, &phy_data);
-		e1e_rphy(hw, HV_MCC_LOWER, &phy_data);
-		adapter->stats.mcc += phy_data;
+		if (!e1e_rphy(hw, HV_MCC_LOWER, &phy_data))
+			adapter->stats.mcc += phy_data;
 
 		e1e_rphy(hw, HV_LATECOL_UPPER, &phy_data);
-		e1e_rphy(hw, HV_LATECOL_LOWER, &phy_data);
-		adapter->stats.latecol += phy_data;
+		if (!e1e_rphy(hw, HV_LATECOL_LOWER, &phy_data))
+			adapter->stats.latecol += phy_data;
 
 		e1e_rphy(hw, HV_DC_UPPER, &phy_data);
-		e1e_rphy(hw, HV_DC_LOWER, &phy_data);
-		adapter->stats.dc += phy_data;
+		if (!e1e_rphy(hw, HV_DC_LOWER, &phy_data))
+			adapter->stats.dc += phy_data;
 	} else {
 		adapter->stats.scc += er32(SCC);
 		adapter->stats.ecol += er32(ECOL);
@@ -3360,8 +3360,8 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	if ((hw->phy.type == e1000_phy_82578) ||
 	    (hw->phy.type == e1000_phy_82577)) {
 		e1e_rphy(hw, HV_COLC_UPPER, &phy_data);
-		e1e_rphy(hw, HV_COLC_LOWER, &phy_data);
-		hw->mac.collision_delta = phy_data;
+		if (!e1e_rphy(hw, HV_COLC_LOWER, &phy_data))
+			hw->mac.collision_delta = phy_data;
 	} else {
 		hw->mac.collision_delta = er32(COLC);
 	}
@@ -3372,8 +3372,8 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	if ((hw->phy.type == e1000_phy_82578) ||
 	    (hw->phy.type == e1000_phy_82577)) {
 		e1e_rphy(hw, HV_TNCRS_UPPER, &phy_data);
-		e1e_rphy(hw, HV_TNCRS_LOWER, &phy_data);
-		adapter->stats.tncrs += phy_data;
+		if (!e1e_rphy(hw, HV_TNCRS_LOWER, &phy_data))
+			adapter->stats.tncrs += phy_data;
 	} else {
 		if ((hw->mac.type != e1000_82574) &&
 		    (hw->mac.type != e1000_82583))

