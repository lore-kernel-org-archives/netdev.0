From: <akepner@sgi.com>
Subject: [PATCH 1/2] net/tg3.c: use mmiowb in tg3_rx, tg3_start_xmit
Date: Tue, 12 Oct 2004 16:34:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0410121630200.31839-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <gnb@sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Using mmiowb() prevents an occasional oops in tg3_tx() resulting from 
a NULL skb pointer in the tx_ring_info structure.


Signed-off-by: Greg Banks <gnb@sgi.com>
---

--- linux.1/drivers/net/tg3.c	2004-10-12 13:50:39.000000000 -0700
+++ linux/drivers/net/tg3.c	2004-10-12 13:55:37.000000000 -0700
@@ -2729,6 +2729,7 @@
 		tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
 			     sw_idx);
 	}
+	mmiowb();
 
 	return received;
 }
@@ -3176,6 +3177,7 @@
 		netif_stop_queue(dev);
 
 out_unlock:
+	mmiowb();
 	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	dev->trans_start = jiffies;
