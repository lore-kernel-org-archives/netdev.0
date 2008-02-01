From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/8] ixgbe: Fix pause code for ethtool
Date: Fri, 01 Feb 2008 15:58:59 -0800
Message-ID: <20080201235859.31474.57020.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13742 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760170AbYBAX7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 18:59:24 -0500
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index b447dd7..a119cbd 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -167,7 +167,7 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	pause->autoneg = AUTONEG_DISABLE;
+	pause->autoneg = (hw->fc.type == ixgbe_fc_full ? 1 : 0);
 
 	if (hw->fc.type == ixgbe_fc_rx_pause) {
 		pause->rx_pause = 1;
@@ -185,10 +185,8 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (pause->autoneg == AUTONEG_ENABLE)
-		return -EINVAL;
-
-	if (pause->rx_pause && pause->tx_pause)
+	if ((pause->autoneg == AUTONEG_ENABLE) ||
+	    (pause->rx_pause && pause->tx_pause))
 		hw->fc.type = ixgbe_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgbe_fc_rx_pause;
@@ -196,6 +194,8 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 		hw->fc.type = ixgbe_fc_tx_pause;
 	else if (!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgbe_fc_none;
+	else
+		return -EINVAL;
 
 	hw->fc.original_type = hw->fc.type;
 

