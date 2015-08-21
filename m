From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 12/22] fjes: net_device_ops.ndo_get_stats64
Date: Fri, 21 Aug 2015 17:29:28 +0900
Message-ID: <1440145778-15941-12-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds net_device_ops.ndo_get_stats64 callback.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 6194962..20feb3e 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -55,6 +55,8 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *, struct net_device *);
 static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static void fjes_tx_stall_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
+static struct rtnl_link_stats64 *
+fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -219,6 +221,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_open		= fjes_open,
 	.ndo_stop		= fjes_close,
 	.ndo_start_xmit		= fjes_xmit_frame,
+	.ndo_get_stats64	= fjes_get_stats64,
 };
 
 /* fjes_open - Called when a network interface is made active */
@@ -700,6 +703,16 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return ret;
 }
 
+static struct rtnl_link_stats64 *
+fjes_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+
+	memcpy(stats, &adapter->stats64, sizeof(struct rtnl_link_stats64));
+
+	return stats;
+}
+
 static irqreturn_t fjes_intr(int irq, void *data)
 {
 	struct fjes_adapter *adapter = data;
-- 
1.8.3.1

