From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] ixgbe: Fix Receive Address Register (RAR)
	cleaning and accounting
Date: Tue, 24 Nov 2009 20:52:10 -0800
Message-ID: <20091125045209.23932.59410.stgit@localhost.localdomain>
References: <20091125045059.23932.10997.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:39880 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934503AbZKYEwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 23:52:23 -0500
In-Reply-To: <20091125045059.23932.10997.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This fixes an issue when clearing out the RAR entries.  If RAR[0]
is the only address in use, don't clear the others.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 79533e2..688b8ca 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1382,10 +1382,10 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 	hw->addr_ctrl.overflow_promisc = 0;
 
 	/* Zero out the other receive addresses */
-	hw_dbg(hw, "Clearing RAR[1-%d]\n", uc_addr_in_use);
-	for (i = 1; i <= uc_addr_in_use; i++) {
-		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
+	hw_dbg(hw, "Clearing RAR[1-%d]\n", uc_addr_in_use + 1);
+	for (i = 0; i < uc_addr_in_use; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(1+i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(1+i), 0);
 	}
 
 	/* Add the new addresses */

