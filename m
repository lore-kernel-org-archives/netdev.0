From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/13] batman-adv: move ogm initialization into the proper function
Date: Wed, 18 Apr 2012 12:00:00 +0200
Message-ID: <1334743210-12338-4-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24575 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab2DRJ7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:25 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 8c4b790..f152007 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -332,7 +332,6 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	hard_iface->batman_adv_ptype.dev = hard_iface->net_dev;
 	dev_add_pack(&hard_iface->batman_adv_ptype);
 
-	atomic_set(&hard_iface->seqno, 1);
 	atomic_set(&hard_iface->frag_seqno, 1);
 	bat_info(hard_iface->soft_iface, "Adding interface: %s\n",
 		 hard_iface->net_dev->name);
@@ -451,6 +450,13 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 	check_known_mac_addr(hard_iface->net_dev);
 	list_add_tail_rcu(&hard_iface->list, &hardif_list);
 
+	/**
+	 * This can't be called via a bat_priv callback because
+	 * we have no bat_priv yet.
+	 */
+	atomic_set(&hard_iface->seqno, 1);
+	hard_iface->packet_buff = NULL;
+
 	return hard_iface;
 
 free_if:
-- 
1.7.9.4
