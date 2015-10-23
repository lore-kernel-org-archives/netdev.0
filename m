From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: fix RX buffer size calculation
Date: Sat, 24 Oct 2015 00:46:40 +0300
Message-ID: <1571476.HbCo5gVB8j@wasted.cogentembedded.com>
References: <2249923.hKhT9K6gME@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34844 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbJWVqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 17:46:43 -0400
Received: by lfbn126 with SMTP id n126so62994367lfb.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 14:46:42 -0700 (PDT)
In-Reply-To: <2249923.hKhT9K6gME@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RX buffer size calulation failed to account for the length granularity
(which is now 32 bytes)...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1127,7 +1127,7 @@ static void sh_eth_ring_format(struct ne
 	struct sh_eth_txdesc *txdesc = NULL;
 	int rx_ringsize = sizeof(*rxdesc) * mdp->num_rx_ring;
 	int tx_ringsize = sizeof(*txdesc) * mdp->num_tx_ring;
-	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN - 1;
+	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN + 32 - 1;
 	dma_addr_t dma_addr;
 
 	mdp->cur_rx = 0;
@@ -1450,7 +1450,7 @@ static int sh_eth_rx(struct net_device *
 	struct sk_buff *skb;
 	u16 pkt_len = 0;
 	u32 desc_status;
-	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN - 1;
+	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN + 32 - 1;
 	dma_addr_t dma_addr;
 
 	boguscnt = min(boguscnt, *quota);
