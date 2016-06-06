From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: drop unused pm_block vif attribute
Date: Mon,  6 Jun 2016 23:03:55 +0200
Message-ID: <1465247047-19412-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This attribute was added 3 years ago by
commit 3eacf866559c ("brcmfmac: introduce brcmf_cfg80211_vif structure"=
)
but it remains unused since then. It seems we can safely drop it.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 9 +++---=
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h | 5 +----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c      | 5 ++---
 3 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index ce35ada..4894eb7 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -603,7 +603,7 @@ struct wireless_dev *brcmf_ap_add_vif(struct wiphy =
*wiphy, const char *name,
=20
 	brcmf_dbg(INFO, "Adding vif \"%s\"\n", name);
=20
-	vif =3D brcmf_alloc_vif(cfg, NL80211_IFTYPE_AP, false);
+	vif =3D brcmf_alloc_vif(cfg, NL80211_IFTYPE_AP);
 	if (IS_ERR(vif))
 		return (struct wireless_dev *)vif;
=20
@@ -5190,8 +5190,7 @@ static struct cfg80211_ops brcmf_cfg80211_ops =3D=
 {
 };
=20
 struct brcmf_cfg80211_vif *brcmf_alloc_vif(struct brcmf_cfg80211_info =
*cfg,
-					   enum nl80211_iftype type,
-					   bool pm_block)
+					   enum nl80211_iftype type)
 {
 	struct brcmf_cfg80211_vif *vif_walk;
 	struct brcmf_cfg80211_vif *vif;
@@ -5206,8 +5205,6 @@ struct brcmf_cfg80211_vif *brcmf_alloc_vif(struct=
 brcmf_cfg80211_info *cfg,
 	vif->wdev.wiphy =3D cfg->wiphy;
 	vif->wdev.iftype =3D type;
=20
-	vif->pm_block =3D pm_block;
-
 	brcmf_init_prof(&vif->profile);
=20
 	if (type =3D=3D NL80211_IFTYPE_AP) {
@@ -6850,7 +6847,7 @@ struct brcmf_cfg80211_info *brcmf_cfg80211_attach=
(struct brcmf_pub *drvr,
 	init_vif_event(&cfg->vif_event);
 	INIT_LIST_HEAD(&cfg->vif_list);
=20
-	vif =3D brcmf_alloc_vif(cfg, NL80211_IFTYPE_STATION, false);
+	vif =3D brcmf_alloc_vif(cfg, NL80211_IFTYPE_STATION);
 	if (IS_ERR(vif))
 		goto wiphy_out;
=20
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
index 95e35bc..c6f9986 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
@@ -167,7 +167,6 @@ struct vif_saved_ie {
  * @wdev: wireless device.
  * @profile: profile information.
  * @sme_state: SME state using enum brcmf_vif_status bits.
- * @pm_block: power-management blocked.
  * @list: linked list.
  * @mgmt_rx_reg: registered rx mgmt frame types.
  * @mbss: Multiple BSS type, set if not first AP (not relevant for P2P=
).
@@ -177,7 +176,6 @@ struct brcmf_cfg80211_vif {
 	struct wireless_dev wdev;
 	struct brcmf_cfg80211_profile profile;
 	unsigned long sme_state;
-	bool pm_block;
 	struct vif_saved_ie saved_ie;
 	struct list_head list;
 	u16 mgmt_rx_reg;
@@ -388,8 +386,7 @@ s32 brcmf_cfg80211_down(struct net_device *ndev);
 enum nl80211_iftype brcmf_cfg80211_get_iftype(struct brcmf_if *ifp);
=20
 struct brcmf_cfg80211_vif *brcmf_alloc_vif(struct brcmf_cfg80211_info =
*cfg,
-					   enum nl80211_iftype type,
-					   bool pm_block);
+					   enum nl80211_iftype type);
 void brcmf_free_vif(struct brcmf_cfg80211_vif *vif);
=20
 s32 brcmf_vif_set_mgmt_ie(struct brcmf_cfg80211_vif *vif, s32 pktflag,
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b/d=
rivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
index 1652a48..fd49cdf 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
@@ -2076,8 +2076,7 @@ static struct wireless_dev *brcmf_p2p_create_p2pd=
ev(struct brcmf_p2p_info *p2p,
 	if (p2p->bss_idx[P2PAPI_BSSCFG_DEVICE].vif)
 		return ERR_PTR(-ENOSPC);
=20
-	p2p_vif =3D brcmf_alloc_vif(p2p->cfg, NL80211_IFTYPE_P2P_DEVICE,
-				  false);
+	p2p_vif =3D brcmf_alloc_vif(p2p->cfg, NL80211_IFTYPE_P2P_DEVICE);
 	if (IS_ERR(p2p_vif)) {
 		brcmf_err("could not create discovery vif\n");
 		return (struct wireless_dev *)p2p_vif;
@@ -2177,7 +2176,7 @@ struct wireless_dev *brcmf_p2p_add_vif(struct wip=
hy *wiphy, const char *name,
 		return ERR_PTR(-EOPNOTSUPP);
 	}
=20
-	vif =3D brcmf_alloc_vif(cfg, type, false);
+	vif =3D brcmf_alloc_vif(cfg, type);
 	if (IS_ERR(vif))
 		return (struct wireless_dev *)vif;
 	brcmf_cfg80211_arm_vif_event(cfg, vif);
--=20
1.8.4.5
