From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] count tg3 rx_discards stat for /proc/net/dev
Date: Wed, 12 May 2004 15:02:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A1AFD8.D5593759@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Linux Network Development list <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

G'day,

This small patch makes the rx_discards stat count towards the receive
error count visible in /proc/net/dev and thus in the output of ifconfig.
This stat is rarely non-zero unless you use multiple cards on the same
PCI bus under heavy load; but when it does happen you really want to
know about it.

Index: linux/drivers/net/tg3.c
===================================================================
--- linux.orig/drivers/net/tg3.c	Wed May 12 12:15:11 2004
+++ linux/drivers/net/tg3.c	Wed May 12 12:17:42 2004
@@ -5701,7 +5701,8 @@
 		get_stat64(&hw_stats->tx_octets);
 
 	stats->rx_errors = old_stats->rx_errors +
-		get_stat64(&hw_stats->rx_errors);
+		get_stat64(&hw_stats->rx_errors) +
+		get_stat64(&hw_stats->rx_discards);
 	stats->tx_errors = old_stats->tx_errors +
 		get_stat64(&hw_stats->tx_errors) +
 		get_stat64(&hw_stats->tx_mac_errors) +

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
