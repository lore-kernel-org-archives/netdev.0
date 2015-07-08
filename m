From: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Subject: [PATCH v2] brcmsmac: Use kstrdup to simplify code
Date: Wed,  8 Jul 2015 22:22:46 +0200
Message-ID: <1436386966-16148-1-git-send-email-christophe.jaillet@wanadoo.fr>
References: <1436383927-14010-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1436383927-14010-1-git-send-email-christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace a kmalloc+strcpy by an equivalent kstrdup in order to improve
readability.

Signed-off-by: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
---
v2: fix the subject

 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 4813506..8a6c077 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1476,9 +1476,7 @@ struct brcms_timer *brcms_init_timer(struct brcms_info *wl,
 	wl->timers = t;
 
 #ifdef DEBUG
-	t->name = kmalloc(strlen(name) + 1, GFP_ATOMIC);
-	if (t->name)
-		strcpy(t->name, name);
+	t->name = kstrdup(name, GFP_ATOMIC);
 #endif
 
 	return t;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
