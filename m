From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v1 5/7] ixgbe: allow RAR table to be updated in
	promisc mode
Date: Mon, 09 Apr 2012 15:00:42 -0700
Message-ID: <20120409220042.3288.91427.stgit@jf-dev1-dcblab>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com, sri@us.ibm.com
To: roprabhu@cisco.com, mst@redhat.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8663 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207Ab2DIWNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 18:13:44 -0400
In-Reply-To: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows RAR table updates while in promiscuous. With
SR-IOV enabled it is valuable to allow the RAR table to
be updated even when in promisc mode to configure forwarding

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8b37395..25a7ed9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3462,16 +3462,17 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		}
 		ixgbe_vlan_filter_enable(adapter);
 		hw->addr_ctrl.user_set_promisc = false;
-		/*
-		 * Write addresses to available RAR registers, if there is not
-		 * sufficient space to store all the addresses then enable
-		 * unicast promiscuous mode
-		 */
-		count = ixgbe_write_uc_addr_list(netdev);
-		if (count < 0) {
-			fctrl |= IXGBE_FCTRL_UPE;
-			vmolr |= IXGBE_VMOLR_ROPE;
-		}
+	}
+
+	/*
+	 * Write addresses to available RAR registers, if there is not
+	 * sufficient space to store all the addresses then enable
+	 * unicast promiscuous mode
+	 */
+	count = ixgbe_write_uc_addr_list(netdev);
+	if (count < 0) {
+		fctrl |= IXGBE_FCTRL_UPE;
+		vmolr |= IXGBE_VMOLR_ROPE;
 	}
 
 	if (adapter->num_vfs) {
