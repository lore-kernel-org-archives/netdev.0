From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ixgbe: Remove unneeded register writes in VF
	VLAN setup
Date: Wed, 05 May 2010 22:57:10 -0700
Message-ID: <20100506055703.8482.16515.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:60302 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993Ab0EFF52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 01:57:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The driver is unnecessarily writing values to VLAN control registers.
These writes already done elsewhere and are superfluous here.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_sriov.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 221b2ca..c4e5150 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -98,17 +98,6 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 
 int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid, u32 vf)
 {
-	u32 ctrl;
-
-	/* Check if global VLAN already set, if not set it */
-	ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
-	if (!(ctrl & IXGBE_VLNCTRL_VFE)) {
-		/* enable VLAN tag insert/strip */
-		ctrl |= IXGBE_VLNCTRL_VFE;
-		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
-	}
-
 	return adapter->hw.mac.ops.set_vfta(&adapter->hw, vid, vf, (bool)add);
 }
 

