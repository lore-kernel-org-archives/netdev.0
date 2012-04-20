From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 3/9] atl1c: remove PHY contrl in atl1c_reset_pcie
Date: Fri, 20 Apr 2012 14:16:18 +0800
Message-ID: <1334902584-15584-4-git-send-email-xiong@qca.qualcomm.com>
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

atl1c_reset_phy follows atl1c_reset_pcie in the whole driver,
so, it's unnecessary to add PHY control code in atl1c_reset_pcie.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 1f82880..f0f348b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -165,11 +165,6 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
 	atl1c_pcie_patch(hw);
 	if (flag & ATL1C_PCIE_L0S_L1_DISABLE)
 		atl1c_disable_l0s_l1(hw);
-	if (flag & ATL1C_PCIE_PHY_RESET)
-		AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_DEFAULT);
-	else
-		AT_WRITE_REG(hw, REG_GPHY_CTRL,
-			GPHY_CTRL_DEFAULT | GPHY_CTRL_EXT_RESET);
 
 	msleep(5);
 }
@@ -2409,8 +2404,7 @@ static int atl1c_resume(struct device *dev)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	AT_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
-	atl1c_reset_pcie(&adapter->hw, ATL1C_PCIE_L0S_L1_DISABLE |
-			ATL1C_PCIE_PHY_RESET);
+	atl1c_reset_pcie(&adapter->hw, ATL1C_PCIE_L0S_L1_DISABLE);
 
 	atl1c_phy_reset(&adapter->hw);
 	atl1c_reset_mac(&adapter->hw);
@@ -2568,8 +2562,7 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 		dev_err(&pdev->dev, "net device private data init failed\n");
 		goto err_sw_init;
 	}
-	atl1c_reset_pcie(&adapter->hw, ATL1C_PCIE_L0S_L1_DISABLE |
-			ATL1C_PCIE_PHY_RESET);
+	atl1c_reset_pcie(&adapter->hw, ATL1C_PCIE_L0S_L1_DISABLE);
 
 	/* Init GPHY as early as possible due to power saving issue  */
 	atl1c_phy_reset(&adapter->hw);
-- 
1.7.7
