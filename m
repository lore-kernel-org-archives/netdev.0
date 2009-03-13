From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 4/10] cxgb3: prefetch buffer access in GRO mode
Date: Fri, 13 Mar 2009 00:13:59 -0700
Message-ID: <20090313071359.21994.26013.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27584 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872AbZCMHOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:14:06 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Elmininate a cache miss when accessing the CPL header within
the first aggregated buffer.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 90f6f82..a482429 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2029,6 +2029,8 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
 			 fl->buf_size, PCI_DMA_FROMDEVICE);
 
+	prefetch(&qs->lro_frag_tbl);
+
 	rx_frag += nr_frags;
 	rx_frag->page = sd->pg_chunk.page;
 	rx_frag->page_offset = sd->pg_chunk.offset + offset;
@@ -2997,6 +2999,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		     V_NEWTIMER(q->rspq.holdoff_tmr));
 
 	mod_timer(&q->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
+
 	return 0;
 
 err_unlock:

