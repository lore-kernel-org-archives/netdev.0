From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 07/10] atl1c: remove PHY reset/init for link down event
Date: Thu, 26 Apr 2012 14:27:15 +0800
Message-ID: <1335421638-16304-8-git-send-email-xiong@qca.qualcomm.com>
References: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:21619 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab2DZG3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 02:29:01 -0400
In-Reply-To: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it's unnecessary to reset/init phy when link down.
Only L1/L2 chip (supported by atlx) need such action.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 995da22..cb3b3c4 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -270,8 +270,6 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
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
