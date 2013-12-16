From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/10]  arp: make arp_invalidate static
Date: Mon, 16 Dec 2013 10:37:18 -0800
Message-ID: <20131216103718.52ccaa47@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:52195 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443Ab3LPTkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:21 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so5872699pbb.16
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:21 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't export arp_invalidate, only used in arp.c

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/arp.h	2013-12-12 11:48:17.269851915 -0800
+++ b/include/net/arp.h	2013-12-12 11:56:45.541936083 -0800
@@ -62,6 +62,5 @@ struct sk_buff *arp_create(int type, int
 			   const unsigned char *src_hw,
 			   const unsigned char *target_hw);
 void arp_xmit(struct sk_buff *skb);
-int arp_invalidate(struct net_device *dev, __be32 ip);
 
 #endif	/* _ARP_H */
--- a/net/ipv4/arp.c	2013-12-12 11:48:17.269851915 -0800
+++ b/net/ipv4/arp.c	2013-12-12 11:56:45.545936021 -0800
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
