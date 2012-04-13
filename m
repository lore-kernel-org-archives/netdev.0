From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 35/37] atl1c: remove code of closing register writable attribution
Date: Fri, 13 Apr 2012 08:15:00 +0800
Message-ID: <1334276102-15866-36-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:48642 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966661Ab2DMAUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 20:20:55 -0400
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Close-action is done by atl1c_reset_pcie, remove it from
atl1c_get_permanent_address.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index cd52d37..3eaf78a 100644
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
