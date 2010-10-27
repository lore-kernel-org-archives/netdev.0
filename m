From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/1] qlge: bugfix: Restoring the vlan setting.
Date: Wed, 27 Oct 2010 07:58:12 -0700
Message-ID: <1288191492-1967-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:38295 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933188Ab0J0PKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 11:10:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e621056..c30e0fe 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2385,6 +2385,20 @@ static void qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 }
 
+static void qlge_restore_vlan(struct ql_adapter *qdev)
+{
+	qlge_vlan_rx_register(qdev->ndev, qdev->vlgrp);
+
+	if (qdev->vlgrp) {
+		u16 vid;
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
+			if (!vlan_group_get_device(qdev->vlgrp, vid))
+				continue;
+			qlge_vlan_rx_add_vid(qdev->ndev, vid);
+		}
+	}
+}
+
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
 static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
@@ -3960,6 +3974,9 @@ static int ql_adapter_up(struct ql_adapter *qdev)
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

