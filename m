From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] ixgbe: Deny MACVLAN requests from VFs with admin set MAC
Date: Tue,  1 May 2012 01:51:08 -0700
Message-ID: <1335862269-28914-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42217 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918Ab2EAIvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 04:51:16 -0400
In-Reply-To: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the host VMM administrator has set the virtual function device's
MAC address then also deny VF requests for MACVLAN filters.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Garrett, Robert <robertx.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 88a58cb..3985637 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -635,6 +635,12 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		}
 		break;
 	case IXGBE_VF_SET_MACVLAN:
+		if (adapter->vfinfo[vf].pf_set_mac) {
+			e_warn(drv, "VF %d requested MACVLAN filter but is "
+				    "administratively denied\n", vf);
+			retval = -1;
+			break;
+		}
 		index = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK) >>
 			IXGBE_VT_MSGINFO_SHIFT;
 		/*
-- 
1.7.7.6
