From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 9/9] net: hns3: hns3:fix a bug about statistic counter in reset process
Date: Wed, 1 Nov 2017 22:47:22 +0800
Message-ID: <1509547642-51110-10-git-send-email-lipeng321@huawei.com>
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

All member of Struct hdev->hw_stats is initialized 0 as hdev is alloced by
devm_kzalloc. But in reset process, hdev will not be alloced again, so need
clear hdev->hw_stats in reset process, otherwise the statistic will be
wrong after reset. This patch set all of the statistic counters to zero
after reset.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 141c758..dff9cbd 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -4838,6 +4838,11 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 	return ret;
 }
 
+static void hclge_stats_clear(struct hclge_dev *hdev)
+{
+	memset(&hdev->hw_stats, 0, sizeof(hdev->hw_stats));
+}
+
 static int hclge_reset_ae_dev(struct hnae3_ae_dev *ae_dev)
 {
 	struct hclge_dev *hdev = ae_dev->priv;
@@ -4846,6 +4851,8 @@ static int hclge_reset_ae_dev(struct hnae3_ae_dev *ae_dev)
 
 	set_bit(HCLGE_STATE_DOWN, &hdev->state);
 
+	hclge_stats_clear(hdev);
+
 	ret = hclge_cmd_init(hdev);
 	if (ret) {
 		dev_err(&pdev->dev, "Cmd queue init failed\n");
-- 
1.9.1
