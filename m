From: akpm@linux-foundation.org
Subject: [patch 7/7] pppol2tp: fix printk warnings
Date: Fri, 08 Feb 2008 03:11:17 -0800
Message-ID: <200802081120.m18BK9QQ021642@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41096 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755609AbYBHLUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:20:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/pppol2tp.c: In function `pppol2tp_seq_tunnel_show':
drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 4)
drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 5)
drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 6)
drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 7)
drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 8)
drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 9)
drivers/net/pppol2tp.c: In function `pppol2tp_seq_session_show':
drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 5)
drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 6)
drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 7)
drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 8)
drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 9)
drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 10)

Not all platforms implement u64 with unsigned long long.  eg: powerpc.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/pppol2tp.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff -puN drivers/net/pppol2tp.c~pppol2tp-fix-printk-warnings drivers/net/pppol2tp.c
--- a/drivers/net/pppol2tp.c~pppol2tp-fix-printk-warnings
+++ a/drivers/net/pppol2tp.c
@@ -2289,10 +2289,12 @@ static void pppol2tp_seq_tunnel_show(str
 		   atomic_read(&tunnel->ref_count) - 1);
 	seq_printf(m, " %08x %llu/%llu/%llu %llu/%llu/%llu\n",
 		   tunnel->debug,
-		   tunnel->stats.tx_packets, tunnel->stats.tx_bytes,
-		   tunnel->stats.tx_errors,
-		   tunnel->stats.rx_packets, tunnel->stats.rx_bytes,
-		   tunnel->stats.rx_errors);
+		   (unsigned long long)tunnel->stats.tx_packets,
+		   (unsigned long long)tunnel->stats.tx_bytes,
+		   (unsigned long long)tunnel->stats.tx_errors,
+		   (unsigned long long)tunnel->stats.rx_packets,
+		   (unsigned long long)tunnel->stats.rx_bytes,
+		   (unsigned long long)tunnel->stats.rx_errors);
 }
 
 static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
@@ -2320,12 +2322,12 @@ static void pppol2tp_seq_session_show(st
 		   jiffies_to_msecs(session->reorder_timeout));
 	seq_printf(m, "   %hu/%hu %llu/%llu/%llu %llu/%llu/%llu\n",
 		   session->nr, session->ns,
-		   session->stats.tx_packets,
-		   session->stats.tx_bytes,
-		   session->stats.tx_errors,
-		   session->stats.rx_packets,
-		   session->stats.rx_bytes,
-		   session->stats.rx_errors);
+		   (unsigned long long)session->stats.tx_packets,
+		   (unsigned long long)session->stats.tx_bytes,
+		   (unsigned long long)session->stats.tx_errors,
+		   (unsigned long long)session->stats.rx_packets,
+		   (unsigned long long)session->stats.rx_bytes,
+		   (unsigned long long)session->stats.rx_errors);
 }
 
 static int pppol2tp_seq_show(struct seq_file *m, void *v)
_
