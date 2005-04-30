From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [RTNETLINK] Fix RTM_MAX to represent the maximum valid message =?ISO-8859-1?Q?type=0C?=
Date: Sat, 30 Apr 2005 21:50:58 +0200
Message-ID: <20050430195058.GC577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

RTM_MAX is currently set to the maximum reserverd message type plus one
thus being the cause of two bugs for new types being assigned a) given the
new family registers only the NEW command in its reserved block the array
size for per family entries is calculated one entry short and b) given the
new family registers all commands RTM_MAX would point to the first entry
of the block following this one and the rtnetlink receive path would accept
a message type for a nonexisting family.

This patch changes RTM_MAX to point to the maximum valid message type
by aligning it to the start of the next block and subtracting one.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.12-rc3.orig/include/linux/rtnetlink.h	2005-04-30 20:22:19.000000000 +0200
+++ linux-2.6.12-rc3/include/linux/rtnetlink.h	2005-04-30 20:25:09.000000000 +0200
@@ -89,8 +89,8 @@
 	RTM_GETANYCAST	= 62,
 #define RTM_GETANYCAST	RTM_GETANYCAST
 
-	RTM_MAX,
-#define RTM_MAX		RTM_MAX
+	__RTM_MAX,
+#define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
 
 /* 
