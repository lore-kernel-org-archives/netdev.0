From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT in wanpipe
Date: Sun, 22 Feb 2004 20:21:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222192059.GA28659@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

wanpipe_open/close are used by sub-modules in their open/close handlers,
thus locking sdlamain into memory by using the exports


--- 1.21/drivers/net/wan/sdlamain.c	Mon Sep 22 03:01:11 2003
+++ edited/drivers/net/wan/sdlamain.c	Sun Oct  5 16:23:10 2003
@@ -1161,7 +1161,6 @@
 void wanpipe_open (sdla_t* card)
 {
 	++card->open_cnt;
-	MOD_INC_USE_COUNT;
 }
 
 /*============================================================================
@@ -1173,7 +1172,6 @@
 void wanpipe_close (sdla_t* card)
 {
 	--card->open_cnt;
-	MOD_DEC_USE_COUNT;
 }
 
 /*============================================================================
