From: Eldad Zack <eldad-v6AqZgAe4C4dvzyIwGCCOg@public.gmane.org>
Subject: [PATCH] [brcmsmac] "INTERMEDIATE but not AMPDU" only when tracing
Date: Sun, 22 Apr 2012 00:48:04 +0200
Message-ID: <1335048484-5925-1-git-send-email-eldad@fogrefinery.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eldad Zack <eldad-v6AqZgAe4C4dvzyIwGCCOg@public.gmane.org>
To: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kan Yan <kanyan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I keep getting the following messages on the log buffer:
[ 2167.097507] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU
[ 2281.331305] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU
[ 2281.332539] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU
[ 2329.876605] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU
[ 2329.877354] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU
[ 2462.280756] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU
[ 2615.651689] ieee80211 phy0: brcms_c_dotxstatus: INTERMEDIATE but not AMPDU

>From the code comment I understand that this something that can - and does, quite frequently - happen.
This patch demotes the message to the trace level.

Signed-off-by: Eldad Zack <eldad-v6AqZgAe4C4dvzyIwGCCOg@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 231ddf4..2fc5956 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -847,8 +847,7 @@ brcms_c_dotxstatus(struct brcms_c_info *wlc, struct tx_status *txs)
 	 */
 	if (!(txs->status & TX_STATUS_AMPDU)
 	    && (txs->status & TX_STATUS_INTERMEDIATE)) {
-		wiphy_err(wlc->wiphy, "%s: INTERMEDIATE but not AMPDU\n",
-			  __func__);
+		BCMMSG(wlc->wiphy, "INTERMEDIATE but not AMPDU\n");
 		return false;
 	}
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
