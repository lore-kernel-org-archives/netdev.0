From: akpm@osdl.org
Subject: [patch 2/9] use mmiowb in tg3.c
Date: Thu, 28 Oct 2004 00:19:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Ld907983@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, jbarnes@engr.sgi.com,
        gnb@sgi.com, jbarnes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Jesse Barnes <jbarnes@engr.sgi.com>

This patch originally from Greg Banks.  Some parts of the tg3 driver depend
on PIO writes arriving in order.  This patch ensures that in two key places
using the new mmiowb macro.  This not only prevents bugs (the queues can be
corrupted), but is much faster than ensuring ordering using PIO reads
(which involve a few round trips to the target bus on some platforms).

Arthur has another patch that uses mmiowb in tg3 that he posted earlier as
well.

Signed-off-by: Greg Banks <gnb@sgi.com>
Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/tg3.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN drivers/net/tg3.c~use-mmiowb-in-tg3c drivers/net/tg3.c
--- 25/drivers/net/tg3.c~use-mmiowb-in-tg3c	2004-10-28 00:17:07.520660672 -0700
+++ 25-akpm/drivers/net/tg3.c	2004-10-28 00:18:16.861119320 -0700
@@ -2730,6 +2730,7 @@ next_pkt_nopost:
 		tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
 			     sw_idx);
 	}
+	mmiowb();
 
 	return received;
 }
@@ -3177,6 +3178,7 @@ static int tg3_start_xmit(struct sk_buff
 		netif_stop_queue(dev);
 
 out_unlock:
+    	mmiowb();
 	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	dev->trans_start = jiffies;
_
