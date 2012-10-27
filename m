From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/12] ixgbe: Return success or failure on VF MAC filter set
Date: Fri, 26 Oct 2012 17:08:31 -0700
Message-ID: <1351296518-31174-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1819 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934335Ab2J0AIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:08:43 -0400
In-Reply-To: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When setting a MAC filter for the VF the function should return a success
or failure code, not the index of the new filter.  It causes spurious NACK
returns to the VF driver.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index b68bf0f..2037d8c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -675,7 +675,7 @@ static int ixgbe_set_vf_mac_addr(struct ixgbe_adapter *adapter,
 		return -1;
 	}
 
-	return ixgbe_set_vf_mac(adapter, vf, new_mac);
+	return ixgbe_set_vf_mac(adapter, vf, new_mac) < 0;
 }
 
 static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
-- 
1.7.11.7
