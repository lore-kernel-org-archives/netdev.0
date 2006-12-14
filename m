From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 4/7] Fix unchecked nr_add_node uses
Date: Thu, 14 Dec 2006 23:42:10 +0100
Message-ID: <11661361353724-git-send-email-ralf@linux-mips.org>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:47091 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbWLNXOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:14:45 -0500
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/netrom/nr_route.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Index: linux-net/net/netrom/nr_route.c
===================================================================
--- linux-net.orig/net/netrom/nr_route.c
+++ linux-net/net/netrom/nr_route.c
@@ -779,9 +779,13 @@ int nr_route_frame(struct sk_buff *skb, 
 	nr_src  = (ax25_address *)(skb->data + 0);
 	nr_dest = (ax25_address *)(skb->data + 7);
 
-	if (ax25 != NULL)
-		nr_add_node(nr_src, "", &ax25->dest_addr, ax25->digipeat,
-			    ax25->ax25_dev->dev, 0, sysctl_netrom_obsolescence_count_initialiser);
+	if (ax25 != NULL) {
+		ret = nr_add_node(nr_src, "", &ax25->dest_addr, ax25->digipeat,
+		                  ax25->ax25_dev->dev, 0,
+		                  sysctl_netrom_obsolescence_count_initialiser);
+		if (ret)
+			return ret;
+	}
 
 	if ((dev = nr_dev_get(nr_dest)) != NULL) {	/* Its for me */
 		if (ax25 == NULL)			/* Its from me */
@@ -846,6 +850,7 @@ int nr_route_frame(struct sk_buff *skb, 
 	ret = (nr_neigh->ax25 != NULL);
 	nr_node_unlock(nr_node);
 	nr_node_put(nr_node);
+
 	return ret;
 }
 
