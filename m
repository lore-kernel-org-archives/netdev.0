From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: prevent link checks while resetting
Date: Wed,  5 Oct 2011 03:20:16 -0700
Message-ID: <1317810024-20846-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36037 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934229Ab1JEKU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:20:29 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
1.7.6.4
