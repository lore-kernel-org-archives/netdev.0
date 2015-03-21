From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] igbvf: use netif_carrier_off earlier when bringing if down
Date: Fri, 20 Mar 2015 17:57:45 -0700
Message-ID: <1426899465-15789-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52848 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbbCUA57 (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/ethernet/intel/igbvf/netdev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index c17ea4b..95af14e 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1519,6 +1519,7 @@ void igbvf_down(struct igbvf_adapter *adapter)
 	rxdctl = er32(RXDCTL(0));
 	ew32(RXDCTL(0), rxdctl & ~E1000_RXDCTL_QUEUE_ENABLE);
 
+	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
 	/* disable transmits in the hardware */
@@ -1535,8 +1536,6 @@ void igbvf_down(struct igbvf_adapter *adapter)
 
 	del_timer_sync(&adapter->watchdog_timer);
 
-	netif_carrier_off(netdev);
-
 	/* record the stats before reset*/
 	igbvf_update_stats(adapter);
 
-- 
1.9.3
