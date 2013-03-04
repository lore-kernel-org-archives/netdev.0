From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v3 16/23] drivers/net: rename random32() to prandom_u32()
Date: Mon,  4 Mar 2013 21:58:24 +0900
Message-ID: <1362401911-14074-17-git-send-email-akinobu.mita@gmail.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Thomas Sailer <t.sailer@alumni.ethz.ch>,
	Jean-Paul Roubelat <jpr@f6fbb.org>,
	Bing Zhao <bzhao@marvell.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, linux-wireless@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Acked-by: Thomas Sailer <t.sailer@alumni.ethz.ch>
Acked-by: Bing Zhao <bzhao@marvell.com> [mwifiex]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Michael Chan <mchan@broadcom.com>
Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
Cc: Jean-Paul Roubelat <jpr@f6fbb.org>
Cc: Bing Zhao <bzhao@marvell.com>
Cc: Brett Rudley <brudley@broadcom.com>
Cc: Arend van Spriel <arend@broadcom.com>
Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
Cc: Hante Meuleman <meuleman@broadcom.com>
Cc: brcm80211-dev-list@broadcom.com
Cc: netdev@vger.kernel.org
Cc: linux-hams@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
---
* Changes from v2
- add Acked-by: line
- add rename for brcm80211

 drivers/net/ethernet/broadcom/cnic.c          | 4 ++--
 drivers/net/hamradio/baycom_epp.c             | 2 +-
 drivers/net/hamradio/hdlcdrv.c                | 2 +-
 drivers/net/hamradio/yam.c                    | 2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 2 +-
 drivers/net/wireless/mwifiex/cfg80211.c       | 4 ++--
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 149a3a0..5abdd48 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -4085,7 +4085,7 @@ static int cnic_cm_alloc_mem(struct cnic_dev *dev)
 	if (!cp->csk_tbl)
 		return -ENOMEM;
 
-	port_id = random32();
+	port_id = prandom_u32();
 	port_id %= CNIC_LOCAL_PORT_RANGE;
 	if (cnic_init_id_tbl(&cp->csk_port_tbl, CNIC_LOCAL_PORT_RANGE,
 			     CNIC_LOCAL_PORT_MIN, port_id)) {
@@ -4145,7 +4145,7 @@ static int cnic_cm_init_bnx2_hw(struct cnic_dev *dev)
 {
 	u32 seed;
 
-	seed = random32();
+	seed = prandom_u32();
 	cnic_ctx_wr(dev, 45, 0, seed);
 	return 0;
 }
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 49b8b58..484f77e 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -449,7 +449,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 			if ((--bc->hdlctx.slotcnt) > 0)
 				return 0;
 			bc->hdlctx.slotcnt = bc->ch_params.slottime;
-			if ((random32() % 256) > bc->ch_params.ppersist)
+			if ((prandom_u32() % 256) > bc->ch_params.ppersist)
 				return 0;
 		}
 	}
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index a4a3516..3169252 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -389,7 +389,7 @@ void hdlcdrv_arbitrate(struct net_device *dev, struct hdlcdrv_state *s)
 	if ((--s->hdlctx.slotcnt) > 0)
 		return;
 	s->hdlctx.slotcnt = s->ch_params.slottime;
-	if ((random32() % 256) > s->ch_params.ppersist)
+	if ((prandom_u32() % 256) > s->ch_params.ppersist)
 		return;
 	start_tx(dev, s);
 }
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 4cf8f10..ae3feb0 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -638,7 +638,7 @@ static void yam_arbitrate(struct net_device *dev)
 	yp->slotcnt = yp->slot / 10;
 
 	/* is random > persist ? */
-	if ((random32() % 256) > yp->pers)
+	if ((prandom_u32() % 256) > yp->pers)
 		return;
 
 	yam_start_tx(dev, yp);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index 4166e64..bca31a8 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -1118,7 +1118,7 @@ static void brcmf_p2p_afx_handler(struct work_struct *work)
 	if (afx_hdl->is_listen && afx_hdl->my_listen_chan)
 		/* 100ms ~ 300ms */
 		err = brcmf_p2p_discover_listen(p2p, afx_hdl->my_listen_chan,
-						100 * (1 + (random32() % 3)));
+					100 * (1 + (prandom_u32() % 3)));
 	else
 		err = brcmf_p2p_act_frm_search(p2p, afx_hdl->peer_listen_chan);
 
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index a44023a..4513707 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -216,7 +216,7 @@ mwifiex_cfg80211_mgmt_tx(struct wiphy *wiphy, struct wireless_dev *wdev,
 	mwifiex_form_mgmt_frame(skb, buf, len);
 	mwifiex_queue_tx_pkt(priv, skb);
 
-	*cookie = random32() | 1;
+	*cookie = prandom_u32() | 1;
 	cfg80211_mgmt_tx_status(wdev, *cookie, buf, len, true, GFP_ATOMIC);
 
 	wiphy_dbg(wiphy, "info: management frame transmitted\n");
@@ -271,7 +271,7 @@ mwifiex_cfg80211_remain_on_channel(struct wiphy *wiphy,
 					 duration);
 
 	if (!ret) {
-		*cookie = random32() | 1;
+		*cookie = prandom_u32() | 1;
 		priv->roc_cfg.cookie = *cookie;
 		priv->roc_cfg.chan = *chan;
 
-- 
1.8.1.2
