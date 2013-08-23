From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/2] e1000e: balance semaphore put/get for 82573
Date: Fri, 23 Aug 2013 05:29:21 -0700
Message-ID: <1377260961-10096-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377260961-10096-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Steven La <sla@riverbed.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61902 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756012Ab3HWM3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 08:29:24 -0400
In-Reply-To: <1377260961-10096-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven La <sla@riverbed.com>

Steven (cc-ed) noticed an imbalance in semaphore put/get for
82573-based NICs. Don't we need something like the following
(untested) patch?

Signed-off-by: Steven La <sla@riverbed.com>
Acked-by: Arthur Kepner <akepner@riverbed.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 104fcec..8fed74e 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1011,6 +1011,11 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 
 	/* Must release MDIO ownership and mutex after MAC reset. */
 	switch (hw->mac.type) {
+	case e1000_82573:
+		/* Release mutex only if the hw semaphore is acquired */
+		if (!ret_val)
+			e1000_put_hw_semaphore_82573(hw);
+		break;
 	case e1000_82574:
 	case e1000_82583:
 		/* Release mutex only if the hw semaphore is acquired */
-- 
1.8.3.1
