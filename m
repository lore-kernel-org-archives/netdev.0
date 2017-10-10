From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 5/5] net: hns3: fix the ring count for ETHTOOL_GRXRINGS
Date: Tue, 10 Oct 2017 16:42:07 +0800
Message-ID: <1507624927-98008-6-git-send-email-lipeng321@huawei.com>
References: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix the ring count for ETHTOOL_GRXRINGS. Ring count
not TC size should be return for command "ethtool -n ethx".

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index b64fbd3..9b36ce0 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -450,7 +450,7 @@ static int hns3_get_rxnfc(struct net_device *netdev,
 
 	switch (cmd->cmd) {
 	case ETHTOOL_GRXRINGS:
-		cmd->data = h->ae_algo->ops->get_tc_size(h);
+		cmd->data = h->kinfo.num_tc * h->kinfo.rss_size;
 		break;
 	case ETHTOOL_GRXFH:
 		return h->ae_algo->ops->get_rss_tuple(h, cmd);
-- 
1.9.1
