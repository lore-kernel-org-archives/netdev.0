From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/21] batman-adv: don't initialise batman_iv private members in hard-interface.c
Date: Wed, 29 May 2013 02:59:34 +0200
Message-ID: <1369789186-3600-10-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43859 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934243Ab3E2BBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:51 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

hard-interface.c has to do not contain any routing algorithm
specific code.

Allocate the hard-interface with kzalloc() and remove any
useless and algorithm specific member initialisation

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 4a76ed6..c478e6b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -577,7 +577,7 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 
 	dev_hold(net_dev);
 
-	hard_iface = kmalloc(sizeof(*hard_iface), GFP_ATOMIC);
+	hard_iface = kzalloc(sizeof(*hard_iface), GFP_ATOMIC);
 	if (!hard_iface)
 		goto release_dev;
 
@@ -603,12 +603,6 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	batadv_check_known_mac_addr(hard_iface->net_dev);
 	list_add_tail_rcu(&hard_iface->list, &batadv_hardif_list);
 
-	/* This can't be called via a bat_priv callback because
-	 * we have no bat_priv yet.
-	 */
-	atomic_set(&hard_iface->bat_iv.ogm_seqno, 1);
-	hard_iface->bat_iv.ogm_buff = NULL;
-
 	return hard_iface;
 
 free_if:
-- 
1.8.1.5
