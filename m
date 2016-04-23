From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 02/13] net: hns: set debug port irq index to 0
Date: Sat, 23 Apr 2016 17:05:06 +0800
Message-ID: <1461402317-136499-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, salil.mehta@huawei.com, yankejian@huawei.com,
 xieqianqian@huawei.com, pawel.moll@arm.com, ijc+devicetree@hellion.org.uk,
 catalin.marinas@arm.com, lipeng321@huawei.com, will.deacon@arm.com,
 linuxarm@huawei.com, xuwei5@hisilicon.com, robh+dt@kernel.org,
 huangdaode@hisilicon.com, galak@codeaurora.org, liguozhu@huawei.com,
 davem@davemloft.net
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

As debug ports are moved from service dsaf to debug dsaf,
the interrupts offset should start from 0, So this patch
re-defines the offset index of debug ports.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 8 +-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h | 5 +----
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 121ba4e..054f391 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -445,20 +445,14 @@ static int hns_rcb_get_port_in_comm(
 
 #define SERVICE_RING_IRQ_IDX(v1) \
 	((v1) ? HNS_SERVICE_RING_IRQ_IDX : HNSV2_SERVICE_RING_IRQ_IDX)
-#define DEBUG_RING_IRQ_IDX(v1) \
-	((v1) ? HNS_DEBUG_RING_IRQ_IDX : HNSV2_DEBUG_RING_IRQ_IDX)
-#define DEBUG_RING_IRQ_OFFSET(v1) \
-	((v1) ? HNS_DEBUG_RING_IRQ_OFFSET : HNSV2_DEBUG_RING_IRQ_OFFSET)
 static int hns_rcb_get_base_irq_idx(struct rcb_common_cb *rcb_common)
 {
-	int comm_index = rcb_common->comm_index;
 	bool is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
 
 	if (!HNS_DSAF_IS_DEBUG(rcb_common->dsaf_dev))
 		return SERVICE_RING_IRQ_IDX(is_ver1);
 	else
-		return  DEBUG_RING_IRQ_IDX(is_ver1) +
-			(comm_index - 1) * DEBUG_RING_IRQ_OFFSET(is_ver1);
+		return  HNS_DEBUG_RING_IRQ_IDX;
 }
 
 #define RCB_COMM_BASE_TO_RING_BASE(base, ringid)\
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index cffd244..8782608 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -10,12 +10,9 @@
 #ifndef _DSAF_REG_H_
 #define _DSAF_REG_H_
 
-#define HNS_DEBUG_RING_IRQ_IDX 55
+#define HNS_DEBUG_RING_IRQ_IDX 0
 #define HNS_SERVICE_RING_IRQ_IDX 59
-#define HNS_DEBUG_RING_IRQ_OFFSET 2
-#define HNSV2_DEBUG_RING_IRQ_IDX 409
 #define HNSV2_SERVICE_RING_IRQ_IDX 25
-#define HNSV2_DEBUG_RING_IRQ_OFFSET 9
 
 #define DSAF_MAX_PORT_NUM_PER_CHIP 8
 #define DSAF_SERVICE_PORT_NUM_PER_DSAF 6
-- 
1.9.1
