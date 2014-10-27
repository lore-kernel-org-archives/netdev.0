From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/11] ssb: driver_chip_comon_pmu: Fix probable mask then right shift defect
Date: Sun, 26 Oct 2014 22:25:04 -0700
Message-ID: <e68a49a228d8d2495630b4ef03a1f32b33fce7fe.1414387334.git.joe@perches.com>
References: <cover.1414387334.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1414387334.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Precedence of & and >> is not the same and is not left to right.
shift has higher precedence and should be done after the mask.

Add parentheses around the mask.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/ssb/driver_chipcommon_pmu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driver_chipcommon_pmu.c
index 1173a09..bc71583 100644
--- a/drivers/ssb/driver_chipcommon_pmu.c
+++ b/drivers/ssb/driver_chipcommon_pmu.c
@@ -621,8 +621,8 @@ static u32 ssb_pmu_get_alp_clock_clk0(struct ssb_chipcommon *cc)
 	u32 crystalfreq;
 	const struct pmu0_plltab_entry *e = NULL;
 
-	crystalfreq = chipco_read32(cc, SSB_CHIPCO_PMU_CTL) &
-		      SSB_CHIPCO_PMU_CTL_XTALFREQ >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SHIFT;
+	crystalfreq = (chipco_read32(cc, SSB_CHIPCO_PMU_CTL) &
+		       SSB_CHIPCO_PMU_CTL_XTALFREQ) >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SHIFT;
 	e = pmu0_plltab_find_entry(crystalfreq);
 	BUG_ON(!e);
 	return e->freq * 1000;
-- 
2.1.2
