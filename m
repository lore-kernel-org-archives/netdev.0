From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] i40evf: Use is_multicast_ether_addr helper
Date: Fri, 16 May 2014 10:00:34 +0200
Message-ID: <1400227234-13383-1-git-send-email-tklauser@distanz.ch>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57951 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583AbaEPIA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 04:00:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the is_multicast_ether_addr helper function from linux/etherdevice.h
instead of open coding the multicast address check.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 6edd581..8b5c734 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -843,7 +843,7 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
 		bool found = false;
 
-		if (f->macaddr[0] & 0x01) {
+		if (is_multicast_ether_addr(f->macaddr)) {
 			netdev_for_each_mc_addr(mca, netdev) {
 				if (ether_addr_equal(mca->addr, f->macaddr)) {
 					found = true;
-- 
1.7.9.5
