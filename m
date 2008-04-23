From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.25 1/2]S2io: Fix memory leak during free_tx_buffers
Date: Wed, 23 Apr 2008 13:28:08 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231326590.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39365 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbYDWR23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fix the memory leak during free_tx_buffers.
 
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.20/drivers/net/s2io.c 2.0.26.22-1/drivers/net/s2io.c
--- 2.0.26.20/drivers/net/s2io.c	2008-04-22 15:02:38.000000000 -0700
+++ 2.0.26.22-1/drivers/net/s2io.c	2008-04-22 15:12:25.000000000 -0700
@@ -2339,7 +2339,7 @@ static void free_tx_buffers(struct s2io_
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		unsigned long flags;
 		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags);
-		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
+		for (j = 0; j < config->tx_cfg[i].fifo_len; j++) {
 			txdp = (struct TxD *) \
 			mac_control->fifos[i].list_info[j].list_virt_addr;
 			skb = s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);

