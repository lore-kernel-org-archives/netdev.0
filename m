From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 2/10] ps3: some minor cleanups
Date: Fri, 20 Jul 2007 17:22:51 +0900
Message-ID: <20070720172122.678A.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:44290 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753878AbXGTIWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:22:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Removed the embarrassing definition which was used in only one
  place. 
- Fixed wrong initialization of dmac_cmd_status.


Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    5 +++--
 drivers/net/ps3_gelic_net.h |    1 -
 2 files changed, 3 insertions(+), 3 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -290,7 +290,8 @@ static void gelic_net_release_rx_chain(s
 			descr->buf_addr = 0;
 			dev_kfree_skb_any(descr->skb);
 			descr->skb = NULL;
-			descr->dmac_cmd_status = GELIC_NET_DESCR_NOT_IN_USE;
+			gelic_net_set_descr_status(descr,
+						   GELIC_NET_DESCR_NOT_IN_USE);
 		}
 		descr = descr->next;
 	} while (descr != card->rx_chain.head);
@@ -374,7 +375,7 @@ static void gelic_net_release_tx_descr(s
 	descr->skb = NULL;
 
 	/* set descr status */
-	descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE;
+	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
 }
 
 /**
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -133,7 +133,6 @@ enum gelic_net_int1_status {
 						      * interrupt status */
 
 #define GELIC_NET_DMAC_CMDSTAT_CHAIN_END  0x00000002 /* RXDCEIS:DMA stopped */
-#define GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE 0xb0000000
 #define GELIC_NET_DESCR_IND_PROC_SHIFT    28
 #define GELIC_NET_DESCR_IND_PROC_MASKO    0x0fffffff
 

--
Masakazu MOKUNO

