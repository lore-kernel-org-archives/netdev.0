From: <cjren@qca.qualcomm.com>
Subject: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Wed, 4 Jul 2012 10:51:48 +0800
Message-ID: <1341370308-23233-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:17878 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426Ab2GDCvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 22:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

some people report atl1c could cause system hang with following
kernel trace info:
---------------------------------------
WARNING: at.../net/sched/sch_generic.c:258 dev_watchdog+0x1db/0x1d0()
...
NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
...
---------------------------------------
This is caused by netif_stop_queue calling when cable Link is down.
So remove netif_stop_queue, because link_watch will take it over.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Cc: stable <stable@vger.kernel.org>
Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 85717cb..7901831 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -261,7 +261,6 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 	if ((phy_data & BMSR_LSTATUS) == 0) {
 		/* link down */
 		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
 		hw->hibernate = true;
 		if (atl1c_reset_mac(hw) != 0)
 			if (netif_msg_hw(adapter))
-- 
1.7.7
