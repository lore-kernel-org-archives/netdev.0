From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] igb: Fixed Wake On Lan support
Date: Tue, 19 Nov 2013 07:40:53 -0800
Message-ID: <1384875654-7795-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab3KSPk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 10:40:59 -0500
In-Reply-To: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch fixes Wake on Lan being reported as supported on some Ethernet
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
