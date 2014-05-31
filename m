From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 6/11] net: wireless: Remove useless return variables
Date: Sat, 31 May 2014 10:14:06 -0300
Message-ID: <1401542051-3174-6-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

wl_cfg80211.c verified by compilation only.
phy/phy_cmn.c unverified.

The coccinelle script that find and fixes this issue is:
// <smpl>
@@
type T;
constant C;
identifier ret;
@@
- T ret = C;
... when != ret
    when strict
return
- ret
+ C
;
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |   18 ++++++------------
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c |    6 +-----
 2 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index d8fa276..db3d848 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -1331,7 +1331,6 @@ static s32
 brcmf_cfg80211_leave_ibss(struct wiphy *wiphy, struct net_device *ndev)
 {
 	struct brcmf_if *ifp = netdev_priv(ndev);
-	s32 err = 0;
 
 	brcmf_dbg(TRACE, "Enter\n");
 	if (!check_vif_up(ifp->vif))
@@ -1341,7 +1340,7 @@ brcmf_cfg80211_leave_ibss(struct wiphy *wiphy, struct net_device *ndev)
 
 	brcmf_dbg(TRACE, "Exit\n");
 
-	return err;
+	return 0;
 }
 
 static s32 brcmf_set_wpa_version(struct net_device *ndev,
@@ -2388,7 +2387,6 @@ static s32 brcmf_inform_single_bss(struct brcmf_cfg80211_info *cfg,
 	struct cfg80211_bss *bss;
 	struct ieee80211_supported_band *band;
 	struct brcmu_chan ch;
-	s32 err = 0;
 	u16 channel;
 	u32 freq;
 	u16 notify_capability;
@@ -2438,7 +2436,7 @@ static s32 brcmf_inform_single_bss(struct brcmf_cfg80211_info *cfg,
 
 	cfg80211_put_bss(wiphy, bss);
 
-	return err;
+	return 0;
 }
 
 static struct brcmf_bss_info_le *
@@ -2690,7 +2688,6 @@ brcmf_cfg80211_escan_handler(struct brcmf_if *ifp,
 {
 	struct brcmf_cfg80211_info *cfg = ifp->drvr->config;
 	s32 status;
-	s32 err = 0;
 	struct brcmf_escan_result_le *escan_result_le;
 	struct brcmf_bss_info_le *bss_info_le;
 	struct brcmf_bss_info_le *bss = NULL;
@@ -2781,7 +2778,7 @@ brcmf_cfg80211_escan_handler(struct brcmf_if *ifp,
 				  status);
 	}
 exit:
-	return err;
+	return 0;
 }
 
 static void brcmf_init_escan(struct brcmf_cfg80211_info *cfg)
@@ -3507,7 +3504,6 @@ static s32
 brcmf_parse_vndr_ies(const u8 *vndr_ie_buf, u32 vndr_ie_len,
 		     struct parsed_vndr_ies *vndr_ies)
 {
-	s32 err = 0;
 	struct brcmf_vs_tlv *vndrie;
 	struct brcmf_tlv *ie;
 	struct parsed_vndr_ie_info *parsed_info;
@@ -3560,7 +3556,7 @@ next:
 			ie = (struct brcmf_tlv *)(((u8 *)ie) + ie->len +
 				TLV_HDR_LEN);
 	}
-	return err;
+	return 0;
 }
 
 static u32
@@ -4650,7 +4646,6 @@ brcmf_bss_connect_done(struct brcmf_cfg80211_info *cfg,
 	struct brcmf_if *ifp = netdev_priv(ndev);
 	struct brcmf_cfg80211_profile *profile = &ifp->vif->profile;
 	struct brcmf_cfg80211_connect_info *conn_info = cfg_to_conn(cfg);
-	s32 err = 0;
 
 	brcmf_dbg(TRACE, "Enter\n");
 
@@ -4676,7 +4671,7 @@ brcmf_bss_connect_done(struct brcmf_cfg80211_info *cfg,
 			  completed ? "succeeded" : "failed");
 	}
 	brcmf_dbg(TRACE, "Exit\n");
-	return err;
+	return 0;
 }
 
 static s32
@@ -4768,7 +4763,6 @@ brcmf_notify_roaming_status(struct brcmf_if *ifp,
 			    const struct brcmf_event_msg *e, void *data)
 {
 	struct brcmf_cfg80211_info *cfg = ifp->drvr->config;
-	s32 err = 0;
 	u32 event = e->event_code;
 	u32 status = e->status;
 
@@ -4779,7 +4773,7 @@ brcmf_notify_roaming_status(struct brcmf_if *ifp,
 			brcmf_bss_connect_done(cfg, ifp->ndev, e, true);
 	}
 
-	return err;
+	return 0;
 }
 
 static s32
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
index b0fd807..57ecc05 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
@@ -1538,11 +1538,7 @@ static s8
 wlc_user_txpwr_antport_to_rfport(struct brcms_phy *pi, uint chan, u32 band,
 				 u8 rate)
 {
-	s8 offset = 0;
-
-	if (!pi->user_txpwr_at_rfport)
-		return offset;
-	return offset;
+	return 0;
 }
 
 void wlc_phy_txpower_recalc_target(struct brcms_phy *pi)
