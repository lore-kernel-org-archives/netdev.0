From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 00:03:27 +0100
Message-ID: <20050128230327.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NLMSG_GOODSIZE specifies a good default size for the skb tailroom
used in netlink messages when the size is unknown at the time of
the allocation.

The current value doesn't make much sense anymore because
skb_shared_info isn't taken into account which means that
depending on the architecture NLMSG_GOOSIZE can exceed PAGE_SIZE
resulting in a waste of almost a complete page.

Using SKB_MAXORDER solves this potential leak at the cost of
slightly smaller but safer sizes for some architectures.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-rc2-bk4.orig/include/linux/netlink.h	2005-01-26 18:19:27.000000000 +0100
+++ linux-2.6.11-rc2-bk4/include/linux/netlink.h	2005-01-28 23:06:02.000000000 +0100
@@ -133,10 +133,9 @@
 
 /*
  *	skb should fit one page. This choice is good for headerless malloc.
- *
- *      FIXME: What is the best size for SLAB???? --ANK
  */
-#define NLMSG_GOODSIZE (PAGE_SIZE - ((sizeof(struct sk_buff)+0xF)&~0xF))
+#define NLMSG_GOODORDER 0
+#define NLMSG_GOODSIZE (SKB_MAX_ORDER(0, NLMSG_GOODORDER))
 
 
 struct netlink_callback
