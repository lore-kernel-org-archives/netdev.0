From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 4/4] tcp: statistics not read_mostly
Date: Mon, 12 Mar 2007 14:08:21 -0700
Message-ID: <20070312210907.925541692@linux-foundation.org>
References: <20070312210817.485320783@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42392 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932424AbXCLVJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 17:09:34 -0400
Content-Disposition: inline; filename=tcp_stats-not-mostly
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCP statistics shouldn't be located in the middle of the
read_mostly section surrounded by sysctl values.
Move EXPORT_SYMBOL next to data like other declarations near by.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/tcp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- net-2.6.22.orig/net/ipv4/tcp.c	2007-03-12 14:05:26.000000000 -0700
+++ net-2.6.22/net/ipv4/tcp.c	2007-03-12 14:06:08.000000000 -0700
@@ -271,7 +271,8 @@
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
-DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics) __read_mostly;
+DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics);
+EXPORT_SYMBOL(tcp_statistics);
 
 atomic_t tcp_orphan_count = ATOMIC_INIT(0);
 
@@ -2492,4 +2493,3 @@
 EXPORT_SYMBOL(tcp_sendpage);
 EXPORT_SYMBOL(tcp_setsockopt);
 EXPORT_SYMBOL(tcp_shutdown);
-EXPORT_SYMBOL(tcp_statistics);

--
Stephen Hemminger <shemminger@linux-foundation.org>

