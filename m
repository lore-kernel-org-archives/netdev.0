From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 04/10] atl1c: remove code of closing register writable attribution
Date: Tue, 1 May 2012 09:38:52 +0800
Message-ID: <1335836338-9425-5-git-send-email-xiong@qca.qualcomm.com>
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

The Close-action is done by atl1c_reset_pcie, remove it from
atl1c_get_permanent_address.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 49f433e..2522685 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -72,7 +72,6 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
 	u32 i;
 	u32 otp_ctrl_data;
 	u32 twsi_ctrl_data;
-	u32 ltssm_ctrl_data;
 	u8  eth_addr[ETH_ALEN];
 	u16 phy_data;
 	bool raise_vol = false;
@@ -108,11 +107,6 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
 			udelay(20);
 			raise_vol = true;
 		}
-		/* close open bit of ReadOnly*/
-		AT_READ_REG(hw, REG_LTSSM_ID_CTRL, &ltssm_ctrl_data);
-		ltssm_ctrl_data &= ~LTSSM_ID_EN_WRO;
-		AT_WRITE_REG(hw, REG_LTSSM_ID_CTRL, ltssm_ctrl_data);
-
 
 		AT_READ_REG(hw, REG_TWSI_CTRL, &twsi_ctrl_data);
 		twsi_ctrl_data |= TWSI_CTRL_SW_LDSTART;
-- 
1.7.7
