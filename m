From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 16/20] net/ena: use napi_schedule_irqoff when possible
Date: Sun,  4 Dec 2016 15:19:34 +0200
Message-ID: <1480857578-5065-17-git-send-email-netanel@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 8c1e14b..6c49529 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1210,7 +1210,7 @@ static irqreturn_t ena_intr_msix_io(int irq, void *data)
 	struct ena_napi *ena_napi = data;
 
 	atomic_set(&ena_napi->unmask_interrupt, 1);
-	napi_schedule(&ena_napi->napi);
+	napi_schedule_irqoff(&ena_napi->napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.7.4
