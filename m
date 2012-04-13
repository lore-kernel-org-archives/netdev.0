From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 19/37] atl1c: clear bit MASTER_CTRL_CLK_SEL_DIS in atl1c_pcie_patch
Date: Fri, 13 Apr 2012 08:14:44 +0800
Message-ID: <1334276102-15866-20-git-send-email-xiong@qca.qualcomm.com>
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

bit MASTER_CTRL_CLK_SEL_DIS could be set before enter suspend
clear it after resume to enable pclk(PCIE clock) switch to
low frequency(25M) in some circumstances to save power.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 4fc824d..ddffc48 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -80,7 +80,12 @@ static const u32 atl1c_default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
 	NETIF_MSG_LINK | NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP;
 static void atl1c_pcie_patch(struct atl1c_hw *hw)
 {
-	u32 data;
+	u32 mst_data, data;
+
+	/* pclk sel could switch to 25M */
+	AT_READ_REG(hw, REG_MASTER_CTRL, &mst_data);
+	mst_data &= ~MASTER_CTRL_CLK_SEL_DIS;
+	AT_WRITE_REG(hw, REG_MASTER_CTRL, mst_data);
 
 	AT_READ_REG(hw, REG_PCIE_PHYMISC, &data);
 	data |= PCIE_PHYMISC_FORCE_RCV_DET;
-- 
1.7.7
