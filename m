From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 14/22] fjes: net_device_ops.ndo_tx_timeout
Date: Fri, 21 Aug 2015 17:29:30 +0900
Message-ID: <1440145778-15941-14-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:58096 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbbHUIfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 04:35:12 -0400
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds net_device_ops.ndo_tx_timeout callback.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 519976c..94ccc11 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -58,6 +58,7 @@ static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64 *
 fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 static int fjes_change_mtu(struct net_device *, int);
+static void fjes_tx_retry(struct net_device *);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -224,6 +225,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_start_xmit		= fjes_xmit_frame,
 	.ndo_get_stats64	= fjes_get_stats64,
 	.ndo_change_mtu		= fjes_change_mtu,
+	.ndo_tx_timeout		= fjes_tx_retry,
 };
 
 /* fjes_open - Called when a network interface is made active */
@@ -705,6 +707,13 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return ret;
 }
 
+static void fjes_tx_retry(struct net_device *netdev)
+{
+	struct netdev_queue *queue = netdev_get_tx_queue(netdev, 0);
+
+	netif_tx_wake_queue(queue);
+}
+
 static struct rtnl_link_stats64 *
 fjes_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
-- 
1.8.3.1
