From: davej@codemonkey.org.uk
Subject: missing forward port.
Date: Tue, 11 Feb 2003 03:59:56 GMT
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200302110359.h1B3xuvo028206@noodles.internal>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch showed up in 2.4 a while back, and
still isn't in 2.5.

    Dave

diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/ipv4/tcp.c linux-2.5/net/ipv4/tcp.c
--- bk-linus/net/ipv4/tcp.c	2003-01-08 10:49:35.000000000 -0100
+++ linux-2.5/net/ipv4/tcp.c	2003-01-17 00:59:34.000000000 -0100
@@ -1192,7 +1192,8 @@ new_segment:
 
 			from += copy;
 			copied += copy;
-			seglen -= copy;
+			if ((seglen -= copy) == 0 && iovlen == 0)
+				goto out;
 
 			if (skb->len != mss_now || (flags & MSG_OOB))
 				continue;
