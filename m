From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 3/4] batman-adv: Remove vis info element in free_info
Date: Sun, 30 Jan 2011 13:11:43 +0100
Message-ID: <1296389504-11208-4-git-send-email-sven@narfation.org>
References: <1296389504-11208-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45225 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753558Ab1A3ML5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 07:11:57 -0500
In-Reply-To: <1296389504-11208-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The free_info function will be called when no reference to the info
object exists anymore. It must be ensured that the allocated memory
gets freed and not only the elements which are managed by the info
object.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/vis.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 0be55be..988296c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -64,6 +64,7 @@ static void free_info(struct kref *ref)
 
 	spin_unlock_bh(&bat_priv->vis_list_lock);
 	kfree_skb(info->skb_packet);
+	kfree(info);
 }
 
 /* Compare two vis packets, used by the hashing algorithm */
-- 
1.7.2.3

