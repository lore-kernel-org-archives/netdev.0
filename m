From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/17] sfc: Remove unnecessary casts to struct sk_buff *
Date: Tue, 24 Nov 2009 02:06:47 +0000
Message-ID: <1259028407.14645.31.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34868 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754332AbZKXCGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:06:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At some point these casts were used to remove const qualification, but
they are now unneeded.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 303919a..e11632b 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -173,7 +173,7 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 
 	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 
-	if (skb_shinfo((struct sk_buff *)skb)->gso_size)
+	if (skb_shinfo(skb)->gso_size)
 		return efx_enqueue_skb_tso(tx_queue, skb);
 
 	/* Get size of the initial fragment */
@@ -287,7 +287,7 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 		   skb_shinfo(skb)->nr_frags + 1);
 
 	/* Mark the packet as transmitted, and free the SKB ourselves */
-	dev_kfree_skb_any((struct sk_buff *)skb);
+	dev_kfree_skb_any(skb);
 	goto unwind;
 
  stop:
@@ -1102,7 +1102,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
  mem_err:
 	EFX_ERR(efx, "Out of memory for TSO headers, or PCI mapping error\n");
-	dev_kfree_skb_any((struct sk_buff *)skb);
+	dev_kfree_skb_any(skb);
 	goto unwind;
 
  stop:

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

