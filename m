From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 4/4] net: hns3: fix the bug when reuse command description in hclge_add_mac_vlan_tbl
Date: Tue, 24 Oct 2017 21:02:12 +0800
Message-ID: <1508850132-106101-5-git-send-email-lipeng321@huawei.com>
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

When reusing a command description read from HW, driver should set
IN_VLD bit, WR bit and NO_INTR bit. If IN_VLD bit and NO_INTR bit
are not set, the command fails and driver prints error message:

[  135.261284] hns3 0000:7d:00.0: cmdq execute failed for get_mac_vlan_cmd_status,status=2.
[  135.270983] hns3 0000:7d:00.0: add mac addr failed for cmd_send, ret =-5.

This patch fixes the bug.
Fixes: 46a3df9 (net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index d11a9a5..0b95fbe 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -3600,11 +3600,11 @@ static int hclge_add_mac_vlan_tbl(struct hclge_vport *vport,
 							   resp_code,
 							   HCLGE_MAC_VLAN_ADD);
 	} else {
-		mc_desc[0].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+		hclge_cmd_reuse_desc(&mc_desc[0], false);
 		mc_desc[0].flag |= cpu_to_le16(HCLGE_CMD_FLAG_NEXT);
-		mc_desc[1].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+		hclge_cmd_reuse_desc(&mc_desc[1], false);
 		mc_desc[1].flag |= cpu_to_le16(HCLGE_CMD_FLAG_NEXT);
-		mc_desc[2].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+		hclge_cmd_reuse_desc(&mc_desc[2], false);
 		mc_desc[2].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_NEXT);
 		memcpy(mc_desc[0].data, req,
 		       sizeof(struct hclge_mac_vlan_tbl_entry_cmd));
-- 
1.9.1
