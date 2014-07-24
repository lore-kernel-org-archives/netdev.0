From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40evf: don't wait so long
Date: Thu, 24 Jul 2014 06:13:20 -0700
Message-ID: <1406207604-31653-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36520 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759205AbaGXNOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:06 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

We really don't need to delay an entire millisecond just to get into our
critical section. A microsecond will be sufficient, thank you.

Change-ID: I2d02ece6610007d98cabcb3f42df9a774bb54e59
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index ed1eb12..a53e81b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -768,7 +768,7 @@ i40evf_mac_filter *i40evf_add_filter(struct i40evf_adapter *adapter,
 
 	while (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK,
 				&adapter->crit_section))
-		mdelay(1);
+		udelay(1);
 
 	f = i40evf_find_filter(adapter, macaddr);
 	if (NULL == f) {
@@ -840,7 +840,7 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 
 	while (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK,
 				&adapter->crit_section))
-		mdelay(1);
+		udelay(1);
 	/* remove filter if not in netdev list */
 	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
 		bool found = false;
-- 
1.9.3
