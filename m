From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Relax alignment on TX harware queue.
Date: Wed, 10 Jun 2009 18:49:33 -0700
Message-ID: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39442 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391AbZFKB5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 21:57:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alignment was on size of queue boundary, but the hardware
only requires 4-byte alignment.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 ++
 drivers/net/qlge/qlge_main.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 5eb52ca..b1ddfd1 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -27,6 +27,8 @@
 			   "%s: " fmt, __func__, ##args);  \
        } while (0)
 
+#define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
+
 #define QLGE_VENDOR_ID    0x1077
 #define QLGE_DEVICE_ID_8012	0x8012
 #define QLGE_DEVICE_ID_8000	0x8000
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 024c734..17d512c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2237,7 +2237,7 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 				 &tx_ring->wq_base_dma);
 
 	if ((tx_ring->wq_base == NULL)
-	    || tx_ring->wq_base_dma & (tx_ring->wq_size - 1)) {
+		|| tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
 		QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
 		return -ENOMEM;
 	}
-- 
1.6.0.2

