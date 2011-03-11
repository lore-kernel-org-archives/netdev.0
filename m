From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/11] e1000e: extend timeout for ethtool link test diagnostic
Date: Fri, 11 Mar 2011 03:06:25 -0800
Message-ID: <1299841590-30676-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21892 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754529Ab1CKLGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:51 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

With some PHYs supported by this driver, link establishment can take a
little longer when connected to certain switches.  Extend the timeout to
reduce the number of false diagnostic failures, and cleanup a code style
issue in the same function.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index d4e51aa..8e276dc 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1666,10 +1666,13 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	} else {
 		hw->mac.ops.check_for_link(hw);
 		if (hw->mac.autoneg)
-			msleep(4000);
+			/*
+			 * On some Phy/switch combinations, link establishment
+			 * can take a few seconds more than expected.
+			 */
+			msleep(5000);
 
-		if (!(er32(STATUS) &
-		      E1000_STATUS_LU))
+		if (!(er32(STATUS) & E1000_STATUS_LU))
 			*data = 1;
 	}
 	return *data;
-- 
1.7.4

