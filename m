From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: print name of connect status event
Date: Fri, 14 Oct 2016 09:45:59 +0200
Message-ID: <20161014074559.22962-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

This simplifies debugging. Format %s (%u) comes from similar debugging
message in brcmf_fweh_event_worker.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 3 ++-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c     | 4 ++--
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h     | 2 ++
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index b777e1b..1e7c6f0 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -5506,7 +5506,8 @@ brcmf_notify_connect_status_ap(struct brcmf_cfg80211_info *cfg,
 	u32 reason = e->reason;
 	struct station_info sinfo;
 
-	brcmf_dbg(CONN, "event %d, reason %d\n", event, reason);
+	brcmf_dbg(CONN, "event %s (%u), reason %d\n",
+		  brcmf_fweh_event_name(event), event, reason);
 	if (event == BRCMF_E_LINK && reason == BRCMF_E_REASON_LINK_BSSCFG_DIS &&
 	    ndev != cfg_to_ndev(cfg)) {
 		brcmf_dbg(CONN, "AP mode link down\n");
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
index 79c081f..c79306b 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
@@ -69,7 +69,7 @@ static struct brcmf_fweh_event_name fweh_event_names[] = {
  *
  * @code: code to lookup.
  */
-static const char *brcmf_fweh_event_name(enum brcmf_fweh_event_code code)
+const char *brcmf_fweh_event_name(enum brcmf_fweh_event_code code)
 {
 	int i;
 	for (i = 0; i < ARRAY_SIZE(fweh_event_names); i++) {
@@ -79,7 +79,7 @@ static const char *brcmf_fweh_event_name(enum brcmf_fweh_event_code code)
 	return "unknown";
 }
 #else
-static const char *brcmf_fweh_event_name(enum brcmf_fweh_event_code code)
+const char *brcmf_fweh_event_name(enum brcmf_fweh_event_code code)
 {
 	return "nodebug";
 }
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h
index 26ff5a9..5fba4b4 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h
@@ -287,6 +287,8 @@ struct brcmf_fweh_info {
 					 void *data);
 };
 
+const char *brcmf_fweh_event_name(enum brcmf_fweh_event_code code);
+
 void brcmf_fweh_attach(struct brcmf_pub *drvr);
 void brcmf_fweh_detach(struct brcmf_pub *drvr);
 int brcmf_fweh_register(struct brcmf_pub *drvr, enum brcmf_fweh_event_code code,
-- 
2.9.3
