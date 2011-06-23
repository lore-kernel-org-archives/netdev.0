From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] ixgbe: move reset code into a separate function
Date: Wed, 22 Jun 2011 18:44:33 -0700
Message-ID: <1308793476-11596-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45487 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932329Ab1FWBop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 21:44:45 -0400
In-Reply-To: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Move reset code into a separate function to allow for reuse in other
parts of the code.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 791b388..acf95ec 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -442,6 +442,16 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	return 0;
 }
 
+static void ixgbe_do_reset(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
+	else
+		ixgbe_reset(adapter);
+}
+
 static u32 ixgbe_get_rx_csum(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -2249,12 +2259,8 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	 * correctly w.r.t stopping tx, and changing TXDCTL.WTHRESH settings
 	 * also locks in RSC enable/disable which requires reset
 	 */
-	if (need_reset) {
-		if (netif_running(netdev))
-			ixgbe_reinit_locked(adapter);
-		else
-			ixgbe_reset(adapter);
-	}
+	if (need_reset)
+		ixgbe_do_reset(netdev);
 
 	return 0;
 }
@@ -2328,12 +2334,8 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 		need_reset = true;
 	}
 
-	if (need_reset) {
-		if (netif_running(netdev))
-			ixgbe_reinit_locked(adapter);
-		else
-			ixgbe_reset(adapter);
-	}
+	if (need_reset)
+		ixgbe_do_reset(netdev);
 
 	return 0;
 }
-- 
1.7.5.4

