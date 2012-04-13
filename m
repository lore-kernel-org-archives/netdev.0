From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 30/37] atl1c: remove PHY reset/init for link down event
Date: Fri, 13 Apr 2012 08:14:55 +0800
Message-ID: <1334276102-15866-31-git-send-email-xiong@qca.qualcomm.com>
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

it's unnecessary to reset/init phy when link down.
Only L1/L2 chip (supported by atlx) need such action.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9f6416e..7f2e8eb 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -264,8 +264,6 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 		atl1c_set_aspm(hw, SPEED_0);
 		netif_carrier_off(netdev);
 		netif_stop_queue(netdev);
-		atl1c_phy_reset(hw);
-		atl1c_phy_init(&adapter->hw);
 	} else {
 		/* Link Up */
 		hw->hibernate = false;
-- 
1.7.7
