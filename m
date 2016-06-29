From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 04/10] liquidio: softcommand delay
Date: Tue, 28 Jun 2016 17:54:26 -0700
Message-ID: <1467161672-21063-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752423AbcF2AzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:13 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the delay constant for softcommands in
accrodance with new requirements.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c         | 2 +-
 drivers/net/ethernet/cavium/liquidio/request_manager.c  | 3 ++-
 drivers/net/ethernet/cavium/liquidio/response_manager.c | 5 ++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index eda593a..4528396 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3585,7 +3585,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		sc->callback = if_cfg_callback;
 		sc->callback_arg = sc;
-		sc->wait_time = 1000;
+		sc->wait_time = 3000;
 
 		retval = octeon_send_soft_command(octeon_dev, sc);
 		if (retval == IQ_SEND_FAILED) {
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 3e40cd6..096d2b9 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -534,9 +534,10 @@ static void check_db_timeout(struct work_struct *work)
 	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
 	unsigned long iq_no = wk->ctxul;
 	struct cavium_wq *db_wq = &oct->check_db_wq[iq_no];
+	u32 delay = 10;
 
 	__check_db_timeout(oct, iq_no);
-	queue_delayed_work(db_wq->wq, &db_wq->wk.work, msecs_to_jiffies(1));
+	queue_delayed_work(db_wq->wq, &db_wq->wk.work, msecs_to_jiffies(delay));
 }
 
 int
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index c93210f..b925a30 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -66,7 +66,7 @@ int octeon_setup_response_list(struct octeon_device *oct)
 	INIT_DELAYED_WORK(&cwq->wk.work, oct_poll_req_completion);
 	cwq->wk.ctxptr = oct;
 	oct->cmd_resp_state = OCT_DRV_ONLINE;
-	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
+	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(50));
 
 	return ret;
 }
@@ -176,6 +176,5 @@ static void oct_poll_req_completion(struct work_struct *work)
 	struct cavium_wq *cwq = &oct->dma_comp_wq;
 
 	lio_process_ordered_list(oct, 0);
-
-	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
+	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(50));
 }
-- 
1.8.3.1
