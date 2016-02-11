From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 2/6] net: thunderx: Use napi_schedule_irqoff()
Date: Thu, 11 Feb 2016 21:50:22 +0530
Message-ID: <1455207626-35488-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

napi_schedule is being called from hard irq context, hence
switch to napi_schedule_irqoff which avoids unneeded call
to local_irq_save and local_irq_restore.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 95db6b7..c6f146c 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -828,7 +828,7 @@ static irqreturn_t nicvf_intr_handler(int irq, void *cq_irq)
 	nicvf_disable_intr(nic, NICVF_INTR_CQ, qidx);
 
 	/* Schedule NAPI */
-	napi_schedule(&cq_poll->napi);
+	napi_schedule_irqoff(&cq_poll->napi);
 
 	/* Clear interrupt */
 	nicvf_clear_intr(nic, NICVF_INTR_CQ, qidx);
-- 
1.7.1
