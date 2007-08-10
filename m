From: akpm@linux-foundation.org
Subject: [patch 13/18] natsemi: fix netdev error acounting
Date: Fri, 10 Aug 2007 14:05:23 -0700
Message-ID: <200708102105.l7AL5NBY008983@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	loveminix@yahoo.com.cn, protasnb@gmail.com, thockin@hockin.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44892 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760511AbXHJVQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

When a detailed netdev error is counted, we also must account for it in the
aggregated error count.

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=8106

Cc: Tim Hockin <thockin@hockin.org>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Chongfeng Hu <loveminix@yahoo.com.cn>
Cc: Natalie Protasevich <protasnb@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/natsemi.c |    3 +++
 1 files changed, 3 insertions(+)

diff -puN drivers/net/natsemi.c~natsemi-fix-netdev-error-acounting drivers/net/natsemi.c
--- a/drivers/net/natsemi.c~natsemi-fix-netdev-error-acounting
+++ a/drivers/net/natsemi.c
@@ -2438,13 +2438,16 @@ static void netdev_error(struct net_devi
 				dev->name);
 		}
 		np->stats.rx_fifo_errors++;
+		np->stats.rx_errors++;
 	}
 	/* Hmmmmm, it's not clear how to recover from PCI faults. */
 	if (intr_status & IntrPCIErr) {
 		printk(KERN_NOTICE "%s: PCI error %#08x\n", dev->name,
 			intr_status & IntrPCIErr);
 		np->stats.tx_fifo_errors++;
+		np->stats.tx_errors++;
 		np->stats.rx_fifo_errors++;
+		np->stats.rx_errors++;
 	}
 	spin_unlock(&np->lock);
 }
_
