From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/8] igb: Fixed Wake On LAN support
Date: Wed, 27 Nov 2013 23:35:56 -0800
Message-ID: <1385624162-10116-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37634 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552Ab3K1Hgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 02:36:33 -0500
In-Reply-To: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
