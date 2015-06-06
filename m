From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] ssb: fix handling of ssb_pmu_get_alp_clock()
Date: Sun,  7 Jun 2015 01:52:51 +0200
Message-ID: <1433634771-23438-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: m@bues.ch, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:37205 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbbFFXw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2015 19:52:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter reported missing brackets which resulted in reading a
wrong crystalfreq value. I also noticed that the result of this
function is ignored.

Reported-By: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/ssb/driver_chipcommon_pmu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driver_chipcommon_pmu.c
index 0942841..c5352ea 100644
--- a/drivers/ssb/driver_chipcommon_pmu.c
+++ b/drivers/ssb/driver_chipcommon_pmu.c
@@ -621,8 +621,8 @@ static u32 ssb_pmu_get_alp_clock_clk0(struct ssb_chipcommon *cc)
 	u32 crystalfreq;
 	const struct pmu0_plltab_entry *e = NULL;
 
-	crystalfreq = chipco_read32(cc, SSB_CHIPCO_PMU_CTL) &
-		      SSB_CHIPCO_PMU_CTL_XTALFREQ >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SHIFT;
+	crystalfreq = (chipco_read32(cc, SSB_CHIPCO_PMU_CTL) &
+		       SSB_CHIPCO_PMU_CTL_XTALFREQ)  >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SHIFT;
 	e = pmu0_plltab_find_entry(crystalfreq);
 	BUG_ON(!e);
 	return e->freq * 1000;
@@ -634,7 +634,7 @@ u32 ssb_pmu_get_alp_clock(struct ssb_chipcommon *cc)
 
 	switch (bus->chip_id) {
 	case 0x5354:
-		ssb_pmu_get_alp_clock_clk0(cc);
+		return ssb_pmu_get_alp_clock_clk0(cc);
 	default:
 		ssb_err("ERROR: PMU alp clock unknown for device %04X\n",
 			bus->chip_id);
-- 
2.1.4
