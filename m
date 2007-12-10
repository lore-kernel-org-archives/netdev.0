From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv4] ESP: Discard dummy packets introduced in rfc4303
Date: Mon, 10 Dec 2007 23:17:03 +0100
Message-ID: <20071210221703.GG11220@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@damveloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46629 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbXLJWlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 17:41:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4303 introduces dummy packets with a nexthdr value of 59
to implement traffic confidentiality. Such packets need to
be dropped silently and the payload may not be attempted to
be parsed as it consists of random chunk.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.25/net/ipv4/esp4.c
===================================================================
--- net-2.6.25.orig/net/ipv4/esp4.c	2007-12-10 15:57:23.000000000 +0100
+++ net-2.6.25/net/ipv4/esp4.c	2007-12-10 16:06:10.000000000 +0100
@@ -9,6 +9,7 @@
 #include <linux/pfkeyv2.h>
 #include <linux/random.h>
 #include <linux/spinlock.h>
+#include <linux/in6.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
 #include <net/udp.h>
@@ -233,6 +234,10 @@
 
 	/* ... check padding bits here. Silly. :-) */
 
+	/* RFC4303: Drop dummy packets without any error */
+	if (nexthdr[1] == IPPROTO_NONE)
+		goto out;
+
 	iph = ip_hdr(skb);
 	ihl = iph->ihl * 4;
 
