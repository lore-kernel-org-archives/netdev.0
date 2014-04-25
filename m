From: Stratos Karafotis <stratosk@semaphore.gr>
Subject: [PATCH v5 7/8] irda: sh_sir: Use cpufreq_for_each_valid_entry macro
 for iteration
Date: Fri, 25 Apr 2014 23:16:49 +0300
Message-ID: <535AC2B1.4020905@semaphore.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpufreq core supports the cpufreq_for_each_valid_entry macro
helper for iteration over the cpufreq_frequency_table, so use it.

It should have no functional changes.

Signed-off-by: Stratos Karafotis <stratosk@semaphore.gr>
---

Please note that I was no able to compile test this patch due to 
lack of cross compiler.

 drivers/net/irda/sh_sir.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index cadf52e..e3fe9a2 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -217,21 +217,17 @@ crc_init_out:
 static u32 sh_sir_find_sclk(struct clk *irda_clk)
 {
 	struct cpufreq_frequency_table *freq_table = irda_clk->freq_table;
+	struct cpufreq_frequency_table *pos;
 	struct clk *pclk = clk_get(NULL, "peripheral_clk");
 	u32 limit, min = 0xffffffff, tmp;
-	int i, index = 0;
+	int index = 0;
 
 	limit = clk_get_rate(pclk);
 	clk_put(pclk);
 
 	/* IrDA can not set over peripheral_clk */
-	for (i = 0;
-	     freq_table[i].frequency != CPUFREQ_TABLE_END;
-	     i++) {
-		u32 freq = freq_table[i].frequency;
-
-		if (freq == CPUFREQ_ENTRY_INVALID)
-			continue;
+	cpufreq_for_each_valid_entry(pos, freq_table) {
+		u32 freq = pos->frequency;
 
 		/* IrDA should not over peripheral_clk */
 		if (freq > limit)
@@ -240,7 +236,7 @@ static u32 sh_sir_find_sclk(struct clk *irda_clk)
 		tmp = freq % SCLK_BASE;
 		if (tmp < min) {
 			min = tmp;
-			index = i;
+			index = pos - freq_table;
 		}
 	}
 
-- 
1.9.0
