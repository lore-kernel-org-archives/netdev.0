From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] option for large routing hash
Date: Tue, 9 Dec 2003 16:09:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16341.58771.558850.163216@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

I think patch should be useful as it helps performance a lot during high 
flow load. I have some numbers if you are interested.

Cheers.	
						--ro


--- net/ipv4/Kconfig.orig	2003-12-09 14:00:14.000000000 +0100
+++ net/ipv4/Kconfig	2003-12-09 14:51:27.000000000 +0100
@@ -75,6 +75,19 @@
 
 	  If unsure, say N.
 
+config IP_ROUTE_LARGE_HASH
+	  bool "IP: large routing hash"
+	---help---
+	  Say yes to increase the number of dst hash buckets. Most likely you
+	  are running a server or router with lots of flows. Saying yes 
+	  will increase used dst hash 8 times typically from 16Kbytes to 128 
+	  Kbytes on a 256Mbytes system.
+
+	  dst hash is otherwise tunable via /proc/sys/net/ipv4/route/
+	  Monitoring can be done with rtstat utility this comes with iproute2.
+
+	  If unsure, say N.
+
 config IP_ROUTE_FWMARK
 	bool "IP: use netfilter MARK value as routing key"
 	depends on IP_MULTIPLE_TABLES && NETFILTER
--- net/ipv4/route.c.orig	2003-12-09 13:59:57.000000000 +0100
+++ net/ipv4/route.c	2003-12-09 14:49:48.000000000 +0100
@@ -2747,6 +2747,9 @@
 
 	goal = num_physpages >> (26 - PAGE_SHIFT);
 
+#ifdef CONFIG_IP_ROUTE_LARGE_HASH
+	goal <<= 3;
+#endif
 	for (order = 0; (1UL << order) < goal; order++)
 		/* NOTHING */;
 
