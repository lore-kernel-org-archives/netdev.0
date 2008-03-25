From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.25 1/2]S2io: Handle TX completions on the same CPU as
 the sender for MIS-X interrupts
Date: Tue, 25 Mar 2008 15:11:56 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10803251510470.22948-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:54970 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbYCYTMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 15:12:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Handling TX completions on the same cpu as the sender.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
---
diff -Nurp 2-0-26-19/drivers/net/s2io.c 2-0-26-21-1/drivers/net/s2io.c
--- 2-0-26-19/drivers/net/s2io.c	2008-03-20 09:22:03.000000000 +0530
+++ 2-0-26-21-1/drivers/net/s2io.c	2008-03-20 10:22:25.000000000 +0530
@@ -4344,6 +4344,9 @@ static int s2io_xmit(struct sk_buff *skb
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
+	if (sp->config.intr_type == MSI_X)
+		tx_intr_handler(fifo);
+
 	return 0;
 pci_map_failed:
 	stats->pci_map_fail_cnt++;

