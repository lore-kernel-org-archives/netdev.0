From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] ixgbe: Add missing code for enabling overheat sensor interrupt
Date: Fri, 16 Sep 2011 19:15:46 -0700
Message-ID: <1316225752-1709-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42810 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755269Ab1IQCP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:59 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds a small bit of missing code for enabling the overheat sensor

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index df1ea20..0533bc4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3543,6 +3543,10 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 		gpie |= IXGBE_GPIE_VTMODE_64;
 	}
 
+	/* Enable Thermal over heat sensor interrupt */
+	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
+		gpie |= IXGBE_SDP0_GPIEN;
+
 	/* Enable fan failure interrupt */
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		gpie |= IXGBE_SDP1_GPIEN;
-- 
1.7.6
