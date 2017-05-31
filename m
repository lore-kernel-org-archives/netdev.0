From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbe: Correct thermal sensor event check
Date: Wed, 31 May 2017 14:19:26 -0700
Message-ID: <20170531211936.63417-6-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:18995 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdEaVTu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:50 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The thermal sensor event logic is messed up, because it can execute
the code when there is no thermal event. The current logic is that
it will exit when !capable && !event whereas it really should exit
when !capable || !event. For one thing, it means that the service
task is doing too much work. It probably has some other symptoms as
well. So, correct the logic, simplifying to only execute when there
is a thermal event. The capable check is redundant.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7baca05c4a51..5c671b7401cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2639,8 +2639,7 @@ static void ixgbe_check_overtemp_subtask(struct ixgbe_adapter *adapter)
 	if (test_bit(__IXGBE_DOWN, &adapter->state))
 		return;
 
-	if (!(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-	    !(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_EVENT))
+	if (!(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_EVENT))
 		return;
 
 	adapter->flags2 &= ~IXGBE_FLAG2_TEMP_SENSOR_EVENT;
-- 
2.12.2
