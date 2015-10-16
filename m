From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next v3 1/2] net: hisilicon rm hnae sysfs interface
Date: Fri, 16 Oct 2015 11:54:16 +0800
Message-ID: <1444967657-107994-2-git-send-email-huangdaode@hisilicon.com>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>,
	<lipeng321@huawei.com>
To: <davem@davemloft.net>, <arnd@arndb.de>, <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the hns driver hnae sysfs interface according to
Arnd's review comments.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c | 47 -------------------------------
 1 file changed, 47 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index f52e99a..9d3bb83 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -436,59 +436,12 @@ void hnae_ae_unregister(struct hnae_ae_dev *hdev)
 }
 EXPORT_SYMBOL(hnae_ae_unregister);
 
-static ssize_t handles_show(struct device *dev,
-			    struct device_attribute *attr, char *buf)
-{
-	ssize_t s = 0;
-	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
-	struct hnae_handle *h;
-	int i = 0, j;
-
-	list_for_each_entry_rcu(h, &hdev->handle_list, node) {
-		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
-			    i++, h->eport_id, h->dev->name);
-		for (j = 0; j < h->q_num; j++) {
-			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
-				     j, h->qs[i]->io_base);
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
-		}
-	}
-
-	return s;
-}
-
-static DEVICE_ATTR_RO(handles);
-static struct attribute *hnae_class_attrs[] = {
-	&dev_attr_handles.attr,
-	NULL,
-};
-ATTRIBUTE_GROUPS(hnae_class);
-
 static int __init hnae_init(void)
 {
 	hnae_class = class_create(THIS_MODULE, "hnae");
 	if (IS_ERR(hnae_class))
 		return PTR_ERR(hnae_class);
 
-	hnae_class->dev_groups = hnae_class_groups;
 	return 0;
 }
 
-- 
1.9.1
