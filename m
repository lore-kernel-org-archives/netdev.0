From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] batman-adv: Fix mem leak in the batadv_tt_local_event()
 function
Date: Tue, 7 Aug 2012 20:32:34 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1208072030500.3227@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	"David S. Miller" <davem@davemloft.net>,
	Antonio Quartulli <ordex@autistici.org>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Memory is allocated for 'tt_change_node' with kmalloc().
'tt_change_node' may go out of scope really being used for anything
(except have a few members initialized) if we hit the 'del:' label.
This patch makes sure we free the memory in that case.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/batman-adv/translation-table.c | 1 +
 1 file changed, 1 insertion(+)

 Compile tested only.

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a438f4b..99dd8f7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -197,6 +197,7 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 del:
 		list_del(&entry->list);
 		kfree(entry);
+		kfree(tt_change_node);
 		event_removed = true;
 		goto unlock;
 	}
-- 
1.7.11.4


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
