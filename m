From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 10/10][NETROM]: Use kmemdup
Date: Fri, 17 Nov 2006 13:20:29 -0200
Message-ID: <20061117152028.GK17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:10127 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755718AbWKQPUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:20:42 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/netrom/nr_route.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index c11737f..0096105 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -155,14 +155,15 @@ static int nr_add_node(ax25_address *nr,
 		atomic_set(&nr_neigh->refcount, 1);
 
 		if (ax25_digi != NULL && ax25_digi->ndigi > 0) {
-			if ((nr_neigh->digipeat = kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
+			nr_neigh->digipeat = kmemdup(ax25_digi,
+						     sizeof(*ax25_digi),
+						     GFP_KERNEL);
+			if (nr_neigh->digipeat == NULL) {
 				kfree(nr_neigh);
 				if (nr_node)
 					nr_node_put(nr_node);
 				return -ENOMEM;
 			}
-			memcpy(nr_neigh->digipeat, ax25_digi,
-					sizeof(*ax25_digi));
 		}
 
 		spin_lock_bh(&nr_neigh_list_lock);
@@ -432,11 +433,12 @@ static int nr_add_neigh(ax25_address *ca
 	atomic_set(&nr_neigh->refcount, 1);
 
 	if (ax25_digi != NULL && ax25_digi->ndigi > 0) {
-		if ((nr_neigh->digipeat = kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
+		nr_neigh->digipeat = kmemdup(ax25_digi, sizeof(*ax25_digi),
+					     GFP_KERNEL);
+		if (nr_neigh->digipeat == NULL) {
 			kfree(nr_neigh);
 			return -ENOMEM;
 		}
-		memcpy(nr_neigh->digipeat, ax25_digi, sizeof(*ax25_digi));
 	}
 
 	spin_lock_bh(&nr_neigh_list_lock);
-- 
1.4.2.1.g3d5c

