From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 04/12] atl1c: remove VPD register
Date: Sat, 14 Apr 2012 17:59:20 +0800
Message-ID: <1334397568-8444-5-git-send-email-xiong@qca.qualcomm.com>
References: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:62721 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab2DNKAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 06:00:55 -0400
In-Reply-To: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VPD register is only used for L1(devid=PCI_DEVICE_ID_ATTANSIC_L1) to
access external NV-memory.
l1c & later chip doesn't use it any more.
no special userspace tool interpret the dumpped registers.
dumpping them via ethtool is just for debug.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h      |   11 -----------
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index 0a9326a..ce63615 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -142,7 +142,6 @@ static void atl1c_get_regs(struct net_device *netdev,
 	memset(p, 0, AT_REGS_LEN);
 
 	regs->version = 0;
-	AT_READ_REG(hw, REG_VPD_CAP, 		  p++);
 	AT_READ_REG(hw, REG_PM_CTRL, 		  p++);
 	AT_READ_REG(hw, REG_MAC_HALF_DUPLX_CTRL,  p++);
 	AT_READ_REG(hw, REG_TWSI_CTRL, 		  p++);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index c22d698..f5c7473 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -59,17 +59,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define LINK_CTRL_L1_EN			0x02
 #define LINK_CTRL_EXT_SYNC		0x80
 
-#define REG_VPD_CAP			0x6C
-#define VPD_CAP_ID_MASK                 0xff
-#define VPD_CAP_ID_SHIFT                0
-#define VPD_CAP_NEXT_PTR_MASK           0xFF
-#define VPD_CAP_NEXT_PTR_SHIFT          8
-#define VPD_CAP_VPD_ADDR_MASK           0x7FFF
-#define VPD_CAP_VPD_ADDR_SHIFT          16
-#define VPD_CAP_VPD_FLAG                0x80000000
-
-#define REG_VPD_DATA                	0x70
-
 #define REG_PCIE_UC_SEVERITY		0x10C
 #define PCIE_UC_SERVRITY_TRN		0x00000001
 #define PCIE_UC_SERVRITY_DLP		0x00000010
-- 
1.7.7
