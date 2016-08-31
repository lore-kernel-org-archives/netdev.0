From: Greg Rose <gvrose8192@gmail.com>
Subject: [PATCH] net/ethernet: Use ether_addr_copy rather than memcpy
Date: Wed, 31 Aug 2016 09:32:48 -0700
Message-ID: <1472661168-22396-1-git-send-email-grose@lightfleet.com>
Cc: Greg Rose <grose@lightfleet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32938 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935817AbcHaQcw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:32:52 -0400
Received: by mail-pf0-f196.google.com with SMTP id i6so2993864pfe.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 09:32:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure why this hasn't been done before because it seems obvious,
so maybe there is some reason that memcpy is used instead of
ether_addr_copy in this code.  But let's try this anyway.

Change memcpy to ether_addr_copy.

Signed-off-by: Greg Rose <grose@lightfleet.com>
---
 net/ethernet/eth.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 66dff5e..cbcdb97 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -95,10 +95,10 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 
 	if (!saddr)
 		saddr = dev->dev_addr;
-	memcpy(eth->h_source, saddr, ETH_ALEN);
+	ether_addr_copy(eth->h_source, saddr);
 
 	if (daddr) {
-		memcpy(eth->h_dest, daddr, ETH_ALEN);
+		ether_addr_copy(eth->h_dest, daddr);
 		return ETH_HLEN;
 	}
 
@@ -211,7 +211,7 @@ EXPORT_SYMBOL(eth_type_trans);
 int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
-	memcpy(haddr, eth->h_source, ETH_ALEN);
+	ether_addr_copy(haddr, eth->h_source);
 	return ETH_ALEN;
 }
 EXPORT_SYMBOL(eth_header_parse);
@@ -236,8 +236,8 @@ int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16
 		return -1;
 
 	eth->h_proto = type;
-	memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
-	memcpy(eth->h_dest, neigh->ha, ETH_ALEN);
+	ether_addr_copy(eth->h_source, dev->dev_addr);
+	ether_addr_copy(eth->h_dest, neigh->ha);
 	hh->hh_len = ETH_HLEN;
 	return 0;
 }
@@ -255,8 +255,8 @@ void eth_header_cache_update(struct hh_cache *hh,
 			     const struct net_device *dev,
 			     const unsigned char *haddr)
 {
-	memcpy(((u8 *) hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
-	       haddr, ETH_ALEN);
+	ether_addr_copy(((u8 *)hh->hh_data) +
+			HH_DATA_OFF(sizeof(struct ethhdr)), haddr);
 }
 EXPORT_SYMBOL(eth_header_cache_update);
 
@@ -286,7 +286,7 @@ void eth_commit_mac_addr_change(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	ether_addr_copy(dev->dev_addr, addr->sa_data);
 }
 EXPORT_SYMBOL(eth_commit_mac_addr_change);
 
-- 
1.8.3.1
