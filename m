From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40evf: disable NAPI polling sooner
Date: Sun, 22 Feb 2015 19:25:42 -0800
Message-ID: <1424661944-1779-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3468 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbbBWD0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 22:26:04 -0500
In-Reply-To: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When closing the interface, disable NAPI polling before any other
activities. This fixes an occasional panic during close caused by the
driver trying to delete and clean rings at the same time.

Change-ID: Ib4d427b13d310258ea85b248d535da70ecf0c1e9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index b1ca9dd..eb1ac22 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -959,6 +959,7 @@ void i40evf_down(struct i40evf_adapter *adapter)
 		usleep_range(500, 1000);
 
 	i40evf_irq_disable(adapter);
+	i40evf_napi_disable_all(adapter);
 
 	/* remove all MAC filters */
 	list_for_each_entry(f, &adapter->mac_filter_list, list) {
@@ -985,8 +986,6 @@ void i40evf_down(struct i40evf_adapter *adapter)
 
 	netif_tx_stop_all_queues(netdev);
 
-	i40evf_napi_disable_all(adapter);
-
 	msleep(20);
 
 	netif_carrier_off(netdev);
-- 
1.9.3
