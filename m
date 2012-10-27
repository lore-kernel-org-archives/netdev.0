From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] ixgbe: Fix return value from macvlan filter function
Date: Fri, 26 Oct 2012 17:08:28 -0700
Message-ID: <1351296518-31174-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27325 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934312Ab2J0AIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:08:42 -0400
In-Reply-To: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The function to set the macvlan filter should return success or failure
instead of the index of the filter.  The message processing function was
misinterpreting the index as a non-zero return code indicating failure and
NACKing MAC filter set messages that actually succeeded.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert Garrett <robertx.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 96876b7..b68bf0f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -742,7 +742,8 @@ static int ixgbe_set_vf_macvlan_msg(struct ixgbe_adapter *adapter,
 		e_warn(drv,
 		       "VF %d has requested a MACVLAN filter but there is no space for it\n",
 		       vf);
-	return err;
+
+	return !!err < 0;
 }
 
 static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
-- 
1.7.11.7
