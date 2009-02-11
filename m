From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/7] qlge: bugfix: Use netif_receive_skb() and vlan_hwaccel_receive_skb().
Date: Wed, 11 Feb 2009 05:58:31 -0800
Message-ID: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbZBKOBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace calls to vlan_hwaccel_rx() and netif_rx().
Thanks to Dave Miller for pointing out the the driver was making
the wrong upcall for passing packets into the stack.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3d1d7b6..27c5e4d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1449,12 +1449,12 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	if (qdev->vlgrp && (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V)) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"Passing a VLAN packet upstream.\n");
-		vlan_hwaccel_rx(skb, qdev->vlgrp,
+		vlan_hwaccel_receive_skb(skb, qdev->vlgrp,
 				le16_to_cpu(ib_mac_rsp->vlan_id));
 	} else {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"Passing a normal packet upstream.\n");
-		netif_rx(skb);
+		netif_receive_skb(skb);
 	}
 }
 
-- 
1.6.0.2

