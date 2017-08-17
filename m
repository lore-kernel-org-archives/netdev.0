From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: hns3: ensure media_type is unitialized
Date: Thu, 17 Aug 2017 10:01:07 +0100
Message-ID: <20170817090107.14310-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        "David S . Miller" <davem@davemloft.net>,
        lipeng <lipeng321@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Media type is only set if h->ae_algo->ops->get_media_type is called
so there is a possibility that media_type is uninitialized when it is
used a switch statement.  Fix this by initializing media_type to
HNAE3_MEDIA_TYPE_UNKNOWN.

Detected by CoverityScan, CID#1452624("Uninitialized scalar variable")

Fixes: 496d03e960ae ("net: hns3: Add Ethtool support to HNS3 driver")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index 0ad65e47c77e..53cab3ad4cda 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -304,7 +304,7 @@ static int hns3_get_link_ksettings(struct net_device *netdev,
 	struct hnae3_handle *h = priv->ae_handle;
 	u32 supported_caps;
 	u32 advertised_caps;
-	u8 media_type;
+	u8 media_type = HNAE3_MEDIA_TYPE_UNKNOWN;
 	u8 link_stat;
 	u8 auto_neg;
 	u8 duplex;
-- 
2.11.0
