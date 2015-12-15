From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] e1000e: Switch e1000e_up to void, drop code checking for error result
Date: Mon, 14 Dec 2015 21:38:36 -0800
Message-ID: <1450157924-58901-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59684 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbbLOFir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:47 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The function e1000e_up always returns 0.  As such we can convert it to a
void and just ignore the results.  This allows us to drop some code in a
couple spots as we no longer need to worry about non-zero return values.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c | 15 ++++-----------
 2 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 0b748d1..1dc293b 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -480,7 +480,7 @@ extern const char e1000e_driver_version[];
 void e1000e_check_options(struct e1000_adapter *adapter);
 void e1000e_set_ethtool_ops(struct net_device *netdev);
 
-int e1000e_up(struct e1000_adapter *adapter);
+void e1000e_up(struct e1000_adapter *adapter);
 void e1000e_down(struct e1000_adapter *adapter, bool reset);
 void e1000e_reinit_locked(struct e1000_adapter *adapter);
 void e1000e_reset(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 775e389..955c8c7 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4146,7 +4146,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 }
 
-int e1000e_up(struct e1000_adapter *adapter)
+void e1000e_up(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
@@ -4166,8 +4166,6 @@ int e1000e_up(struct e1000_adapter *adapter)
 		ew32(ICS, E1000_ICS_LSC | E1000_ICR_OTHER);
 	else
 		ew32(ICS, E1000_ICS_LSC);
-
-	return 0;
 }
 
 static void e1000e_flush_descriptors(struct e1000_adapter *adapter)
@@ -6633,7 +6631,7 @@ static int e1000e_pm_runtime_resume(struct device *dev)
 		return rc;
 
 	if (netdev->flags & IFF_UP)
-		rc = e1000e_up(adapter);
+		e1000e_up(adapter);
 
 	return rc;
 }
@@ -6824,13 +6822,8 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
 	e1000_init_manageability_pt(adapter);
 
-	if (netif_running(netdev)) {
-		if (e1000e_up(adapter)) {
-			dev_err(&pdev->dev,
-				"can't bring device back up after reset\n");
-			return;
-		}
-	}
+	if (netif_running(netdev))
+		e1000e_up(adapter);
 
 	netif_device_attach(netdev);
 
-- 
2.5.0
