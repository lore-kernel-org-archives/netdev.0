From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] ixgbe: Make certain to initialize the fdir_perfect_lock in all cases
Date: Sat,  9 Jul 2011 04:50:39 -0700
Message-ID: <1310212240-24623-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29537 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098Ab1GILup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 07:50:45 -0400
In-Reply-To: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This fix makes it so that the fdir_perfect_lock is initialized in all
cases.  This is necessary as the fdir_filter_exit routine will always
attempt to take the lock before inspecting the filter table.

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fa671ae..de30796 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5155,8 +5155,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
 			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
-		/* n-tuple support exists, always init our spinlock */
-		spin_lock_init(&adapter->fdir_perfect_lock);
 		/* Flow Director hash filters enabled */
 		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 		adapter->atr_sample_rate = 20;
@@ -5177,6 +5175,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		break;
 	}
 
+	/* n-tuple support exists, always init our spinlock */
+	spin_lock_init(&adapter->fdir_perfect_lock);
+
 #ifdef CONFIG_IXGBE_DCB
 	/* Configure DCB traffic classes */
 	for (j = 0; j < MAX_TRAFFIC_CLASS; j++) {
-- 
1.7.6

