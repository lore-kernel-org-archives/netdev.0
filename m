From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v3 net-next 2/9] sunvnet: remove unused variable in maybe_tx_wakeup
Date: Fri, 10 Feb 2017 09:38:18 -0800
Message-ID: <1486748305-240339-3-git-send-email-shannon.nelson@oracle.com>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23162 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751712AbdBJRpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:45:10 -0500
In-Reply-To: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>

The vio_dring_state *dr variable is unused in maybe_tx_wakeup().
As the comments indicate, we call maybe_tx_wakeup() whenever we
get a STOPPED LDC message on the port. If the queue is stopped,
we want to wake it up so that we will send another START message
at the next TX and trigger the consumer to drain the dring.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index c71f000..0f940f0 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -719,12 +719,8 @@ static void maybe_tx_wakeup(struct vnet_port *port)
 	txq = netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
 				  port->q_index);
 	__netif_tx_lock(txq, smp_processor_id());
-	if (likely(netif_tx_queue_stopped(txq))) {
-		struct vio_dring_state *dr;
-
-		dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+	if (likely(netif_tx_queue_stopped(txq)))
 		netif_tx_wake_queue(txq);
-	}
 	__netif_tx_unlock(txq);
 }
 
-- 
1.7.1
