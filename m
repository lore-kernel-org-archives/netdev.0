From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix 64bit warning/bug in farsync.c
Date: Tue, 7 Oct 2003 19:57:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007175757.GA1764@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: ncorbic@sangoma.com, davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix obvious 64bit bug/warning in farsync.c

diff -u linux-2.5-cleanup/drivers/net/wan/farsync.c-o linux-2.5-cleanup/drivers/net/wan/farsync.c
--- linux-2.5-cleanup/drivers/net/wan/farsync.c-o	2003-08-04 22:06:34.000000000 +0200
+++ linux-2.5-cleanup/drivers/net/wan/farsync.c	2003-12-02 16:50:08.040067224 +0100
@@ -317,7 +317,7 @@
 };
 
 /* Calculate offset of a buffer object within the shared memory window */
-#define BUF_OFFSET(X)   ((unsigned int)&(((struct buf_window *)BFM_BASE)->X))
+#define BUF_OFFSET(X)   offsetof(struct buf_window, X)
 
 #pragma pack()
 
