From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH] batman-adv: Return hna count on local buffer fill
Date: Sun, 19 Dec 2010 20:28:10 +0100
Message-ID: <1292786890-17755-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:53939 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932401Ab0LST2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Dec 2010 14:28:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hna_local_fill_buffer must return the number of added hna entries and
not the last checked hash bucket.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
This patch is for net-next-2.6

 net/batman-adv/translation-table.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a19e16c..a633b5a4 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -162,7 +162,7 @@ int hna_local_fill_buffer(struct bat_priv *bat_priv,
 		atomic_set(&bat_priv->hna_local_changed, 0);
 
 	spin_unlock_bh(&bat_priv->hna_lhash_lock);
-	return i;
+	return count;
 }
 
 int hna_local_seq_print_text(struct seq_file *seq, void *offset)
-- 
1.7.2.3

