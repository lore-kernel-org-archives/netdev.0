From: Arthur Kepner <akepner@sgi.com>
Subject: [PATCH] fix "ethtool -S" for tg3
Date: Tue, 11 May 2004 12:57:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0405111251080.7038576@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here's a small mod I had to make to get "ethtool -S" to work with tg3 in
2.6.6:

8<-----------------------------------------------------------------------------
--- linux/drivers/net/tg3.c     2004-05-11 12:11:45.000000000 -0700
+++ linux.orig/drivers/net/tg3.c        2004-05-11 12:34:47.000000000 -0700
@@ -6288,7 +6288,7 @@
                                   struct ethtool_stats *estats, u64 *tmp_stats)
 {
        struct tg3 *tp = dev->priv;
-       memcpy(tmp_stats, &tp->estats, sizeof(tp->estats));
+       memcpy(tmp_stats, tg3_get_estats(tp), sizeof(tp->estats));
 }
8<-----------------------------------------------------------------------------

--

Arthur
