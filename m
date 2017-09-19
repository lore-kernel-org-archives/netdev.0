From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 6/7] net: hns3: set default vlan id to PF
Date: Tue, 19 Sep 2017 02:06:27 +0100
Message-ID: <20170919010628.175732-7-salil.mehta@huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>,
        Mingguang Qu <qumingguang@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6071 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdISBHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 21:07:38 -0400
In-Reply-To: <20170919010628.175732-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lipeng <lipeng321@huawei.com>

When there is no vlan id in the packets, hardware will treat the vlan id
as 0 and look for the mac_vlan table. This patch set the default vlan id
of PF as 0. Without this config, it will fail when look for mac_vlan
table, and hardware will drop packets.

Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 8e172afd4876..74008ef23169 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -3673,6 +3673,7 @@ static int hclge_init_vlan_config(struct hclge_dev *hdev)
 {
 #define HCLGE_VLAN_TYPE_VF_TABLE   0
 #define HCLGE_VLAN_TYPE_PORT_TABLE 1
+	struct hnae3_handle *handle;
 	int ret;
 
 	ret = hclge_set_vlan_filter_ctrl(hdev, HCLGE_VLAN_TYPE_VF_TABLE,
@@ -3682,8 +3683,11 @@ static int hclge_init_vlan_config(struct hclge_dev *hdev)
 
 	ret = hclge_set_vlan_filter_ctrl(hdev, HCLGE_VLAN_TYPE_PORT_TABLE,
 					 true);
+	if (ret)
+		return ret;
 
-	return ret;
+	handle = &hdev->vport[0].nic;
+	return hclge_set_port_vlan_filter(handle, htons(ETH_P_8021Q), 0, false);
 }
 
 static int hclge_set_mtu(struct hnae3_handle *handle, int new_mtu)
-- 
2.11.0
