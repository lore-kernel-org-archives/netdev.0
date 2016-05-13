From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: [PATCH] mac80211_hwsim: Add missing check for HWSIM_ATTR_SIGNAL
Date: Fri, 13 May 2016 12:41:48 +0200
Message-ID: <1463136108-4434-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A wmediumd that does not send this attribute causes a NULL pointer
dereference, as the attribute is accessed even if it does not exist.

The attribute was required but never checked ever since userspace frame
forwarding has been introduced. The issue gets more problematic once we
allow wmediumd registration from user namespaces.

Fixes: 7882513bacb1 ("mac80211_hwsimdriver support userspace frame tx/rx")
Signed-off-by: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
---
 drivers/net/wireless/mac80211_hwsim.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 303d94d..a16cd0c 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2817,6 +2817,7 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 	if (!info->attrs[HWSIM_ATTR_ADDR_TRANSMITTER] ||
 	    !info->attrs[HWSIM_ATTR_FLAGS] ||
 	    !info->attrs[HWSIM_ATTR_COOKIE] ||
+	    !info->attrs[HWSIM_ATTR_SIGNAL] ||
 	    !info->attrs[HWSIM_ATTR_TX_INFO])
 		goto out;
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
