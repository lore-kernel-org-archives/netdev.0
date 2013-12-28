From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] arp:  make arp_invalidate static
Date: Sat, 28 Dec 2013 11:07:18 -0800
Message-ID: <20131228110718.256a8711@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:62945 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab3L1THW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 14:07:22 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so10350653pab.14
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 11:07:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't export arp_invalidate, only used in arp.c

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 include/net/arp.h |    1 -
 net/ipv4/arp.c    |    3 +--
 2 files changed, 1 insertion(+), 3 deletions(-)

--- a/include/net/arp.h	2013-12-24 15:15:26.817740541 -0800
+++ b/include/net/arp.h	2013-12-24 15:15:59.561300476 -0800
@@ -62,6 +62,5 @@ struct sk_buff *arp_create(int type, int
 			   const unsigned char *src_hw,
 			   const unsigned char *target_hw);
 void arp_xmit(struct sk_buff *skb);
-int arp_invalidate(struct net_device *dev, __be32 ip);
 
 #endif	/* _ARP_H */
--- a/net/ipv4/arp.c	2013-12-24 15:15:26.817740541 -0800
+++ b/net/ipv4/arp.c	2013-12-24 15:15:59.561300476 -0800
@@ -1112,7 +1112,7 @@ static int arp_req_get(struct arpreq *r,
 	return err;
 }
 
-int arp_invalidate(struct net_device *dev, __be32 ip)
+static int arp_invalidate(struct net_device *dev, __be32 ip)
 {
 	struct neighbour *neigh = neigh_lookup(&arp_tbl, &ip, dev);
 	int err = -ENXIO;
@@ -1127,7 +1127,6 @@ int arp_invalidate(struct net_device *de
 
 	return err;
 }
-EXPORT_SYMBOL(arp_invalidate);
 
 static int arp_req_delete_public(struct net *net, struct arpreq *r,
 		struct net_device *dev)
