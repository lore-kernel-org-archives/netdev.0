From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: hns3: remove a couple of redundant assignments
Date: Wed,  1 Nov 2017 10:17:15 +0000
Message-ID: <20171101101715.17617-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>,
        Yunsheng Lin <linyunsheng@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The assignment to kinfo is redundant as this is a duplicate of
the initialiation of kinfo a few lines earlier, so it can be
removed.  The assignment to v_tc_info is never read, so this
variable is redundant and can be removed completely. Cleans
up two clang warnings:

drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c:433:34:
warning: Value stored to 'kinfo' during its initialization is never read
drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c:775:3:
warning: Value stored to 'v_tc_info' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index 1ae6eae82eb3..7bfa2e5497cb 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -434,7 +434,6 @@ static void hclge_tm_vport_tc_info_update(struct hclge_vport *vport)
 	struct hclge_dev *hdev = vport->back;
 	u8 i;
 
-	kinfo = &vport->nic.kinfo;
 	vport->bw_limit = hdev->tm_info.pg_info[0].bw_limit;
 	kinfo->num_tc =
 		min_t(u16, kinfo->num_tqps, hdev->tm_info.num_tc);
@@ -766,13 +765,11 @@ static int hclge_tm_pri_vnet_base_shaper_qs_cfg(struct hclge_vport *vport)
 {
 	struct hnae3_knic_private_info *kinfo = &vport->nic.kinfo;
 	struct hclge_dev *hdev = vport->back;
-	struct hnae3_tc_info *v_tc_info;
 	u8 ir_u, ir_b, ir_s;
 	u32 i;
 	int ret;
 
 	for (i = 0; i < kinfo->num_tc; i++) {
-		v_tc_info = &kinfo->tc_info[i];
 		ret = hclge_shaper_para_calc(
 					hdev->tm_info.tc_info[i].bw_limit,
 					HCLGE_SHAPER_LVL_QSET,
-- 
2.14.1
