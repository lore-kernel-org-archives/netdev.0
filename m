From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 2/6] wlcore: use to_delayed_work
Date: Fri,  1 Jan 2016 23:48:53 +0800
Message-ID: <7e3f7f2de228014b7039a935f16478e9ab8a05e5.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, Eliad Peller <eliad@wizery.com>,
	Kobi Leibovitch <kobi.lev100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:51543 "EHLO m50-135.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbcAAPta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2016 10:49:30 -0500
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/wireless/ti/wlcore/main.c | 10 +++++-----
 drivers/net/wireless/ti/wlcore/ps.c   |  2 +-
 drivers/net/wireless/ti/wlcore/scan.c |  2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index ec7f6af..5c12caa 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -244,7 +244,7 @@ static void wl12xx_tx_watchdog_work(struct work_struct *work)
 	struct delayed_work *dwork;
 	struct wl1271 *wl;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wl = container_of(dwork, struct wl1271, tx_watchdog_work);
 
 	mutex_lock(&wl->mutex);
@@ -2085,7 +2085,7 @@ static void wlcore_channel_switch_work(struct work_struct *work)
 	struct wl12xx_vif *wlvif;
 	int ret;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wlvif = container_of(dwork, struct wl12xx_vif, channel_switch_work);
 	wl = wlvif->wl;
 
@@ -2121,7 +2121,7 @@ static void wlcore_connection_loss_work(struct work_struct *work)
 	struct ieee80211_vif *vif;
 	struct wl12xx_vif *wlvif;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wlvif = container_of(dwork, struct wl12xx_vif, connection_loss_work);
 	wl = wlvif->wl;
 
@@ -2150,7 +2150,7 @@ static void wlcore_pending_auth_complete_work(struct work_struct *work)
 	unsigned long time_spare;
 	int ret;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wlvif = container_of(dwork, struct wl12xx_vif,
 			     pending_auth_complete_work);
 	wl = wlvif->wl;
@@ -5660,7 +5660,7 @@ static void wlcore_roc_complete_work(struct work_struct *work)
 	struct wl1271 *wl;
 	int ret;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wl = container_of(dwork, struct wl1271, roc_complete_work);
 
 	ret = wlcore_roc_completed(wl);
diff --git a/drivers/net/wireless/ti/wlcore/ps.c b/drivers/net/wireless/ti/wlcore/ps.c
index 4cd316e..d4420da 100644
--- a/drivers/net/wireless/ti/wlcore/ps.c
+++ b/drivers/net/wireless/ti/wlcore/ps.c
@@ -38,7 +38,7 @@ void wl1271_elp_work(struct work_struct *work)
 	struct wl12xx_vif *wlvif;
 	int ret;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wl = container_of(dwork, struct wl1271, elp_work);
 
 	wl1271_debug(DEBUG_PSM, "elp work");
diff --git a/drivers/net/wireless/ti/wlcore/scan.c b/drivers/net/wireless/ti/wlcore/scan.c
index 1e3d51c..a384f3f 100644
--- a/drivers/net/wireless/ti/wlcore/scan.c
+++ b/drivers/net/wireless/ti/wlcore/scan.c
@@ -38,7 +38,7 @@ void wl1271_scan_complete_work(struct work_struct *work)
 	struct wl12xx_vif *wlvif;
 	int ret;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wl = container_of(dwork, struct wl1271, scan_complete_work);
 
 	wl1271_debug(DEBUG_SCAN, "Scanning complete");
-- 
2.5.0
