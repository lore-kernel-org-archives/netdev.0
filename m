From: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Subject: [PATCH] net/wireless/brcm80211/brcmfmac: Make return type reflect actual semantics
Date: Fri, 20 Jun 2014 23:32:03 +0200
Message-ID: <1403299923-21533-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
To: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Applying ++ to a bool is equivalent to setting it true, regardless of
its initial value (bools are not uint1_t). Hence the function
wl_get_vif_state_all can only ever return true/false. The only
in-tree caller uses its return value as a boolean. So update its
return type, and since the list traversal and bit testing have no side
effects, just return true immediately.

Signed-off-by: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
---

Notes:
    Alternatively, if the function is supposed to return a count, the
    one-line fix would be
    
    -	bool result = 0;
    +	u32 result = 0;

 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 7 +++----
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h | 2 +-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index d8fa276..ec5f8c5 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -5625,16 +5625,15 @@ enum nl80211_iftype brcmf_cfg80211_get_iftype(struct brcmf_if *ifp)
 	return wdev->iftype;
 }
 
-u32 wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state)
+bool wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state)
 {
 	struct brcmf_cfg80211_vif *vif;
-	bool result = 0;
 
 	list_for_each_entry(vif, &cfg->vif_list, list) {
 		if (test_bit(state, &vif->sme_state))
-			result++;
+			return true;
 	}
-	return result;
+	return false;
 }
 
 static inline bool vif_event_equals(struct brcmf_cfg80211_vif_event *event,
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
index 283c525..c702e4e 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
@@ -477,7 +477,7 @@ const struct brcmf_tlv *
 brcmf_parse_tlvs(const void *buf, int buflen, uint key);
 u16 channel_to_chanspec(struct brcmu_d11inf *d11inf,
 			struct ieee80211_channel *ch);
-u32 wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state);
+bool wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state);
 void brcmf_cfg80211_arm_vif_event(struct brcmf_cfg80211_info *cfg,
 				  struct brcmf_cfg80211_vif *vif);
 bool brcmf_cfg80211_vif_event_armed(struct brcmf_cfg80211_info *cfg);
-- 
1.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
