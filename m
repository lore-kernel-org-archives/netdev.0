From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 03/37] atl1c: remove HDS register
Date: Fri, 13 Apr 2012 08:14:28 +0800
Message-ID: <1334276102-15866-4-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove HDS register as it doesn't exist in hardware.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |    7 -------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 --
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 855aca0..c22d698 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -669,13 +669,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define REG_INT_RETRIG_TIMER		0x1608
 #define INT_RETRIG_TIMER_MASK		0xFFFF
 
-#define REG_HDS_CTRL			0x160C
-#define HDS_CTRL_EN			0x0001
-#define HDS_CTRL_BACKFILLSIZE_SHIFT	8
-#define HDS_CTRL_BACKFILLSIZE_MASK	0x0FFF
-#define HDS_CTRL_MAX_HDRSIZE_SHIFT	20
-#define HDS_CTRL_MAC_HDRSIZE_MASK	0x0FFF
-
 #define REG_MAC_RX_STATUS_BIN 		0x1700
 #define REG_MAC_RX_STATUS_END 		0x175c
 #define REG_MAC_TX_STATUS_BIN 		0x1760
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 226be99..885e892 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1453,8 +1453,6 @@ static int atl1c_configure(struct atl1c_adapter *adapter)
 	/* set MTU */
 	AT_WRITE_REG(hw, REG_MTU, hw->max_frame_size + ETH_HLEN +
 			VLAN_HLEN + ETH_FCS_LEN);
-	/* HDS, disable */
-	AT_WRITE_REG(hw, REG_HDS_CTRL, 0);
 
 	atl1c_configure_tx(adapter);
 	atl1c_configure_rx(adapter);
-- 
1.7.7
