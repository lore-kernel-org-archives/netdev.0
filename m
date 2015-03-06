From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] e1000: call netif_carrier_off early on down
Date: Fri,  6 Mar 2015 03:06:05 -0800
Message-ID: <1425639966-6829-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50981 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756082AbbCFLGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 06:06:12 -0500
In-Reply-To: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>

When bringing down an interface netif_carrier_off() should be
one the first things we do, since this will prevent the stack
from queuing more packets to this interface.
This operation is very fast, and should make the device behave
much nicer when trying to bring down an interface under load.

Also, this would Do The Right Thing (TM) if this device has some
sort of fail-over teaming and redirect traffic to the other IF.

Move netif_carrier_off as early as possible.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7f997d3..26dcb44 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -516,6 +516,7 @@ void e1000_down(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl, tctl;
 
+	netif_carrier_off(netdev);
 
 	/* disable receives in the hardware */
 	rctl = er32(RCTL);
@@ -544,7 +545,6 @@ void e1000_down(struct e1000_adapter *adapter)
 
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
-	netif_carrier_off(netdev);
 
 	e1000_reset(adapter);
 	e1000_clean_all_tx_rings(adapter);
-- 
1.9.3
