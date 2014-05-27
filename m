From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40evf: Use is_multicast_ether_addr helper
Date: Tue, 27 May 2014 02:12:31 -0700
Message-ID: <1401181951-31358-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091AbaE0JMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:46 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

Use the is_multicast_ether_addr helper function from linux/etherdevice.h
instead of open coding the multicast address check.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8dbaa77..23c9ff6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -845,7 +845,7 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
 		bool found = false;
 
-		if (f->macaddr[0] & 0x01) {
+		if (is_multicast_ether_addr(f->macaddr)) {
 			netdev_for_each_mc_addr(mca, netdev) {
 				if (ether_addr_equal(mca->addr, f->macaddr)) {
 					found = true;
-- 
1.9.3
