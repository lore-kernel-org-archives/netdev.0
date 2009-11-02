From: Thiago Farina <tfransosi@gmail.com>
Subject: [PATCH] trivial: remove duplicated MIN macro from tehuti.
Date: Mon,  2 Nov 2009 15:45:14 -0500
Message-ID: <1257194714-5218-1-git-send-email-tfransosi@gmail.com>
References: <y>
Cc: baum@tehutinetworks.net, andy@greyhouse.net, davem@davemloft.net,
	shemminger@vyatta.com, apkm@linux-fundation.org,
	ben@decadent.org.uk, yanghy@cn.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Thiago Farina <tfransosi@gmail.com>
To: trivial@kernel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:35729 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932443AbZKBUph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 15:45:37 -0500
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the kernel api already has the macro "min",
just use it instead of declaring another one.

Signed-off-by: Thiago Farina <tfransosi@gmail.com>
---
 drivers/net/tehuti.c |    4 ++--
 drivers/net/tehuti.h |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index ec9dfb2..8d116a9 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1878,7 +1878,7 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
 			udelay(50);	/* give hw a chance to clean fifo */
 			continue;
 		}
-		avail = MIN(avail, size);
+		avail = min(avail, size);
 		DBG("about to push  %d bytes starting %p size %d\n", avail,
 		    data, size);
 		bdx_tx_push_desc(priv, data, avail);
@@ -1889,7 +1889,7 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
 }
 
 static const struct net_device_ops bdx_netdev_ops = {
-	.ndo_open	 	= bdx_open,
+	.ndo_open	        = bdx_open,
 	.ndo_stop		= bdx_close,
 	.ndo_start_xmit		= bdx_tx_transmit,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index 4fc875e..1241419 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -76,8 +76,6 @@
 #define FIFO_SIZE  4096
 #define FIFO_EXTRA_SPACE            1024
 
-#define MIN(x, y)  ((x) < (y) ? (x) : (y))
-
 #if BITS_PER_LONG == 64
 #    define H32_64(x)  (u32) ((u64)(x) >> 32)
 #    define L32_64(x)  (u32) ((u64)(x) & 0xffffffff)
-- 
1.6.5.1.61.ge79999

