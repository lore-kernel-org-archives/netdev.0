From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 05/10] atl1c: remove PHY polling from atl1c_open
Date: Thu, 26 Apr 2012 14:27:13 +0800
Message-ID: <1335421638-16304-6-git-send-email-xiong@qca.qualcomm.com>
References: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PHY polling code for FPGA is considered in every MDIO R/W API.
no need to add additional code to atl1c_open.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index cf78287..8a1d2f9 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2273,13 +2273,6 @@ static int atl1c_open(struct net_device *netdev)
 	if (unlikely(err))
 		goto err_up;
 
-	if (adapter->hw.ctrl_flags & ATL1C_FPGA_VERSION) {
-		u32 phy_data;
-
-		AT_READ_REG(&adapter->hw, REG_MDIO_CTRL, &phy_data);
-		phy_data |= MDIO_CTRL_AP_EN;
-		AT_WRITE_REG(&adapter->hw, REG_MDIO_CTRL, phy_data);
-	}
 	return 0;
 
 err_up:
-- 
1.7.7
