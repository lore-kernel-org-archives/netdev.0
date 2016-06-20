From: Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 2/3] wlcore: Add support for get_expected_throughput opcode
Date: Mon, 20 Jun 2016 16:00:21 +0300
Message-ID: <1466427622-5953-3-git-send-email-maxim.altshul@ti.com>
References: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
 <1466427622-5953-2-git-send-email-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, <yanivma-l0cyMroinI0@public.gmane.org>, <guym-l0cyMroinI0@public.gmane.org>,
	<arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>
To: <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466427622-5953-2-git-send-email-maxim.altshul-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding this opcode, allows the TI wireless driver,
to report throughput directly from FW to mac80211.

This is used mainly for mesh metric calculation.

Signed-off-by: Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>
---
 drivers/net/wireless/ti/wlcore/main.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 39dec7d..cf4c6af 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5851,6 +5851,20 @@ out:
 	mutex_unlock(&wl->mutex);
 }
 
+static u32 wlcore_op_get_expected_throughput(struct ieee80211_sta *sta)
+{
+	struct wl1271_station *wl_sta = (struct wl1271_station *)sta->drv_priv;
+	struct wl1271 *wl = wl_sta->wl;
+	u8 hlid = wl_sta->hlid;
+	u32 ret = 0;
+
+	/* return in units of 100kbps */
+	if (wl)
+		ret = (wl->links[hlid].fw_rate_mbps * 10);
+
+	return ret;
+}
+
 static bool wl1271_tx_frames_pending(struct ieee80211_hw *hw)
 {
 	struct wl1271 *wl = hw->priv;
@@ -6051,6 +6065,7 @@ static const struct ieee80211_ops wl1271_ops = {
 	.switch_vif_chanctx = wlcore_op_switch_vif_chanctx,
 	.sta_rc_update = wlcore_op_sta_rc_update,
 	.sta_statistics = wlcore_op_sta_statistics,
+	.get_expected_throughput = wlcore_op_get_expected_throughput,
 	CFG80211_TESTMODE_CMD(wl1271_tm_cmd)
 };
 
-- 
2.7.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
