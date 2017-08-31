From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 4/8] net: hns3: set default vlan id to PF
Date: Thu, 31 Aug 2017 21:39:05 +0800
Message-ID: <1504186749-8926-5-git-send-email-lipeng321@huawei.com>
References: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When there is no vlan id in the packets, hardware will treat the vlan id
as 0 and look for the mac_vlan table. This patch set the default vlan id
of PF as 0.

Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 5d49856..7374053 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -3698,6 +3698,7 @@ static int hclge_init_vlan_config(struct hclge_dev *hdev)
 {
 #define HCLGE_VLAN_TYPE_VF_TABLE   0
 #define HCLGE_VLAN_TYPE_PORT_TABLE 1
+	struct hnae3_handle *handle;
 	int ret;
 
 	ret = hclge_set_vlan_filter_ctrl(hdev, HCLGE_VLAN_TYPE_VF_TABLE,
@@ -3707,6 +3708,8 @@ static int hclge_init_vlan_config(struct hclge_dev *hdev)
 
 	ret = hclge_set_vlan_filter_ctrl(hdev, HCLGE_VLAN_TYPE_PORT_TABLE,
 					 true);
+	handle = &hdev->vport[0].nic;
+	ret = hclge_set_port_vlan_filter(handle, htons(ETH_P_8021Q), 0, false);
 
 	return ret;
 }
-- 
1.9.1
