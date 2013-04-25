From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] igb: SERDES loopback sigdetect bit on i210 devices
Date: Wed, 24 Apr 2013 21:08:39 -0700
Message-ID: <1366862927-1855-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15281 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab3DYEJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 00:09:01 -0400
In-Reply-To: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch implements SERDES loopback configuration for i210 devices by
unsetting sigdetect bit, so as to fix Ethtool loopback test failure. Old
sigdetect code is also simplified to take care of all devices newer than 82580

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 48b5947..7876240 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1678,17 +1678,12 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 		wr32(E1000_CONNSW, reg);
 
 		/* Unset sigdetect for SERDES loopback on
-		 * 82580 and i350 devices.
+		 * 82580 and newer devices.
 		 */
-		switch (hw->mac.type) {
-		case e1000_82580:
-		case e1000_i350:
+		if (hw->mac.type >= e1000_82580) {
 			reg = rd32(E1000_PCS_CFG0);
 			reg |= E1000_PCS_CFG_IGN_SD;
 			wr32(E1000_PCS_CFG0, reg);
-			break;
-		default:
-			break;
 		}
 
 		/* Set PCS register for forced speed */
-- 
1.7.11.7
