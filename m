From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 15/18] net/ena: remove affinity hint from the driver
Date: Sun, 20 Nov 2016 10:45:44 +0200
Message-ID: <1479631547-29354-16-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f177.google.com ([209.85.210.177]:35294 "EHLO
        mail-wj0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752145AbcKTIwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:52:46 -0500
Received: by mail-wj0-f177.google.com with SMTP id v7so14035743wjy.2
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:52:45 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allow irqbalance to better distribute the napi handler,
remove the smp affinity hint from the driver.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index eda5fb5..bff082a 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1331,8 +1331,6 @@ static int ena_request_mgmnt_irq(struct ena_adapter *adapter)
 		  "set affinity hint of mgmnt irq.to 0x%lx (irq vector: %d)\n",
 		  irq->affinity_hint_mask.bits[0], irq->vector);
 
-	irq_set_affinity_hint(irq->vector, &irq->affinity_hint_mask);
-
 	return rc;
 }
 
@@ -1362,8 +1360,6 @@ static int ena_request_io_irq(struct ena_adapter *adapter)
 		netif_dbg(adapter, ifup, adapter->netdev,
 			  "set affinity hint of irq. index %d to 0x%lx (irq vector: %d)\n",
 			  i, irq->affinity_hint_mask.bits[0], irq->vector);
-
-		irq_set_affinity_hint(irq->vector, &irq->affinity_hint_mask);
 	}
 
 	return rc;
-- 
1.9.1
