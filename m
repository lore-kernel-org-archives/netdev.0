From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: cxgb4vf: Staticize local symbols
Date: Tue, 10 Sep 2013 13:22:35 +0530
Message-ID: <1378799555-11872-1-git-send-email-sachin.kamat@linaro.org>
Cc: leedom@chelsio.com, davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:33801 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab3IJIKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 04:10:37 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so7285361pbc.9
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 01:10:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Local symbols used only in this file are made static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index df296af..8475c4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1396,8 +1396,9 @@ static inline void copy_frags(struct sk_buff *skb,
  *	Builds an sk_buff from the given packet gather list.  Returns the
  *	sk_buff or %NULL if sk_buff allocation failed.
  */
-struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
-				  unsigned int skb_len, unsigned int pull_len)
+static struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
+					 unsigned int skb_len,
+					 unsigned int pull_len)
 {
 	struct sk_buff *skb;
 
@@ -1443,7 +1444,7 @@ out:
  *	Releases the pages of a packet gather list.  We do not own the last
  *	page on the list and do not free it.
  */
-void t4vf_pktgl_free(const struct pkt_gl *gl)
+static void t4vf_pktgl_free(const struct pkt_gl *gl)
 {
 	int frag;
 
@@ -1640,7 +1641,7 @@ static inline void rspq_next(struct sge_rspq *rspq)
  *	on this queue.  If the system is under memory shortage use a fairly
  *	long delay to help recovery.
  */
-int process_responses(struct sge_rspq *rspq, int budget)
+static int process_responses(struct sge_rspq *rspq, int budget)
 {
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
 	int budget_left = budget;
@@ -1893,7 +1894,7 @@ static unsigned int process_intrq(struct adapter *adapter)
  * The MSI interrupt handler handles data events from SGE response queues as
  * well as error and other async events as they all use the same MSI vector.
  */
-irqreturn_t t4vf_intr_msi(int irq, void *cookie)
+static irqreturn_t t4vf_intr_msi(int irq, void *cookie)
 {
 	struct adapter *adapter = cookie;
 
-- 
1.7.9.5
