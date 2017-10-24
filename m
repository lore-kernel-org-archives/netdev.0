From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 2/4] net: hns3: add nic_client check when initialize roce base information
Date: Tue, 24 Oct 2017 21:02:10 +0800
Message-ID: <1508850132-106101-3-git-send-email-lipeng321@huawei.com>
References: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roce driver works base on HNS3 driver.If insmod Roce driver before
NIC driver there is a error because do not check nic_client. This patch
adds nic_client check when initialize roce base information.

Fixes: 46a3df9 (net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 4431241..2c22d3c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -4285,7 +4285,7 @@ static int hclge_init_client_instance(struct hnae3_client *client,
 				vport->roce.client = client;
 			}
 
-			if (hdev->roce_client) {
+			if (hdev->roce_client && hdev->nic_client) {
 				ret = hclge_init_roce_base_info(vport);
 				if (ret)
 					goto err;
-- 
1.9.1
