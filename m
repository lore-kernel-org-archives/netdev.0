From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] ixgbe: send MFLCN to ethtool
Date: Thu, 29 Sep 2011 22:24:47 -0700
Message-ID: <1317360291-5576-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2856 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754992Ab1I3FY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 01:24:58 -0400
In-Reply-To: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

MFLCN register is used to set Rx flow control on parts newer than 82598.

This patch sends the value of MFLCN to ethtool, so it can be used in a
register dump (ethtool -d).

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index ae9fba5..db255fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -460,7 +460,7 @@ static void ixgbe_set_msglevel(struct net_device *netdev, u32 data)
 
 static int ixgbe_get_regs_len(struct net_device *netdev)
 {
-#define IXGBE_REGS_LEN  1128
+#define IXGBE_REGS_LEN  1129
 	return IXGBE_REGS_LEN * sizeof(u32);
 }
 
@@ -771,6 +771,9 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[1125] = IXGBE_READ_REG(hw, IXGBE_PCIEECCCTL);
 	regs_buff[1126] = IXGBE_READ_REG(hw, IXGBE_PBTXECC);
 	regs_buff[1127] = IXGBE_READ_REG(hw, IXGBE_PBRXECC);
+
+	/* 82599 X540 specific registers  */
+	regs_buff[1128] = IXGBE_READ_REG(hw, IXGBE_MFLCN);
 }
 
 static int ixgbe_get_eeprom_len(struct net_device *netdev)
-- 
1.7.6.2
