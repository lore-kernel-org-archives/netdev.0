From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/62] chelsio: Use static const
Date: Sat, 20 Nov 2010 18:38:11 -0800
Message-ID: <33643252f41c2b54ae8a8bac91e3fd6cbcaa835f.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moved duplicated ch_mac_addr declarations to single static const file scope.

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  21712	    305	   5168	  27185	   6a31	drivers/net/chelsio/sge.o.new
  21806	    305	   5168	  27279	   6a8f	drivers/net/chelsio/sge.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/chelsio/sge.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 70221ca..f778b15 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -273,6 +273,10 @@ struct sge {
 	struct cmdQ cmdQ[SGE_CMDQ_N] ____cacheline_aligned_in_smp;
 };
 
+static const u8 ch_mac_addr[ETH_ALEN] = {
+	0x0, 0x7, 0x43, 0x0, 0x0, 0x0
+};
+
 /*
  * stop tasklet and free all pending skb's
  */
@@ -2012,10 +2016,6 @@ static void espibug_workaround_t204(unsigned long data)
 				continue;
 
 			if (!skb->cb[0]) {
-				u8 ch_mac_addr[ETH_ALEN] = {
-					0x0, 0x7, 0x43, 0x0, 0x0, 0x0
-				};
-
 				skb_copy_to_linear_data_offset(skb,
 						    sizeof(struct cpl_tx_pkt),
 							       ch_mac_addr,
@@ -2048,8 +2048,6 @@ static void espibug_workaround(unsigned long data)
 
 	        if ((seop & 0xfff0fff) == 0xfff && skb) {
 	                if (!skb->cb[0]) {
-	                        u8 ch_mac_addr[ETH_ALEN] =
-	                            {0x0, 0x7, 0x43, 0x0, 0x0, 0x0};
 	                        skb_copy_to_linear_data_offset(skb,
 						     sizeof(struct cpl_tx_pkt),
 							       ch_mac_addr,
-- 
1.7.3.2.245.g03276.dirty
