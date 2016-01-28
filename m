From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH] ptp: ixp46x: use helpers for converting ns to timespec
Date: Thu, 28 Jan 2016 10:27:19 +0800
Message-ID: <1453948039-3198-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Cochran <richardcochran@gmail.com>, <guohanjun@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Kefeng Wang <wangkefeng.wang@huawei.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the driver to use ns_to_timespec64() and timespec64_to_ns()
instead of open coding the same logic.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/ptp/ptp_ixp46x.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 934c139..ee4f183 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -178,7 +178,6 @@ static int ptp_ixp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 static int ptp_ixp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
-	u32 remainder;
 	unsigned long flags;
 	struct ixp_clock *ixp_clock = container_of(ptp, struct ixp_clock, caps);
 	struct ixp46x_ts_regs *regs = ixp_clock->regs;
@@ -189,8 +188,7 @@ static int ptp_ixp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 
 	spin_unlock_irqrestore(&register_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 	return 0;
 }
 
@@ -202,8 +200,7 @@ static int ptp_ixp_settime(struct ptp_clock_info *ptp,
 	struct ixp_clock *ixp_clock = container_of(ptp, struct ixp_clock, caps);
 	struct ixp46x_ts_regs *regs = ixp_clock->regs;
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
+	ns = timespec64_to_ns(ts);
 
 	spin_lock_irqsave(&register_lock, flags);
 
-- 
2.6.0.GIT
