From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/14] ixgbe: Extend trust to allow guest to set unicast address
Date: Mon,  4 Apr 2016 17:58:54 -0700
Message-ID: <1459817945-144915-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: chas williams <3chas3@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38979 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754665AbcDEA7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 20:59:09 -0400
In-Reply-To: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams <3chas3@gmail.com>

When running certain routing protocols like VRRP, VF guests need the
ability to set the unicast address of the interface.  Extend the new ndo
trust feature to let the hypervisor trust a guest to set/update its own
unicast address.

Signed-off-by: Chas Williams <3chas3@gmail.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 8025a3f..80e47db 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -887,7 +887,7 @@ static int ixgbe_set_vf_mac_addr(struct ixgbe_adapter *adapter,
 		return -1;
 	}
 
-	if (adapter->vfinfo[vf].pf_set_mac &&
+	if (adapter->vfinfo[vf].pf_set_mac && !adapter->vfinfo[vf].trusted &&
 	    !ether_addr_equal(adapter->vfinfo[vf].vf_mac_addresses, new_mac)) {
 		e_warn(drv,
 		       "VF %d attempted to override administratively set MAC address\n"
-- 
2.5.5
