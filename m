From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Force IPv6 garbage collection on device down
Date: Mon, 05 Apr 2004 17:53:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3brm68lqy.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We had some problems with devices occasionally hanging with non zero
reference count on device destroy until the next time the IPv6 garbage
collection timer ran (upto 10s). 

To avoid that this patch forces an IPv6 FIB garbage collection
on device down.

-Andi

diff -u linux-2.6.5/net/ipv6/ndisc.c-N linux-2.6.5/net/ipv6/ndisc.c
--- linux-2.6.5/net/ipv6/ndisc.c-N	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5/net/ipv6/ndisc.c	2004-04-05 17:50:52.000000000 +0200
@@ -1403,6 +1403,9 @@
 		neigh_changeaddr(&nd_tbl, dev);
 		fib6_run_gc(0);
 		break;
+	case NETDEV_UNREGISTER:
+		fib6_run_gc(0);
+		break;
 	default:
 		break;
 	}
