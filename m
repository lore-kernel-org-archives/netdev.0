From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] ixgbe: Fix SR-IOV VLAN pool configuration
Date: Sat, 12 Dec 2015 03:14:40 -0800
Message-ID: <1449918890-145243-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14272 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186AbbLLLPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:00 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The code for checking the PF bit in ixgbe_set_vf_vlan_msg was using the
wrong offset and as a result it was pulling the VLAN off of the PF even if
there were VFs numbered greater than 40 that still had the VLAN enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 31de6cf..61a054a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -887,10 +887,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 			bits = IXGBE_READ_REG(hw, IXGBE_VLVFB(reg_ndx * 2));
 			bits &= ~(1 << VMDQ_P(0));
 			bits |= IXGBE_READ_REG(hw,
-					       IXGBE_VLVFB(reg_ndx * 2) + 1);
+					       IXGBE_VLVFB(reg_ndx * 2 + 1));
 		} else {
 			bits = IXGBE_READ_REG(hw,
-					      IXGBE_VLVFB(reg_ndx * 2) + 1);
+					      IXGBE_VLVFB(reg_ndx * 2 + 1));
 			bits &= ~(1 << (VMDQ_P(0) - 32));
 			bits |= IXGBE_READ_REG(hw, IXGBE_VLVFB(reg_ndx * 2));
 		}
-- 
2.5.0
