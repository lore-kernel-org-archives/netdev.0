From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 3/7] net: hns3: fix the ops check in hns3_get_rxnfc
Date: Mon, 23 Oct 2017 19:51:03 +0800
Message-ID: <1508759467-18397-4-git-send-email-lipeng321@huawei.com>
References: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1# patch: 07d2995 net: hns3: add support for ETHTOOL_GRXFH.
2# patch: 5668abd net: hns3: add support for set_ringparam.

1# patch adds ae_algo->ops->get_rss_tuple to hns3_get_rxnfc
and 2# patch delete ae_algo->ops->get_tc_size
from hns3_get_rxnfc.This patch fix the ops check in hns3_get_rxnfc.

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index 6c469e4..5cd163b 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -717,7 +717,7 @@ static int hns3_get_rxnfc(struct net_device *netdev,
 {
 	struct hnae3_handle *h = hns3_get_handle(netdev);
 
-	if (!h->ae_algo || !h->ae_algo->ops || !h->ae_algo->ops->get_tc_size)
+	if (!h->ae_algo || !h->ae_algo->ops || !h->ae_algo->ops->get_rss_tuple)
 		return -EOPNOTSUPP;
 
 	switch (cmd->cmd) {
-- 
1.9.1
