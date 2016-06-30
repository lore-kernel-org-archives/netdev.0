From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 6/9] net: hns: normalize two different loop
Date: Thu, 30 Jun 2016 15:25:06 +0800
Message-ID: <1467271509-63162-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

There are two approaches to assign data, one does 2 loops, another
does 1 loop. This patch normalize the different methods to 1 loop.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index e36ee22..86ce28a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2567,15 +2567,15 @@ static char *hns_dsaf_get_node_stats_strings(char *data, int node,
 	buff += ETH_GSTRING_LEN;
 	if (node < DSAF_SERVICE_NW_NUM && !is_ver1) {
 		for (i = 0; i < DSAF_PRIO_NR; i++) {
-			snprintf(buff, ETH_GSTRING_LEN,
-				 "inod%d_pfc_prio%d_pkts", node, i);
-			buff += ETH_GSTRING_LEN;
-		}
-		for (i = 0; i < DSAF_PRIO_NR; i++) {
-			snprintf(buff, ETH_GSTRING_LEN,
-				 "onod%d_pfc_prio%d_pkts", node, i);
+			snprintf(buff + 0 * ETH_GSTRING_LEN * DSAF_PRIO_NR,
+				 ETH_GSTRING_LEN, "inod%d_pfc_prio%d_pkts",
+				 node, i);
+			snprintf(buff + 1 * ETH_GSTRING_LEN * DSAF_PRIO_NR,
+				 ETH_GSTRING_LEN, "onod%d_pfc_prio%d_pkts",
+				 node, i);
 			buff += ETH_GSTRING_LEN;
 		}
+		buff += 1 * DSAF_PRIO_NR * ETH_GSTRING_LEN;
 	}
 	snprintf(buff, ETH_GSTRING_LEN, "onnod%d_tx_pkts", node);
 	buff += ETH_GSTRING_LEN;
@@ -2606,8 +2606,8 @@ static u64 *hns_dsaf_get_node_stats(struct dsaf_device *ddev, u64 *data,
 	p[12] = hw_stats->stp_drop;
 	if (node_num < DSAF_SERVICE_NW_NUM && !is_ver1) {
 		for (i = 0; i < DSAF_PRIO_NR; i++) {
-			p[13 + i] = hw_stats->rx_pfc[i];
-			p[13 + i + DSAF_PRIO_NR] = hw_stats->tx_pfc[i];
+			p[13 + i + 0 * DSAF_PRIO_NR] = hw_stats->rx_pfc[i];
+			p[13 + i + 1 * DSAF_PRIO_NR] = hw_stats->tx_pfc[i];
 		}
 		p[29] = hw_stats->tx_pkts;
 		return &p[30];
-- 
1.9.1
