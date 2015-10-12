From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next v2 1/2] hisilicon net: removes the once HANDEL_TX_MSG macro
Date: Mon, 12 Oct 2015 11:23:44 +0800
Message-ID: <1444620225-2339-2-git-send-email-huangdaode@hisilicon.com>
References: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <arnd@arndb.de>, <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the code style to make the code more simple.
also removes the once used HNADEL_TX_MSG macro, according to the
review comments from Joe Perches.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Reviewed-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c | 45 +++++++++++++++----------------
 1 file changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index f52e99a..40f5779 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -439,40 +439,39 @@ EXPORT_SYMBOL(hnae_ae_unregister);
 static ssize_t handles_show(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
-	ssize_t s = 0;
+	char *s = buf;
 	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
 	struct hnae_handle *h;
 	int i = 0, j;
 
 	list_for_each_entry_rcu(h, &hdev->handle_list, node) {
-		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
+		s += sprintf(s, "handle %d (eport_id=%u from %s):\n",
 			    i++, h->eport_id, h->dev->name);
 		for (j = 0; j < h->q_num; j++) {
-			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
+			s += sprintf(s, "\tqueue[%d] on %p\n",
 				     j, h->qs[i]->io_base);
-#define HANDEL_TX_MSG "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n"
-			s += sprintf(buf + s,
-				     HANDEL_TX_MSG,
-				     h->qs[i]->tx_ring.io_base,
-				     h->qs[i]->tx_ring.buf_size,
-				     h->qs[i]->tx_ring.desc_num,
-				     h->qs[i]->tx_ring.max_desc_num_per_pkt,
-				     h->qs[i]->tx_ring.max_raw_data_sz_per_desc,
-				     h->qs[i]->tx_ring.max_pkt_size,
-				 h->qs[i]->tx_ring.stats.sw_err_cnt,
-				 h->qs[i]->tx_ring.stats.io_err_cnt);
-			s += sprintf(buf + s,
-				"\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
-				h->qs[i]->rx_ring.io_base,
-				h->qs[i]->rx_ring.buf_size,
-				h->qs[i]->rx_ring.desc_num,
-				h->qs[i]->rx_ring.stats.sw_err_cnt,
-				h->qs[i]->rx_ring.stats.io_err_cnt,
-				h->qs[i]->rx_ring.stats.seg_pkt_cnt);
+			s += sprintf(s,
+				    "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n",
+				    h->qs[i]->tx_ring.io_base,
+				    h->qs[i]->tx_ring.buf_size,
+				    h->qs[i]->tx_ring.desc_num,
+				    h->qs[i]->tx_ring.max_desc_num_per_pkt,
+				    h->qs[i]->tx_ring.max_raw_data_sz_per_desc,
+				    h->qs[i]->tx_ring.max_pkt_size,
+				    h->qs[i]->tx_ring.stats.sw_err_cnt,
+				    h->qs[i]->tx_ring.stats.io_err_cnt);
+			s += sprintf(s,
+				    "\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
+				    h->qs[i]->rx_ring.io_base,
+				    h->qs[i]->rx_ring.buf_size,
+				    h->qs[i]->rx_ring.desc_num,
+				    h->qs[i]->rx_ring.stats.sw_err_cnt,
+				    h->qs[i]->rx_ring.stats.io_err_cnt,
+				    h->qs[i]->rx_ring.stats.seg_pkt_cnt);
 		}
 	}
 
-	return s;
+	return s - buf;
 }
 
 static DEVICE_ATTR_RO(handles);
-- 
1.9.1
