From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 08/12] atl1c: wrong register used to stop TXQ
Date: Sat, 14 Apr 2012 17:59:24 +0800
Message-ID: <1334397568-8444-9-git-send-email-xiong@qca.qualcomm.com>
References: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

function atl1c_stop_mac uses wrong register of REG_TWSI_CTRL
to stop mac, replace it with REG_TXQ_CTRL.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index ca1259d..b36c033 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1142,7 +1142,7 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
 
 	AT_READ_REG(hw, REG_TXQ_CTRL, &data);
 	data &= ~TXQ_CTRL_EN;
-	AT_WRITE_REG(hw, REG_TWSI_CTRL, data);
+	AT_WRITE_REG(hw, REG_TXQ_CTRL, data);
 
 	atl1c_wait_until_idle(hw);
 
-- 
1.7.7
