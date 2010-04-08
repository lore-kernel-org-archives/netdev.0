From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Fix IGMP3 report parsing
Date: Thu, 8 Apr 2010 09:26:34 +0800
Message-ID: <20100408012634.GC18649@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Banyeer <banyeer@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52774 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752954Ab0DHB0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 21:26:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Fix IGMP3 report parsing

The IGMP3 report parsing is looking at the wrong address for
group records.  This patch fixes it.

Reported-by: Banyeer <banyeer@yahoo.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6980625..5f0acfd 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -719,11 +719,11 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 	len = sizeof(*ih);
 
 	for (i = 0; i < num; i++) {
+		grec = (void *)(skb->data + len);
 		len += sizeof(*grec);
 		if (!pskb_may_pull(skb, len))
 			return -EINVAL;
 
-		grec = (void *)(skb->data + len);
 		group = grec->grec_mca;
 		type = grec->grec_type;
 

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
