From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v4 08/13] net: ethernet: ti: cpts: drop excessive writes to CTRL and INT_EN regs
Date: Mon, 5 Dec 2016 14:05:20 -0600
Message-ID: <20161205200525.16664-9-grygorii.strashko@ti.com>
References: <20161205200525.16664-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205200525.16664-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CPTS module and IRQs are always enabled when CPTS is registered,
before starting overflow check work, and disabled during
deregistration, when overflow check work has been canceled already.
So, It doesn't require to (re)enable CPTS module and IRQs in
cpts_overflow_check().

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 7ab1fa7..fe1bb7f 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -243,8 +243,6 @@ static void cpts_overflow_check(struct work_struct *work)
 	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
 
-	cpts_write32(cpts, CPTS_EN, control);
-	cpts_write32(cpts, TS_PEND_EN, int_enable);
 	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
-- 
2.10.1
