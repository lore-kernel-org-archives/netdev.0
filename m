From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 2/9] net: hns3: Refactor mac_init function
Date: Wed, 1 Nov 2017 22:47:15 +0800
Message-ID: <1509547642-51110-3-git-send-email-lipeng321@huawei.com>
References: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: qumingguang <qumingguang@huawei.com>

It needs initialize mdio in initialization process, but reset process
does not reset mdio, so do not initialize mdio in reset process.
This patch move out the mdio configuration function from the mac_init.
So mac_init can be used both in reset process and initialization process.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index a56d878..4ef4592 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2228,13 +2228,6 @@ static int hclge_mac_init(struct hclge_dev *hdev)
 
 	mac->link = 0;
 
-	ret = hclge_mac_mdio_config(hdev);
-	if (ret) {
-		dev_warn(&hdev->pdev->dev,
-			 "mdio config fail ret=%d\n", ret);
-		return ret;
-	}
-
 	/* Initialize the MTA table work mode */
 	hdev->accept_mta_mc	= true;
 	hdev->enable_mta	= true;
@@ -4498,6 +4491,13 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 		return ret;
 	}
 
+	ret = hclge_mac_mdio_config(hdev);
+	if (ret) {
+		dev_warn(&hdev->pdev->dev,
+			 "mdio config fail ret=%d\n", ret);
+		return ret;
+	}
+
 	ret = hclge_mac_init(hdev);
 	if (ret) {
 		dev_err(&pdev->dev, "Mac init error, ret = %d\n", ret);
-- 
1.9.1
