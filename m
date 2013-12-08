From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 08/16] wl1251: disable power saving in monitor mode
Date: Sun,  8 Dec 2013 10:25:06 +0100
Message-ID: <1386494714-21070-9-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Gnedt <david.gnedt@davizone.at>

=46orce power saving off while monitor interface is present.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index ee318c8..1223bc6 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -570,6 +570,11 @@ static int wl1251_build_qos_null_data(struct wl125=
1 *wl)
 				       sizeof(template));
 }
=20
+static bool wl1251_can_do_pm(struct ieee80211_conf *conf, struct wl125=
1 *wl)
+{
+	return (conf->flags & IEEE80211_CONF_PS) && !wl->monitor_present;
+}
+
 static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct wl1251 *wl =3D hw->priv;
@@ -617,7 +622,7 @@ static int wl1251_op_config(struct ieee80211_hw *hw=
, u32 changed)
 			goto out_sleep;
 	}
=20
-	if (conf->flags & IEEE80211_CONF_PS && !wl->psm_requested) {
+	if (wl1251_can_do_pm(conf, wl) && !wl->psm_requested) {
 		wl1251_debug(DEBUG_PSM, "psm enabled");
=20
 		wl->psm_requested =3D true;
@@ -633,8 +638,7 @@ static int wl1251_op_config(struct ieee80211_hw *hw=
, u32 changed)
 		ret =3D wl1251_ps_set_mode(wl, STATION_POWER_SAVE_MODE);
 		if (ret < 0)
 			goto out_sleep;
-	} else if (!(conf->flags & IEEE80211_CONF_PS) &&
-		   wl->psm_requested) {
+	} else if (!wl1251_can_do_pm(conf, wl) && wl->psm_requested) {
 		wl1251_debug(DEBUG_PSM, "psm disabled");
=20
 		wl->psm_requested =3D false;
--=20
1.7.9.5
