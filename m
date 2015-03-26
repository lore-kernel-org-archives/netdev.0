From: Christian Hesse <list@eworm.de>
Subject: [PATCH 1/1] ip-link: allow human readable output with base of 1024 only for byte counts
Date: Thu, 26 Mar 2015 12:24:08 +0100
Message-ID: <1427369048-1433-1-git-send-email-list@eworm.de>
Cc: Christian Hesse <mail@eworm.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:44614 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbbCZLeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 07:34:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Hesse <mail@eworm.de>

Counting bytes with a base of 1024 is ok. Counting packets, errors, etc
that way makes no sense.
So only print byte counts with a base of 1024 if option -iec is given.

Signed-off-by: Christian Hesse <mail@eworm.de>
---
 ip/ipaddress.c | 98 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 49 insertions(+), 49 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5..016ce60 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -361,7 +361,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	}
 }
 
-static void print_num(FILE *fp, unsigned width, uint64_t count)
+static void print_num(FILE *fp, unsigned width, uint64_t count, int use_iec)
 {
 	const char *prefix = "kMGTPE";
 	const unsigned int base = use_iec ? 1024 : 1000;
@@ -408,14 +408,14 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 		s->rx_compressed ? "compressed" : "", _SL_);
 
 	fprintf(fp, "    ");
-	print_num(fp, 10, s->rx_bytes);
-	print_num(fp, 8, s->rx_packets);
-	print_num(fp, 7, s->rx_errors);
-	print_num(fp, 7, s->rx_dropped);
-	print_num(fp, 7, s->rx_over_errors);
-	print_num(fp, 7, s->multicast);
+	print_num(fp, 10, s->rx_bytes, use_iec);
+	print_num(fp, 8, s->rx_packets, 0);
+	print_num(fp, 7, s->rx_errors, 0);
+	print_num(fp, 7, s->rx_dropped, 0);
+	print_num(fp, 7, s->rx_over_errors,0 );
+	print_num(fp, 7, s->multicast, 0);
 	if (s->rx_compressed)
-		print_num(fp, 7, s->rx_compressed);
+		print_num(fp, 7, s->rx_compressed, 0);
 
 	/* RX error stats */
 	if (show_stats > 1) {
@@ -423,11 +423,11 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
 
 		fprintf(fp, "               ");
-		print_num(fp, 8, s->rx_length_errors);
-		print_num(fp, 7, s->rx_crc_errors);
-		print_num(fp, 7, s->rx_frame_errors);
-		print_num(fp, 7, s->rx_fifo_errors);
-		print_num(fp, 7, s->rx_missed_errors);
+		print_num(fp, 8, s->rx_length_errors, 0);
+		print_num(fp, 7, s->rx_crc_errors, 0);
+		print_num(fp, 7, s->rx_frame_errors, 0);
+		print_num(fp, 7, s->rx_fifo_errors, 0);
+		print_num(fp, 7, s->rx_missed_errors, 0);
 	}
 	fprintf(fp, "%s", _SL_);
 
@@ -437,14 +437,14 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 
 
 	fprintf(fp, "    ");
-	print_num(fp, 10, s->tx_bytes);
-	print_num(fp, 8, s->tx_packets);
-	print_num(fp, 7, s->tx_errors);
-	print_num(fp, 7, s->tx_dropped);
-	print_num(fp, 7, s->tx_carrier_errors);
-	print_num(fp, 7, s->collisions);
+	print_num(fp, 10, s->tx_bytes, use_iec);
+	print_num(fp, 8, s->tx_packets, 0);
+	print_num(fp, 7, s->tx_errors, 0);
+	print_num(fp, 7, s->tx_dropped, 0);
+	print_num(fp, 7, s->tx_carrier_errors, 0);
+	print_num(fp, 7, s->collisions, 0);
 	if (s->tx_compressed)
-		print_num(fp, 7, s->tx_compressed);
+		print_num(fp, 7, s->tx_compressed, 0);
 
 	/* TX error stats */
 	if (show_stats > 1) {
@@ -455,12 +455,12 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 		fprintf(fp, "%s", _SL_);
 
 		fprintf(fp, "               ");
-		print_num(fp, 8, s->tx_aborted_errors);
-		print_num(fp, 7, s->tx_fifo_errors);
-		print_num(fp, 7, s->tx_window_errors);
-		print_num(fp, 7, s->tx_heartbeat_errors);
+		print_num(fp, 8, s->tx_aborted_errors, 0);
+		print_num(fp, 7, s->tx_fifo_errors, 0);
+		print_num(fp, 7, s->tx_window_errors, 0);
+		print_num(fp, 7, s->tx_heartbeat_errors, 0);
 		if (carrier_changes)
-			print_num(fp, 7, *(uint32_t*)RTA_DATA(carrier_changes));
+			print_num(fp, 7, *(uint32_t*)RTA_DATA(carrier_changes), 0);
 	}
 }
 
@@ -473,25 +473,25 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 
 
 	fprintf(fp, "    ");
-	print_num(fp, 10, s->rx_bytes);
-	print_num(fp, 8, s->rx_packets);
-	print_num(fp, 7, s->rx_errors);
-	print_num(fp, 7, s->rx_dropped);
-	print_num(fp, 7, s->rx_over_errors);
-	print_num(fp, 7, s->multicast);
+	print_num(fp, 10, s->rx_bytes, use_iec);
+	print_num(fp, 8, s->rx_packets, 0);
+	print_num(fp, 7, s->rx_errors, 0);
+	print_num(fp, 7, s->rx_dropped, 0);
+	print_num(fp, 7, s->rx_over_errors, 0);
+	print_num(fp, 7, s->multicast, 0);
 	if (s->rx_compressed)
-		print_num(fp, 7, s->rx_compressed);
+		print_num(fp, 7, s->rx_compressed, 0);
 
 	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
 		fprintf(fp, "               ");
-		print_num(fp, 8, s->rx_length_errors);
-		print_num(fp, 7, s->rx_crc_errors);
-		print_num(fp, 7, s->rx_frame_errors);
-		print_num(fp, 7, s->rx_fifo_errors);
-		print_num(fp, 7, s->rx_missed_errors);
+		print_num(fp, 8, s->rx_length_errors, 0);
+		print_num(fp, 7, s->rx_crc_errors, 0);
+		print_num(fp, 7, s->rx_frame_errors, 0);
+		print_num(fp, 7, s->rx_fifo_errors, 0);
+		print_num(fp, 7, s->rx_missed_errors, 0);
 	}
 	fprintf(fp, "%s", _SL_);
 
@@ -500,14 +500,14 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 		s->tx_compressed ? "compressed" : "", _SL_);
 
 	fprintf(fp, "    ");
-	print_num(fp, 10, s->tx_bytes);
-	print_num(fp, 8, s->tx_packets);
-	print_num(fp, 7, s->tx_errors);
-	print_num(fp, 7, s->tx_dropped);
-	print_num(fp, 7, s->tx_carrier_errors);
-	print_num(fp, 7, s->collisions);
+	print_num(fp, 10, s->tx_bytes, use_iec);
+	print_num(fp, 8, s->tx_packets, 0);
+	print_num(fp, 7, s->tx_errors, 0);
+	print_num(fp, 7, s->tx_dropped, 0);
+	print_num(fp, 7, s->tx_carrier_errors, 0);
+	print_num(fp, 7, s->collisions, 0);
 	if (s->tx_compressed)
-		print_num(fp, 7, s->tx_compressed);
+		print_num(fp, 7, s->tx_compressed, 0);
 
 	/* TX error stats */
 	if (show_stats > 1) {
@@ -518,12 +518,12 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 		fprintf(fp, "%s", _SL_);
 
 		fprintf(fp, "               ");
-		print_num(fp, 8, s->tx_aborted_errors);
-		print_num(fp, 7, s->tx_fifo_errors);
-		print_num(fp, 7, s->tx_window_errors);
-		print_num(fp, 7, s->tx_heartbeat_errors);
+		print_num(fp, 8, s->tx_aborted_errors, 0);
+		print_num(fp, 7, s->tx_fifo_errors, 0);
+		print_num(fp, 7, s->tx_window_errors, 0);
+		print_num(fp, 7, s->tx_heartbeat_errors, 0);
 		if (carrier_changes)
-			print_num(fp, 7, *(uint32_t*)RTA_DATA(carrier_changes));
+			print_num(fp, 7, *(uint32_t*)RTA_DATA(carrier_changes), 0);
 	}
 }
 
-- 
2.3.4
