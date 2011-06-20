From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] ixgbevf: Fix bungled declaration of ixgbevf_mbx_ops
Date: Sun, 19 Jun 2011 17:58:24 -0700
Message-ID: <1308531518-17298-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51969 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475Ab1FTA7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:59:00 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

In two places storage for mbx_ops is misidentified as type
ixgbe_mac_operations.

Reported-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index b703f60..a2bbbb3 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -279,7 +279,7 @@ enum ixgbevf_boards {
 
 extern struct ixgbevf_info ixgbevf_82599_vf_info;
 extern struct ixgbevf_info ixgbevf_X540_vf_info;
-extern struct ixgbe_mac_operations ixgbevf_mbx_ops;
+extern struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 
 /* needed by ethtool.c */
 extern char ixgbevf_driver_name[];
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index b2c5ecd..721417e 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3364,7 +3364,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	hw->mac.type  = ii->mac;
 
 	memcpy(&hw->mbx.ops, &ixgbevf_mbx_ops,
-	       sizeof(struct ixgbe_mac_operations));
+	       sizeof(struct ixgbe_mbx_operations));
 
 	adapter->flags &= ~IXGBE_FLAG_RX_PS_CAPABLE;
 	adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
-- 
1.7.5.4

