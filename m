From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 12/22] fjes: net_device_ops.ndo_get_stats64
Date: Thu, 18 Jun 2015 09:49:37 +0900
Message-ID: <1434588587-25655-12-git-send-email-izumi.taku@jp.fujitsu.com>
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

This patch adds net_device_ops.ndo_get_stats64 callback.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_main.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 97bf487..eeda824 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -57,6 +57,8 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *,
 static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static void fjes_tx_stall_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
+static struct rtnl_link_stats64
+*fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -223,6 +225,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_open		= fjes_open,
 	.ndo_stop		= fjes_close,
 	.ndo_start_xmit		= fjes_xmit_frame,
+	.ndo_get_stats64	= fjes_get_stats64,
 };
 
 /*
@@ -734,6 +737,17 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *skb,
 	return ret;
 }
 
+static struct rtnl_link_stats64
+*fjes_get_stats64(struct net_device *netdev,
+		struct rtnl_link_stats64 *stats)
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

