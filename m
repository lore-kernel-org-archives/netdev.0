From: Torsten Kaiser <just.for.lkml@googlemail.com>
Subject: [PATCH]Fix misplaces parenthesis in virtio_net.c
Date: Mon, 9 Apr 2012 17:14:15 +0200
Message-ID: <20120409171415.4c49c96a@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 2e57b79ccef1ff1422fdf45a9b28fe60f8f084f7 misplaced its
parenthesis and now tx_fifo_errors will only be incremented if an
ENOMEM error is not written to the syslog.

Correct the parenthesis and indentation to the original goal of
counting all non ENOMEM errors and ratelimiting only the messages.

Signed-of-by: Torsten Kaiser <just.for.lkml@googlemail.com>

--- a/drivers/net/virtio_net.c	2012-04-09 16:55:31.366847092 +0200
+++ b/drivers/net/virtio_net.c	2012-04-09 16:56:31.196847799 +0200
@@ -626,16 +626,15 @@
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
 		if (likely(capacity == -ENOMEM)) {
-			if (net_ratelimit()) {
+			if (net_ratelimit())
 				dev_warn(&dev->dev,
 					 "TX queue failure: out of memory\n");
-			} else {
+		} else {
 			dev->stats.tx_fifo_errors++;
 			if (net_ratelimit())
 				dev_warn(&dev->dev,
 					 "Unexpected TX queue failure: %d\n",
 					 capacity);
-			}
 		}
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
