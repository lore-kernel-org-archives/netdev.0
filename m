From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 6/7] net: netcp: allocate buffers to desc before re-enable interrupt
Date: Wed, 23 Sep 2015 13:37:10 -0400
Message-ID: <1443029831-22035-7-git-send-email-m-karicheri2@ti.com>
References: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently netcp_rxpool_refill() that refill descriptors and attached
buffers to fdq while interrupt is enabled as part of NAPI poll. Doing
it while interrupt is disabled could be beneficial as hardware will
not be starved when CPU is busy with processing interrupt.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index d39dce3..8026daa 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -904,12 +904,12 @@ static int netcp_rx_poll(struct napi_struct *napi, int budget)
 
 	packets = netcp_process_rx_packets(netcp, budget);
 
+	netcp_rxpool_refill(netcp);
 	if (packets < budget) {
 		napi_complete(&netcp->rx_napi);
 		knav_queue_enable_notify(netcp->rx_queue);
 	}
 
-	netcp_rxpool_refill(netcp);
 	return packets;
 }
 
-- 
1.9.1
