From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 06/10] batman-adv: warn if added interface is part of a bridge
Date: Fri, 17 Feb 2012 15:18:26 +0800
Message-ID: <1329463110-856-7-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm18.bullet.mail.ukl.yahoo.com ([217.146.183.192]:34267 "HELO
	nm18.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751649Ab2BQHT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:19:26 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index d3e0e32..68b667c 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -281,6 +281,14 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	if (!atomic_inc_not_zero(&hard_iface->refcount))
 		goto out;
 
+	/* hard-interface is part of a bridge */
+	if (hard_iface->net_dev->priv_flags & IFF_BRIDGE_PORT)
+		pr_err("You are about to enable batman-adv on '%s' which "
+		       "already is part of a bridge. Unless you know exactly "
+		       "what you are doing this is probably wrong and won't "
+		       "work the way you think it would.\n",
+		       hard_iface->net_dev->name);
+
 	soft_iface = dev_get_by_name(&init_net, iface_name);
 
 	if (!soft_iface) {
-- 
1.7.9
