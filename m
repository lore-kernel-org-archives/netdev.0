From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 9/9] ixgbevf: make operations tables const
Date: Thu, 19 Jan 2012 00:13:34 -0800
Message-ID: <1326960814-16976-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7452 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754892Ab2ASINz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:55 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

The arrays of function pointers should be const to make life harder
for rootkits.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    6 +++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |    6 +++---
 drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 74b22ee..9075c1d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -279,12 +279,12 @@ enum ixgbevf_boards {
 	board_X540_vf,
 };
 
-extern struct ixgbevf_info ixgbevf_82599_vf_info;
-extern struct ixgbevf_info ixgbevf_X540_vf_info;
+extern const struct ixgbevf_info ixgbevf_82599_vf_info;
+extern const struct ixgbevf_info ixgbevf_X540_vf_info;
 extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 
 /* needed by ethtool.c */
-extern char ixgbevf_driver_name[];
+extern const char ixgbevf_driver_name[];
 extern const char ixgbevf_driver_version[];
 
 extern int ixgbevf_up(struct ixgbevf_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1cad3b6..bed411b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -53,7 +53,7 @@
 
 #include "ixgbevf.h"
 
-char ixgbevf_driver_name[] = "ixgbevf";
+const char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver";
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 5c8c23f..d0138d7 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -402,7 +402,7 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	return 0;
 }
 
-static struct ixgbe_mac_operations ixgbevf_mac_ops = {
+static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.init_hw             = ixgbevf_init_hw_vf,
 	.reset_hw            = ixgbevf_reset_hw_vf,
 	.start_hw            = ixgbevf_start_hw_vf,
@@ -416,12 +416,12 @@ static struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.set_vfta            = ixgbevf_set_vfta_vf,
 };
 
-struct ixgbevf_info ixgbevf_82599_vf_info = {
+const struct ixgbevf_info ixgbevf_82599_vf_info = {
 	.mac = ixgbe_mac_82599_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
 
-struct ixgbevf_info ixgbevf_X540_vf_info = {
+const struct ixgbevf_info ixgbevf_X540_vf_info = {
 	.mac = ixgbe_mac_X540_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 10306b4..d556619 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -167,7 +167,7 @@ struct ixgbevf_hw_stats {
 
 struct ixgbevf_info {
 	enum ixgbe_mac_type		mac;
-	struct ixgbe_mac_operations	*mac_ops;
+	const struct ixgbe_mac_operations *mac_ops;
 };
 
 #endif /* __IXGBE_VF_H__ */
-- 
1.7.7.5
