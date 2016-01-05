From: Chas Williams <3chas3@gmail.com>
Subject: [PATCH net-next] ixgbe: Extend trust to allow guest to set unicast address
Date: Tue,  5 Jan 2016 17:30:39 -0500
Message-ID: <1452033039-18970-1-git-send-email-3chas3@gmail.com>
Cc: netdev@vger.kernel.org, Chas Williams <3chas3@gmail.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33272 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbcAEWaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:30:46 -0500
Received: by mail-qg0-f42.google.com with SMTP id b35so160197325qge.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:30:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running certain routing protocols like VRRP, VF guests need the
ability to set the unicast address of the interface.  Extend the new ndo
trust feature to let the hypervisor trust a guest to set/update its own
unicast address.

Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index eeff3d0..63cff17 100644
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
2.5.0
