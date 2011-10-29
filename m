From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 2/3] batman-adv: add sanity check when removing global tts
Date: Sat, 29 Oct 2011 10:06:45 +0200
Message-ID: <1319875606-7794-3-git-send-email-lindner_marek@yahoo.de>
References: <1319875606-7794-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	stable@kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm20-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.115]:31347
	"HELO nm20-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753850Ab1J2IH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 04:07:28 -0400
In-Reply-To: <1319875606-7794-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

After removing the batman-adv module, the hash may be already gone
when tt_global_del_orig() tries to clean the hash. This patch adds
a sanity check to avoid this.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Tested-by: Alexey Fisher <bug-track@fisher-privat.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index abf05cb..c7aafc7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -722,6 +722,9 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 
+	if (!hash)
+		return;
+
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 		list_lock = &hash->list_locks[i];
-- 
1.7.5.4
