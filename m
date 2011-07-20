From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH 3/3] wireless: mwifiex: print hw address via %pM
Date: Wed, 20 Jul 2011 16:34:31 +0300
Message-ID: <8f12d3ad71585e863084560b227534a4b9e4af54.1311162926.git.andriy.shevchenko@linux.intel.com>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
In-Reply-To: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/mwifiex/debugfs.c |   33 +++++++------------------------
 1 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/debugfs.c b/drivers/net/wireless/mwifiex/debugfs.c
index 1bcf9ea..d26a78b 100644
--- a/drivers/net/wireless/mwifiex/debugfs.c
+++ b/drivers/net/wireless/mwifiex/debugfs.c
@@ -216,28 +216,19 @@ mwifiex_info_read(struct file *file, char __user *ubuf,
 	p += sprintf(p, "bss_mode=\"%s\"\n", bss_modes[info.bss_mode]);
 	p += sprintf(p, "media_state=\"%s\"\n",
 		     (!priv->media_connected ? "Disconnected" : "Connected"));
-	p += sprintf(p, "mac_address=\"%02x:%02x:%02x:%02x:%02x:%02x\"\n",
-		     netdev->dev_addr[0], netdev->dev_addr[1],
-		     netdev->dev_addr[2], netdev->dev_addr[3],
-		     netdev->dev_addr[4], netdev->dev_addr[5]);
+	p += sprintf(p, "mac_address=\"%pM\"\n", netdev->dev_addr);
 
 	if (GET_BSS_ROLE(priv) == MWIFIEX_BSS_ROLE_STA) {
 		p += sprintf(p, "multicast_count=\"%d\"\n",
 			     netdev_mc_count(netdev));
 		p += sprintf(p, "essid=\"%s\"\n", info.ssid.ssid);
-		p += sprintf(p, "bssid=\"%02x:%02x:%02x:%02x:%02x:%02x\"\n",
-			     info.bssid[0], info.bssid[1],
-			     info.bssid[2], info.bssid[3],
-			     info.bssid[4], info.bssid[5]);
+		p += sprintf(p, "bssid=\"%pM\"\n", info.bssid);
 		p += sprintf(p, "channel=\"%d\"\n", (int) info.bss_chan);
 		p += sprintf(p, "region_code = \"%02x\"\n", info.region_code);
 
 		netdev_for_each_mc_addr(ha, netdev)
-			p += sprintf(p, "multicast_address[%d]="
-				     "\"%02x:%02x:%02x:%02x:%02x:%02x\"\n", i++,
-				     ha->addr[0], ha->addr[1],
-				     ha->addr[2], ha->addr[3],
-				     ha->addr[4], ha->addr[5]);
+			p += sprintf(p, "multicast_address[%d]=\"%pM\"\n",
+					i++, ha->addr);
 	}
 
 	p += sprintf(p, "num_tx_bytes = %lu\n", priv->stats.tx_bytes);
@@ -451,26 +442,18 @@ mwifiex_debug_read(struct file *file, char __user *ubuf,
 	if (info.tx_tbl_num) {
 		p += sprintf(p, "Tx BA stream table:\n");
 		for (i = 0; i < info.tx_tbl_num; i++)
-			p += sprintf(p, "tid = %d, "
-				     "ra = %02x:%02x:%02x:%02x:%02x:%02x\n",
-				     info.tx_tbl[i].tid, info.tx_tbl[i].ra[0],
-				     info.tx_tbl[i].ra[1], info.tx_tbl[i].ra[2],
-				     info.tx_tbl[i].ra[3], info.tx_tbl[i].ra[4],
-				     info.tx_tbl[i].ra[5]);
+			p += sprintf(p, "tid = %d, ra = %pM\n",
+				     info.tx_tbl[i].tid, info.tx_tbl[i].ra);
 	}
 
 	if (info.rx_tbl_num) {
 		p += sprintf(p, "Rx reorder table:\n");
 		for (i = 0; i < info.rx_tbl_num; i++) {
