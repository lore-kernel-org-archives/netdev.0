From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix warnings in defxx.c
Date: Tue, 7 Oct 2003 19:55:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007175535.GA1743@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix harmless 64bit warnings in defxx.c

diff -u linux-2.5-cleanup/drivers/net/defxx.c-o linux-2.5-cleanup/drivers/net/defxx.c
--- linux-2.5-cleanup/drivers/net/defxx.c-o	2003-08-22 13:35:29.000000000 +0200
+++ linux-2.5-cleanup/drivers/net/defxx.c	2003-12-02 17:12:55.629162080 +0100
@@ -2664,8 +2664,8 @@
  
 static void my_skb_align(struct sk_buff *skb, int n)
 {
-	u32 x=(u32)skb->data;	/* We only want the low bits .. */
-	u32 v;
+	unsigned long x=(unsigned long)skb->data;	
+	unsigned long v;
 	
 	v=(x+n-1)&~(n-1);	/* Where we want to be */
 	
