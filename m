From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/6] myri10ge: support new firmware counters
Date: Mon, 07 May 2007 23:49:25 +0200
Message-ID: <463F9EE5.1060605@myri.com>
References: <463F9E9E.8000808@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1803 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966692AbXEGVt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:49:28 -0400
In-Reply-To: <463F9E9E.8000808@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add dropped_pause, dropped_bad_phy, dropped_bad_crc32,
dropped_unicast_filtered to the set of ethtool counters.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c     |    9 ++++++++-
 drivers/net/myri10ge/myri10ge_mcp.h |    6 +++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:14:39.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:20:45.000000000 +0200
@@ -1355,7 +1355,9 @@
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
 	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
 	"link_changes", "link_up", "dropped_link_overflow",
-	"dropped_link_error_or_filtered", "dropped_multicast_filtered",
+	"dropped_link_error_or_filtered",
+	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
+	"dropped_unicast_filtered", "dropped_multicast_filtered",
 	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
 	"dropped_no_big_buffer"
 };
@@ -1412,6 +1414,11 @@
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
 	data[i++] =
 	    (unsigned int)ntohl(mgp->fw_stats->dropped_link_error_or_filtered);
+	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_pause);
+	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_phy);
+	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_crc32);
+	data[i++] =
+	    (unsigned int)ntohl(mgp->fw_stats->dropped_unicast_filtered);
 	data[i++] =
 	    (unsigned int)ntohl(mgp->fw_stats->dropped_multicast_filtered);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_runt);
Index: linux-git/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge_mcp.h	2007-02-04 19:44:54.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge_mcp.h	2007-05-07 23:20:45.000000000 +0200
@@ -219,7 +219,11 @@
 
 struct mcp_irq_data {
 	/* add new counters at the beginning */
-	__be32 future_use[5];
+	__be32 future_use[1];
+	__be32 dropped_pause;
+	__be32 dropped_unicast_filtered;
+	__be32 dropped_bad_crc32;
+	__be32 dropped_bad_phy;
 	__be32 dropped_multicast_filtered;
 	/* 40 Bytes */
 	__be32 send_done_count;


