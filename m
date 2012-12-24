From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2 1/2] cpts: fix build error by removing useless code.
Date: Mon, 24 Dec 2012 08:19:09 +0100
Message-ID: <2cc4445dc92ddadb69b3e2feb9d8de38727ea0d4.1356331925.git.richardcochran@gmail.com>
References: <cover.1356331925.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sergei Shtylyov <sshtylyov@mvista.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <cover.1356331925.git.richardcochran@gmail.com>
In-Reply-To: <cover.1356331925.git.richardcochran@gmail.com>
References: <cover.1356331925.git.richardcochran@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpts driver tries to obtain the input clock frequency by calling the
clock's internal 'recalc' method. Since <plat/clock.h> has been removed,
this code can no longer compile.

However, the driver never makes use of the frequency value, so this patch
fixes the issue by removing the offending code altogether.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c |    1 -
 drivers/net/ethernet/ti/cpts.h |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 5e62c1a..5ab8fb4 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -248,7 +248,6 @@ static void cpts_clk_init(struct cpts *cpts)
 		return;
 	}
 	clk_enable(cpts->refclk);
-	cpts->freq = cpts->refclk->recalc(cpts->refclk);
 }
 
 static void cpts_clk_release(struct cpts *cpts)
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index e1bba3a..fe993cd 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -120,7 +120,6 @@ struct cpts {
 	struct delayed_work overflow_work;
 	int phc_index;
 	struct clk *refclk;
-	unsigned long freq;
 	struct list_head events;
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
-- 
1.7.2.5

