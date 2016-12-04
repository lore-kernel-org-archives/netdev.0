From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 03/20] net/ena: fix queues number calculation
Date: Sun,  4 Dec 2016 15:19:21 +0200
Message-ID: <1480857578-5065-4-git-send-email-netanel@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35851 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbcLDNUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 08:20:15 -0500
Received: by mail-wm0-f45.google.com with SMTP id g23so59333368wme.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 05:20:15 -0800 (PST)
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ENA driver tries to open a queue per vCPU.
To determine how many vCPUs the instance have it uses num_possible_cpus
while it should have use num_online_cpus instead.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 397c9bc..224302c 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2667,7 +2667,7 @@ static int ena_calc_io_queue_num(struct pci_dev *pdev,
 		io_sq_num = get_feat_ctx->max_queues.max_sq_num;
 	}
 
-	io_queue_num = min_t(int, num_possible_cpus(), ENA_MAX_NUM_IO_QUEUES);
+	io_queue_num = min_t(int, num_online_cpus(), ENA_MAX_NUM_IO_QUEUES);
 	io_queue_num = min_t(int, io_queue_num, io_sq_num);
 	io_queue_num = min_t(int, io_queue_num,
 			     get_feat_ctx->max_queues.max_cq_num);
-- 
2.7.4
