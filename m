From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Force IPv6 FIB gc on device shutdown
Date: Fri, 9 Apr 2004 17:39:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409173901.62ebf75b.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


A few people reported problems with shutdown complaining about lost reference
counts in network devices. The problem was that the IPv6 FIB kept some
device references around and only dropped it on the next GC timer run, which
happens only every 10s.

This patch forces a garbage collection on device shutdown.

-Andi

diff -u linux/net/ipv6/ndisc.c-o linux/net/ipv6/ndisc.c
--- linux/net/ipv6/ndisc.c-o	2004-04-04 23:35:36.000000000 +0200
+++ linux/net/ipv6/ndisc.c	2004-04-05 15:11:07.000000000 +0200
@@ -1564,6 +1564,9 @@
 		neigh_changeaddr(&nd_tbl, dev);
 		fib6_run_gc(0);
 		break;
+	case NETDEV_UNREGISTER:
+		fib6_run_gc(0);
+		break;
 	default:
 		break;
 	}
