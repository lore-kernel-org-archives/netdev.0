From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V4 net-next 02/13] net/ena: fix queues number calculation
Date: Thu,  9 Feb 2017 15:21:28 +0200
Message-ID: <1486646499-13682-3-git-send-email-netanel@annapurnalabs.com>
References: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com,
        evgenys@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ENA driver tries to open a queue per vCPU.
To determine how many vCPUs the instance have it uses num_possible_cpus()
while it should have use num_online_cpus() instead.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index d8cd9ca..effe686 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2658,7 +2658,7 @@ static int ena_calc_io_queue_num(struct pci_dev *pdev,
 		io_sq_num = get_feat_ctx->max_queues.max_sq_num;
 	}
 
-	io_queue_num = min_t(int, num_possible_cpus(), ENA_MAX_NUM_IO_QUEUES);
+	io_queue_num = min_t(int, num_online_cpus(), ENA_MAX_NUM_IO_QUEUES);
 	io_queue_num = min_t(int, io_queue_num, io_sq_num);
 	io_queue_num = min_t(int, io_queue_num,
 			     get_feat_ctx->max_queues.max_cq_num);
-- 
2.7.4
