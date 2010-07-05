From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/6] qlge: Restore promiscuous setting after reset.
Date: Mon,  5 Jul 2010 15:19:37 -0700
Message-ID: <1278368382-23887-2-git-send-email-ron.mercer@qlogic.com>
References: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:42713 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755045Ab0GEXFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 19:05:19 -0400
In-Reply-To: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index bfb8b32..01b0634 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2246,6 +2246,7 @@ netdev_tx_t ql_lb_send(struct sk_buff *skb, struct net_device *ndev);
 void ql_check_lb_frame(struct ql_adapter *, struct sk_buff *);
 int ql_own_firmware(struct ql_adapter *qdev);
 int ql_clean_lb_rx_ring(struct rx_ring *rx_ring, int budget);
+void qlge_set_multicast_list(struct net_device *ndev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fa4b24c..e99c2c6 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3919,6 +3919,11 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	if ((ql_read32(qdev, STS) & qdev->port_init) &&
 			(ql_read32(qdev, STS) & qdev->port_link_up))
 		ql_link_on(qdev);
+	/* Restore rx mode. */
+	clear_bit(QL_ALLMULTI, &qdev->flags);
+	clear_bit(QL_PROMISCUOUS, &qdev->flags);
+	qlge_set_multicast_list(qdev->ndev);
+
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	netif_tx_start_all_queues(qdev->ndev);
@@ -4204,7 +4209,7 @@ static struct net_device_stats *qlge_get_stats(struct net_device
 	return &ndev->stats;
 }
 
-static void qlge_set_multicast_list(struct net_device *ndev)
+void qlge_set_multicast_list(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct netdev_hw_addr *ha;
-- 
1.6.0.2

