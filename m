From: Maxim Altshul <maxim.altshul@ti.com>
Subject: [PATCH v3] wlcore: Add support for get_expected_throughput opcode
Date: Thu, 30 Jun 2016 18:37:42 +0300
Message-ID: <20160630153757.14258-1-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maxim Altshul <maxim.altshul@ti.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	Arik Nemtsov <arik@wizery.com>, Yaniv Machani <yanivma@ti.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43910 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932151AbcF3Pha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 11:37:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding this opcode, allows the TI wireless driver,
to report throughput directly from FW to mac80211.

This is used mainly for mesh metric calculation.

Signed-off-by: Maxim Altshul <maxim.altshul@ti.com>
---
Removed ret and NULL test.

 drivers/net/wireless/ti/wlcore/main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 39dec7d..237dae8c 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5851,6 +5851,16 @@ out:
 	mutex_unlock(&wl->mutex);
 }
 
+static u32 wlcore_op_get_expected_throughput(struct ieee80211_sta *sta)
+{
+	struct wl1271_station *wl_sta = (struct wl1271_station *)sta->drv_priv;
+	struct wl1271 *wl = wl_sta->wl;
+	u8 hlid = wl_sta->hlid;
+
+	/* return in units of Kbps */
+		return (wl->links[hlid].fw_rate_mbps * 1000);
+}
+
 static bool wl1271_tx_frames_pending(struct ieee80211_hw *hw)
 {
 	struct wl1271 *wl = hw->priv;
@@ -6051,6 +6061,7 @@ static const struct ieee80211_ops wl1271_ops = {
 	.switch_vif_chanctx = wlcore_op_switch_vif_chanctx,
 	.sta_rc_update = wlcore_op_sta_rc_update,
 	.sta_statistics = wlcore_op_sta_statistics,
+	.get_expected_throughput = wlcore_op_get_expected_throughput,
 	CFG80211_TESTMODE_CMD(wl1271_tm_cmd)
 };
 
-- 
2.9.0
