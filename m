From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbe: disable LLI for FCoE
Date: Wed, 28 Sep 2011 23:30:12 -0700
Message-ID: <1317277816-6024-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62728 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133Ab1I2GaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:21 -0400
In-Reply-To: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Disable LLI for FCoE since regular interrupt
and their moderation rate works slightly better
for FCoE also.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index cae766d..323f452 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -661,9 +661,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 			IXGBE_ETQS_QUEUE_EN |
 			(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL,
-			IXGBE_FCRXCTRL_FCOELLI |
-			IXGBE_FCRXCTRL_FCCRCBO |
+	IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL, IXGBE_FCRXCTRL_FCCRCBO |
 			(FC_FCOE_VER << IXGBE_FCRXCTRL_FCOEVER_SHIFT));
 	return;
 
-- 
1.7.6.2
