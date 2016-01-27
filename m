From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH] net: cavium: liquidio: use helpers ns_to_timespec64()
Date: Wed, 27 Jan 2016 17:34:37 +0800
Message-ID: <1453887277-11531-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	<guohanjun@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Kefeng Wang <wangkefeng.wang@huawei.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the driver to use ns_to_timespec64() to keep consistency
with timespec64_to_ns() instead of open coding the same logic.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b895044..8727655 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1526,7 +1526,6 @@ static int liquidio_ptp_gettime(struct ptp_clock_info *ptp,
 				struct timespec64 *ts)
 {
 	u64 ns;
-	u32 remainder;
 	unsigned long flags;
 	struct lio *lio = container_of(ptp, struct lio, ptp_info);
 	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
@@ -1536,8 +1535,7 @@ static int liquidio_ptp_gettime(struct ptp_clock_info *ptp,
 	ns += lio->ptp_adjust;
 	spin_unlock_irqrestore(&lio->ptp_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
-- 
2.6.0.GIT
