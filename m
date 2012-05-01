From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 10/10] atl1c: remove PHY polling from atl1c_change_mtu
Date: Tue, 1 May 2012 09:38:58 +0800
Message-ID: <1335836338-9425-11-git-send-email-xiong@qca.qualcomm.com>
References: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PHY polling code for FPGA is considered in every MDIO R/W API.
no need to add additional code to atl1c_change_mtu.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: David Liu <dwliu@qca.qaulcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 05ce8ec..9cc1570 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -553,14 +553,6 @@ static int atl1c_change_mtu(struct net_device *netdev, int new_mtu)
 		netdev_update_features(netdev);
 		atl1c_up(adapter);
 		clear_bit(__AT_RESETTING, &adapter->flags);
-		if (adapter->hw.ctrl_flags & ATL1C_FPGA_VERSION) {
-			u32 phy_data;
-
-			AT_READ_REG(&adapter->hw, 0x1414, &phy_data);
-			phy_data |= 0x10000000;
-			AT_WRITE_REG(&adapter->hw, 0x1414, phy_data);
-		}
-
 	}
 	return 0;
 }
-- 
1.7.7
