From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/4] batman-adv: fix indirect hard_iface NULL dereference
Date: Thu, 15 May 2014 20:50:49 +0200
Message-ID: <1400179852-4064-2-git-send-email-antonio@meshcoding.com>
References: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:42203 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbaEOSxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:53:09 -0400
In-Reply-To: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

If hard_iface is NULL and goto out is made batadv_hardif_free_ref()
doesn't check for NULL before dereferencing it to get to refcount.

Introduced in cb1c92ec37fb70543d133a1fa7d9b54d6f8a1ecd
("batman-adv: add debugfs support to view multiif tables").

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 1785da3..6a48451 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1079,7 +1079,8 @@ int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset)
 	bat_priv->bat_algo_ops->bat_orig_print(bat_priv, seq, hard_iface);
 
 out:
-	batadv_hardif_free_ref(hard_iface);
+	if (hard_iface)
+		batadv_hardif_free_ref(hard_iface);
 	return 0;
 }
 
-- 
1.8.5.5
