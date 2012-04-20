From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 1/9] atl1c: remove REG_PHY_STATUS
Date: Fri, 20 Apr 2012 14:16:16 +0800
Message-ID: <1334902584-15584-2-git-send-email-xiong@qca.qualcomm.com>
References: <1334902584-15584-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334902584-15584-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this register is used for l1e(dev=1026)
l1c/l1d/l2cb don't use it.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |    7 -------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 --
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index cc7afa1..459e141 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -293,13 +293,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define MDIO_AP_EN              	0x10000000
 #define MDIO_WAIT_TIMES         	10
 
-/* MII PHY Status Register */
-#define REG_PHY_STATUS           	0x1418
-#define PHY_GENERAL_STATUS_MASK		0xFFFF
-#define PHY_STATUS_RECV_ENABLE		0x0001
-#define PHY_OE_PWSP_STATUS_MASK		0x07FF
-#define PHY_OE_PWSP_STATUS_SHIFT	16
-#define PHY_STATUS_LPW_STATE		0x80000000
 /* BIST Control and Status Register0 (for the Packet Memory) */
 #define REG_BIST0_CTRL              	0x141c
 #define BIST0_NOW                   	0x1
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index df10637..a6c3f05 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -699,11 +699,9 @@ static void atl1c_set_mac_type(struct atl1c_hw *hw)
 
 static int atl1c_setup_mac_funcs(struct atl1c_hw *hw)
 {
-	u32 phy_status_data;
 	u32 link_ctrl_data;
 
 	atl1c_set_mac_type(hw);
-	AT_READ_REG(hw, REG_PHY_STATUS, &phy_status_data);
 	AT_READ_REG(hw, REG_LINK_CTRL, &link_ctrl_data);
 
 	hw->ctrl_flags = ATL1C_INTR_MODRT_ENABLE  |
-- 
1.7.7
