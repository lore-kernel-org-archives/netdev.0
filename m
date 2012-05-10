From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/12] ixgbe: Fix bogus error message
Date: Wed,  9 May 2012 23:46:46 -0700
Message-ID: <1336632413-19135-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51353 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab2EJGrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:47:00 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the VF sends a MACVLAN request with index of zero then it is not
actually trying to add a filter.  Check the index value and only
indicate that operation is not allowed when the VF is actually trying
to add a filter.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index b64f1fc..2d971d1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -640,14 +640,14 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		}
 		break;
 	case IXGBE_VF_SET_MACVLAN:
-		if (adapter->vfinfo[vf].pf_set_mac) {
+		index = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK) >>
+			IXGBE_VT_MSGINFO_SHIFT;
+		if (adapter->vfinfo[vf].pf_set_mac && index > 0) {
 			e_warn(drv, "VF %d requested MACVLAN filter but is "
 				    "administratively denied\n", vf);
 			retval = -1;
 			break;
 		}
-		index = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK) >>
-			IXGBE_VT_MSGINFO_SHIFT;
 		/*
 		 * If the VF is allowed to set MAC filters then turn off
 		 * anti-spoofing to avoid false positives.  An index
-- 
1.7.7.6
