From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 14/22] fjes: net_device_ops.ndo_tx_timeout
Date: Thu, 18 Jun 2015 09:49:39 +0900
Message-ID: <1434588587-25655-14-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds net_device_ops.ndo_tx_timeout callback.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 72541a7..84727d8 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -60,6 +60,7 @@ static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64
 *fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 static int fjes_change_mtu(struct net_device *, int);
+static void fjes_tx_retry(struct net_device *);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -228,6 +229,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_start_xmit		= fjes_xmit_frame,
 	.ndo_get_stats64	= fjes_get_stats64,
 	.ndo_change_mtu		= fjes_change_mtu,
+	.ndo_tx_timeout		= fjes_tx_retry,
 };
 
 /*
@@ -739,6 +741,13 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *skb,
 	return ret;
 }
 
+static void fjes_tx_retry(struct net_device *netdev)
+{
+	struct netdev_queue *curQueue = netdev_get_tx_queue(netdev, 0);
+
+	netif_tx_wake_queue(curQueue);
+}
+
 static struct rtnl_link_stats64
 *fjes_get_stats64(struct net_device *netdev,
 		struct rtnl_link_stats64 *stats)
-- 
1.8.3.1

