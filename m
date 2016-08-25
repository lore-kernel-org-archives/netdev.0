From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: hns: dereference ppe_cb->ppe_common_cb if it is non-null
Date: Thu, 25 Aug 2016 07:51:10 +0100
Message-ID: <20160825065110.10104-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>,
        Lisheng <lisheng011@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

ppe_cb->ppe_common_cb is being dereferenced before a null check is
being made on it.  If ppe_cb->ppe_common_cb is null then we end up
with a null pointer dereference when assigning dsaf_dev.  Fix this
by moving the initialisation of dsaf_dev once we know
ppe_cb->ppe_common_cb is OK to dereference.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index ff8b6a4..6ea8722 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -328,9 +328,10 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 static void hns_ppe_uninit_hw(struct hns_ppe_cb *ppe_cb)
 {
 	u32 port;
-	struct dsaf_device *dsaf_dev = ppe_cb->ppe_common_cb->dsaf_dev;
 
 	if (ppe_cb->ppe_common_cb) {
+		struct dsaf_device *dsaf_dev = ppe_cb->ppe_common_cb->dsaf_dev;
+
 		port = ppe_cb->index;
 		dsaf_dev->misc_op->ppe_srst(dsaf_dev, port, 0);
 	}
-- 
2.9.3
