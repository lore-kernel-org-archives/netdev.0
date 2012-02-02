From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/8] ixgbe: Add warning when no space left for more MAC filters
Date: Thu,  2 Feb 2012 04:20:15 -0800
Message-ID: <1328185221-8591-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3805 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755965Ab2BBMUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 07:20:24 -0500
In-Reply-To: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Send message to system log when the VF requests another MAC filter
but there is no space left on the device for it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index b76339b..8d8cdbc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -646,6 +646,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 			ixgbe_ndo_set_vf_spoofchk(adapter->netdev, vf, false);
 		retval = ixgbe_set_vf_macvlan(adapter, vf, index,
 					      (unsigned char *)(&msgbuf[1]));
+		if (retval == -ENOSPC)
+			e_warn(drv, "VF %d has requested a MACVLAN filter "
+				    "but there is no space for it\n", vf);
 		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
-- 
1.7.7.6
