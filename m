From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] ixgbe - DDP last user buffer - error to warn
Date: Fri, 19 Aug 2011 06:11:23 -0700
Message-ID: <1313759486-23575-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30602 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753309Ab1HSNLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:11:30 -0400
In-Reply-To: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

Change the error message in the last DDP user buffer to warn_once

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 824edae..e9b992f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -241,10 +241,12 @@ static int ixgbe_fcoe_ddp_setup(struct net_device *netdev, u16 xid,
 	 */
 	if (lastsize == bufflen) {
 		if (j >= IXGBE_BUFFCNT_MAX) {
-			e_err(drv, "xid=%x:%d,%d,%d:addr=%llx "
-				"not enough user buffers. We need an extra "
-				"buffer because lastsize is bufflen.\n",
-				xid, i, j, dmacount, (u64)addr);
+			printk_once("Will NOT use DDP since there are not "
+				    "enough user buffers. We need an  extra "
+				    "buffer because lastsize is bufflen. "
+				    "xid=%x:%d,%d,%d:addr=%llx\n",
+				    xid, i, j, dmacount, (u64)addr);
+
 			goto out_noddp_free;
 		}
 
-- 
1.7.6

