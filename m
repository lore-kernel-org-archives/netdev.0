From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] ixgbe: fix EEH recovery during reset on PPC
Date: Tue, 24 Jun 2008 17:00:56 -0700
Message-ID: <20080625000036.16592.6621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pl@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31298 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942AbYFYABL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 20:01:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Larson <pl@us.ibm.com>

EEh is not recovering in a resonable amount of time on PPC during
ixgbe_down().

Signed-off-by: Paul Larson <pl@us.ibm.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7b39394..5774377 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1969,7 +1969,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	ixgbe_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev))
+		ixgbe_reset(adapter);
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 

