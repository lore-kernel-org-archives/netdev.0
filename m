From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: fix local translation table output
Date: Tue, 29 Jan 2013 08:08:00 +0100
Message-ID: <1359443280-28835-2-git-send-email-ordex@autistici.org>
References: <1359443280-28835-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:61827 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab3A2HJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 02:09:06 -0500
In-Reply-To: <1359443280-28835-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last-seen field has to be printed for all the local
entries but the one marked with the no-purge flag

Introduced by 15727323d9f8864b2d41930940acc38de987045a
("batman-adv: don't print the last_seen time for bat0 TT local entry")

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index fb15b4c..d44672f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -517,8 +517,8 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 				    BATADV_TT_CLIENT_PENDING ? 'X' : '.'),
 				   (tt_common_entry->flags &
 				    BATADV_TT_CLIENT_WIFI ? 'W' : '.'),
-				   no_purge ? last_seen_secs : 0,
-				   no_purge ? last_seen_msecs : 0);
+				   no_purge ? 0 : last_seen_secs,
+				   no_purge ? 0 : last_seen_msecs);
 		}
 		rcu_read_unlock();
 	}
-- 
1.8.1.1
