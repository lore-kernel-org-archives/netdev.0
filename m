From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: nhs: fix 32-bit build warning
Date: Tue, 06 Oct 2015 23:53:57 +0200
Message-ID: <8581924.9CPedieySC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, huangdaode <huangdaode@hisilicon.com>,
	Kenneth Lee <liguozhu@huawei.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:49269 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbbJFVyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:54:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recently added hns driver causes a build warning in ARM
allmodconfig builds:

drivers/net/ethernet/hisilicon/hns/hnae.c: In function 'handles_show':
drivers/net/ethernet/hisilicon/hns/hnae.c:452:13: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
          j, (u64)h->qs[i]->io_base);
             ^

This removes the pointless cast and prints the pointer address using
the "%p" format string in all three locations.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index 0a0a9e80dcd7..f52e99acf463 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -448,12 +448,12 @@ static ssize_t handles_show(struct device *dev,
 		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
 			    i++, h->eport_id, h->dev->name);
 		for (j = 0; j < h->q_num; j++) {
-			s += sprintf(buf + s, "\tqueue[%d] on 0x%llx\n",
-				     j, (u64)h->qs[i]->io_base);
-#define HANDEL_TX_MSG "\t\ttx_ring on 0x%llx:%u,%u,%u,%u,%u,%llu,%llu\n"
+			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
+				     j, h->qs[i]->io_base);
+#define HANDEL_TX_MSG "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n"
 			s += sprintf(buf + s,
 				     HANDEL_TX_MSG,
-				     (u64)h->qs[i]->tx_ring.io_base,
+				     h->qs[i]->tx_ring.io_base,
 				     h->qs[i]->tx_ring.buf_size,
 				     h->qs[i]->tx_ring.desc_num,
 				     h->qs[i]->tx_ring.max_desc_num_per_pkt,
@@ -462,8 +462,8 @@ static ssize_t handles_show(struct device *dev,
 				 h->qs[i]->tx_ring.stats.sw_err_cnt,
 				 h->qs[i]->tx_ring.stats.io_err_cnt);
 			s += sprintf(buf + s,
-				"\t\trx_ring on 0x%llx:%u,%u,%llu,%llu,%llu\n",
-				(u64)h->qs[i]->rx_ring.io_base,
+				"\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
+				h->qs[i]->rx_ring.io_base,
 				h->qs[i]->rx_ring.buf_size,
 				h->qs[i]->rx_ring.desc_num,
 				h->qs[i]->rx_ring.stats.sw_err_cnt,
