From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] ixgbe: prevent link checks while resetting
Date: Thu, 29 Sep 2011 22:24:42 -0700
Message-ID: <1317360291-5576-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2856 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200Ab1I3FY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 01:24:56 -0400
In-Reply-To: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

It some situations the driver sets __IXGBE_RESETTING and then
__IXGBE_DOWN flags. It is possible a link check may sneak in
between.

This patch adds check for both flags.
The idea is to reduce register reads while the PHY is resetting.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9cd44ad..ed92272 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5978,7 +5978,8 @@ static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
 static void ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)
 {
 	/* if interface is down do nothing */
-	if (test_bit(__IXGBE_DOWN, &adapter->state))
+	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_RESETTING, &adapter->state))
 		return;
 
 	ixgbe_watchdog_update_link(adapter);
-- 
1.7.6.2
