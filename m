From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 1/7] igb: Fixed Wake On LAN support
Date: Sat, 30 Nov 2013 01:20:15 -0800
Message-ID: <1385803221-3752-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40622 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131Ab3K3JUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Nov 2013 04:20:25 -0500
In-Reply-To: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch fixes Wake on LAN being reported as supported on some Ethernet
ports, in contrary to Hardware capability.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index b0f3666..c3143da 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2062,14 +2062,15 @@ static void igb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	wol->supported = WAKE_UCAST | WAKE_MCAST |
-			 WAKE_BCAST | WAKE_MAGIC |
-			 WAKE_PHY;
 	wol->wolopts = 0;
 
 	if (!(adapter->flags & IGB_FLAG_WOL_SUPPORTED))
 		return;
 
+	wol->supported = WAKE_UCAST | WAKE_MCAST |
+			 WAKE_BCAST | WAKE_MAGIC |
+			 WAKE_PHY;
+
 	/* apply any specific unsupported masks here */
 	switch (adapter->hw.device_id) {
 	default:
-- 
1.8.3.1
