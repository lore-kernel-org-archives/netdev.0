From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] au1000_eth: Duplicate test of RX_OVERLEN bit in update_rx_stats()
Date: Tue, 06 Oct 2009 21:54:18 +0200
Message-ID: <4ACBA06A.6050208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	manuel.lauss@gmail.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:26364 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932457AbZJFTqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:46:40 -0400
Received: by ey-out-2122.google.com with SMTP id 4so874875eyf.19
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2009 12:45:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in update_rx_stats() the RX_OVERLEN bit is set twice, replace it by RX_RUNT.
in au1000_rx() the RX_MISSED_FRAME bit was tested a few lines earlier already

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
please review, I merely guessed it should be RX_RUNT.

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index fdf5937..04f63c7 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -721,7 +721,7 @@ static inline void update_rx_stats(struct net_device *dev, u32 status)
 		ps->rx_errors++;
 		if (status & RX_MISSED_FRAME)
 			ps->rx_missed_errors++;
-		if (status & (RX_OVERLEN | RX_OVERLEN | RX_LEN_ERROR))
+		if (status & (RX_OVERLEN | RX_RUNT | RX_LEN_ERROR))
 			ps->rx_length_errors++;
 		if (status & RX_CRC_ERROR)
 			ps->rx_crc_errors++;
@@ -794,8 +794,6 @@ static int au1000_rx(struct net_device *dev)
 					printk("rx len error\n");
 				if (status & RX_U_CNTRL_FRAME)
 					printk("rx u control frame\n");
-				if (status & RX_MISSED_FRAME)
-					printk("rx miss\n");
 			}
 		}
 		prxd->buff_stat = (u32)(pDB->dma_addr | RX_DMA_ENABLE);
