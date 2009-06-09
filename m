From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/8] qlge: Drop inbound frames > MTU.
Date: Tue,  9 Jun 2009 08:39:28 -0700
Message-ID: <1244561974-25662-2-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbZFIPrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:14 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The max frame size register is set higher than the MTU to
accomodate FCoE frames.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 45da405..7c17aa2 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1525,6 +1525,15 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 		dev_kfree_skb_any(skb);
 		return;
 	}
+
+	/* The max framesize filter on this chip is set higher than
+	 * MTU since FCoE uses 2k frames.
+	 */
+	if (skb->len > ndev->mtu + ETH_HLEN) {
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
 	prefetch(skb->data);
 	skb->dev = ndev;
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
-- 
1.6.0.2

