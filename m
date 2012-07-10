From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 07/11] qlge: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:31 -0700
Message-ID: <1341878975-10577-7-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab2GJAJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:34 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:34 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set by the driver on packet recieve.
eth_type_trans already sets skb->dev to the proper value and it is not
referenced anywhere else in the dirver, thus making its setting unnecessary.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
Cc: linux-driver@qlogic.com
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 3c3499d..ca427eb 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1619,7 +1619,6 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	}
 
 	prefetch(skb->data);
-	skb->dev = ndev;
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
 		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 			     "%s Multicast.\n",
@@ -1934,7 +1933,6 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 	}
 
 	prefetch(skb->data);
-	skb->dev = ndev;
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
 		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev, "%s Multicast.\n",
 			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-- 
1.7.9.5
