From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 21/26] ixgb: recalculate after how many descriptors to wake the queue
Date: Tue, 29 Aug 2006 09:45:01 -0700
Message-ID: <20060829164501.6872.36314.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:55562 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965094AbWH2Qgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:48 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Recalculate when to wake the queue using DESC_NEEDED instead of a
static hardcoded number.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    3 ---
 drivers/net/ixgb/ixgb_main.c |    2 +-
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 82b67af..a4bee8c 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -110,9 +110,6 @@ struct ixgb_adapter;
 #define IXGB_RXBUFFER_8192  8192
 #define IXGB_RXBUFFER_16384 16384
 
-/* How many Tx Descriptors do we need to call netif_wake_queue? */
-#define IXGB_TX_QUEUE_WAKE 16
-
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGB_RX_BUFFER_WRITE	4	/* Must be power of 2 */
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index fee4c5a..960b44b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1787,7 +1787,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 	if (unlikely(netif_queue_stopped(netdev))) {
 		spin_lock(&adapter->tx_lock);
 		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
-		    (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE))
+		    (IXGB_DESC_UNUSED(tx_ring) >= DESC_NEEDED))
 			netif_wake_queue(netdev);
 		spin_unlock(&adapter->tx_lock);
 	}



---
Auke Kok <auke-jan.h.kok@intel.com>
