From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] wlcore: Return directly after a failed
 ieee80211_beacon_get() in wlcore_set_beacon_template()
Date: Sun, 29 Oct 2017 21:13:44 +0100
Message-ID: <6ea50cb4-8871-6752-6275-50da266f0e7d@users.sourceforge.net>
References: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Eyal Reizer <eyalr@ti.com>, Iain Hunter <drhunter95@gmail.com>,
        James Minor <james.minor@ni.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maxim Altshul <maxim.altshul@ti.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 20:00:41 +0100

Return directly after a call of the function "ieee80211_beacon_get"
failed at the beginning.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ti/wlcore/main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index efea811c1c83..0365b5e40a8d 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -4018,10 +4018,8 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 	struct sk_buff *beacon = ieee80211_beacon_get(wl->hw, vif);
 	u16 tmpl_id;
 
-	if (!beacon) {
-		ret = -EINVAL;
-		goto out;
-	}
+	if (!beacon)
+		return -EINVAL;
 
 	wl1271_debug(DEBUG_MASTER, "beacon updated");
 
-- 
2.14.3
