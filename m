From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 10/14] Spidernet RX Chain tail
Date: Wed, 13 Dec 2006 15:20:59 -0600
Message-ID: <20061213212059.GJ1915@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Christoph Hellwig <hch@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:48969 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbWLMVWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:22:16 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLMGSO011405
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:22:16 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLL1jh458018
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:21:01 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLKxZB019606
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:21:01 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Tell the hardware the location of the rx ring tail.
More punctuation cleanup.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:28:15.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:28:19.000000000 -0600
@@ -487,10 +487,10 @@ spider_net_refill_rx_chain(struct spider
 }
 
 /**
- * spider_net_alloc_rx_skbs - allocates rx skbs in rx descriptor chains
+ * spider_net_alloc_rx_skbs - Allocates rx skbs in rx descriptor chains
  * @card: card structure
  *
- * returns 0 on success, <0 on failure
+ * Returns 0 on success, <0 on failure.
  */
 static int
 spider_net_alloc_rx_skbs(struct spider_net_card *card)
@@ -501,17 +501,18 @@ spider_net_alloc_rx_skbs(struct spider_n
 	result = -ENOMEM;
 
 	chain = &card->rx_chain;
-	/* put at least one buffer into the chain. if this fails,
-	 * we've got a problem. if not, spider_net_refill_rx_chain
-	 * will do the rest at the end of this function */
+	/* Put at least one buffer into the chain. if this fails,
+	 * we've got a problem. If not, spider_net_refill_rx_chain
+	 * will do the rest at the end of this function. */
 	if (spider_net_prepare_rx_descr(card, chain->head))
 		goto error;
 	else
 		chain->head = chain->head->next;
 
-	/* this will allocate the rest of the rx buffers; if not, it's
-	 * business as usual later on */
+	/* This will allocate the rest of the rx buffers;
+	 * if not, it's business as usual later on. */
 	spider_net_refill_rx_chain(card);
+	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
 	return 0;
 
