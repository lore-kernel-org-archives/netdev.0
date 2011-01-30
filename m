From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 2/4] batman-adv: Remove vis info on hashing errors
Date: Sun, 30 Jan 2011 13:11:42 +0100
Message-ID: <1296389504-11208-3-git-send-email-sven@narfation.org>
References: <1296389504-11208-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45223 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736Ab1A3MLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 07:11:54 -0500
In-Reply-To: <1296389504-11208-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A newly created vis info object must be removed when it couldn't be
added to the hash. The old_info which has to be replaced was already
removed and isn't related to the hash anymore.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/vis.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index f69a374..0be55be 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -444,7 +444,7 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 			      info);
 	if (hash_added < 0) {
 		/* did not work (for some reason) */
-		kref_put(&old_info->refcount, free_info);
+		kref_put(&info->refcount, free_info);
 		info = NULL;
 	}
 
-- 
1.7.2.3

