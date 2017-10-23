From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 4/7] net: hns3: get vf count by pci_sriov_get_totalvfs
Date: Mon, 23 Oct 2017 19:51:04 +0800
Message-ID: <1508759467-18397-5-git-send-email-lipeng321@huawei.com>
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

This patch gets vf count by standard function pci_sriov_get_totalvfs,
instead of info from NIC HW.

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 8508521..4431241 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -837,7 +837,6 @@ static int hclge_parse_func_status(struct hclge_dev *hdev,
 	else
 		hdev->flag &= ~HCLGE_FLAG_MAIN;
 
-	hdev->num_req_vfs = status->vf_num / status->pf_num;
 	return 0;
 }
 
@@ -4361,6 +4360,8 @@ static int hclge_pci_init(struct hclge_dev *hdev)
 		goto err_clr_master;
 	}
 
+	hdev->num_req_vfs = pci_sriov_get_totalvfs(pdev);
+
 	return 0;
 err_clr_master:
 	pci_clear_master(pdev);
-- 
1.9.1
