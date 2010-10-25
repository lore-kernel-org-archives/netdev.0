From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Restoring the vlan setting.
Date: Mon, 25 Oct 2010 09:17:51 -0700
Message-ID: <1288023473-31490-2-git-send-email-ron.mercer@qlogic.com>
References: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:57791 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754912Ab0JYRFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 13:05:46 -0400
In-Reply-To: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index ba0053d..ed0c63d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2382,6 +2382,20 @@ static void qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 }
 
+static void qlge_restore_vlan(struct ql_adapter *qdev)
+{
+	qlge_vlan_rx_register(qdev->ndev, qdev->vlgrp);
+
+	if (qdev->vlgrp) {
+		u16 vid;
+			for (vid = 0; vid < VLAN_N_VID; vid++) {
+				if (!vlan_group_get_device(qdev->vlgrp, vid))
+					continue;
+				qlge_vlan_rx_add_vid(qdev->ndev, vid);
+			}
+	}
+}
+
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
 static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
@@ -3957,6 +3971,9 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	clear_bit(QL_PROMISCUOUS, &qdev->flags);
 	qlge_set_multicast_list(qdev->ndev);
 
+	/* Restore vlan setting. */
+	qlge_restore_vlan(qdev);
+
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	netif_tx_start_all_queues(qdev->ndev);
-- 
1.6.0.2

