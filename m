From: Chas Williams <3chas3@gmail.com>
Subject: [PATCH net-next] ixgbe: Extend trust to allow guest to set unicast address
Date: Thu, 31 Dec 2015 06:12:11 -0500
Message-ID: <1451560331-21378-1-git-send-email-3chas3@gmail.com>
Cc: netdev@vger.kernel.org, Chas Williams <3chas3@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35235 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbLaLMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 06:12:17 -0500
Received: by mail-qg0-f45.google.com with SMTP id o11so199780152qge.2
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2015 03:12:16 -0800 (PST)
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
