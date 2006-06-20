From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Make illegal_highdma more anal
Date: Wed, 21 Jun 2006 09:49:38 +1000
Message-ID: <20060620234938.GC30522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5644 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750781AbWFTXtk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 19:49:40 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This patch should prevent mistakes like the one I made earlier.

[NET]: Make illegal_highdma more anal

Rather than having illegal_highdma as a macro when HIGHMEM is off, we
can turn it into an inline function that returns zero.  This will catch
callers that give it bad arguments.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/dev.c b/net/core/dev.c
index 9c68ab8..134d9d1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1234,7 +1234,6 @@ void netdev_rx_csum_fault(struct net_dev
 EXPORT_SYMBOL(netdev_rx_csum_fault);
 #endif
 
-#ifdef CONFIG_HIGHMEM
 /* Actually, we should eliminate this check as soon as we know, that:
  * 1. IOMMU is present and allows to map all the memory.
  * 2. No high memory really exists on this machine.
@@ -1242,6 +1241,7 @@ #ifdef CONFIG_HIGHMEM
 
 static inline int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
+#ifdef CONFIG_HIGHMEM
 	int i;
 
 	if (dev->features & NETIF_F_HIGHDMA)
@@ -1251,11 +1251,9 @@ static inline int illegal_highdma(struct
 		if (PageHighMem(skb_shinfo(skb)->frags[i].page))
 			return 1;
 
+#endif
 	return 0;
 }
-#else
-#define illegal_highdma(dev, skb)	(0)
-#endif
 
 struct dev_gso_cb {
 	void (*destructor)(struct sk_buff *skb);
