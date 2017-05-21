From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 07/10] qede: qedr closure after setting state
Date: Sun, 21 May 2017 12:10:58 +0300
Message-ID: <1495357860-28280-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0065.outbound.protection.outlook.com ([104.47.37.65]:61216
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752738AbdEUJL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:11:56 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is benign, but it makes more sense to start the close sequence
only after changing the internal state [in case it would once care].

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index a66bdfe..f0871e1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1899,9 +1899,10 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode,
 	if (!is_locked)
 		__qede_lock(edev);
 
-	qede_roce_dev_event_close(edev);
 	edev->state = QEDE_STATE_CLOSED;
 
+	qede_roce_dev_event_close(edev);
+
 	/* Close OS Tx */
 	netif_tx_disable(edev->ndev);
 	netif_carrier_off(edev->ndev);
-- 
1.9.3
