From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] igb: use netif_carrier_off earlier when bringing if down
Date: Fri, 20 Mar 2015 17:57:44 -0700
Message-ID: <1426899465-15789-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50519 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbbCUA57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 20:57:59 -0400
In-Reply-To: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Use netif_carrier_off() first, since that will prevent the stack from
queuing more packets to this IF. This operation is fast, and should
behave much nicer when trying to bring down an interface under load.

Reported-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f366b3b..0e07545 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1776,6 +1776,7 @@ void igb_down(struct igb_adapter *adapter)
 	wr32(E1000_RCTL, rctl & ~E1000_RCTL_EN);
 	/* flush and sleep below */
 
+	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
 
 	/* disable transmits in the hardware */
@@ -1797,12 +1798,9 @@ void igb_down(struct igb_adapter *adapter)
 		}
 	}
 
-
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-	netif_carrier_off(netdev);
-
 	/* record the stats before reset*/
 	spin_lock(&adapter->stats64_lock);
 	igb_update_stats(adapter, &adapter->stats64);
-- 
1.9.3
