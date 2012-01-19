From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 8/9] ixgbevf: fix sparse warnings
Date: Thu, 19 Jan 2012 00:13:33 -0800
Message-ID: <1326960814-16976-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56557 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883Ab2ASINz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:55 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Fixes sparse warnings:
drivers/net/ethernet/intel/ixgbevf/vf.c:418:21: warning: symbol 'ixgbevf_82599_vf_info' was not declared. Should it be static?
drivers/net/ethernet/intel/ixgbevf/vf.c:423:21: warning: symbol 'ixgbevf_X540_vf_info' was not declared. Should it be static?
drivers/net/ethernet/intel/ixgbevf/mbx.c:331:29: warning: symbol 'ixgbevf_mbx_ops' was not declared. Should it be static?

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |    2 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.c     |    3 ++-
 drivers/net/ethernet/intel/ixgbevf/vf.c      |    1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index e6c9d1a..74b22ee 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -281,7 +281,7 @@ enum ixgbevf_boards {
 
 extern struct ixgbevf_info ixgbevf_82599_vf_info;
 extern struct ixgbevf_info ixgbevf_X540_vf_info;
-extern struct ixgbe_mbx_operations ixgbevf_mbx_ops;
+extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 
 /* needed by ethtool.c */
 extern char ixgbevf_driver_name[];
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
index 930fa83..13532d9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
@@ -26,6 +26,7 @@
 *******************************************************************************/
 
 #include "mbx.h"
+#include "ixgbevf.h"
 
 /**
  *  ixgbevf_poll_for_msg - Wait for message notification
@@ -328,7 +329,7 @@ static s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *hw)
 	return 0;
 }
 
-struct ixgbe_mbx_operations ixgbevf_mbx_ops = {
+const struct ixgbe_mbx_operations ixgbevf_mbx_ops = {
 	.init_params   = ixgbevf_init_mbx_params_vf,
 	.read          = ixgbevf_read_mbx_vf,
 	.write         = ixgbevf_write_mbx_vf,
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 21533e3..5c8c23f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -26,6 +26,7 @@
 *******************************************************************************/
 
 #include "vf.h"
+#include "ixgbevf.h"
 
 /**
  *  ixgbevf_start_hw_vf - Prepare hardware for Tx/Rx
-- 
1.7.7.5
