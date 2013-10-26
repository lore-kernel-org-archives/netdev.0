From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 15/16] wl1251: Add sysfs file tx_mgmt_frm_rate for setting rate
Date: Sat, 26 Oct 2013 22:34:14 +0200
Message-ID: <1382819655-30430-16-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch was extracted from Maemo 2.6.28 kernel

Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c |  152 +++++++++++++++++++++++++=
++++++++
 1 file changed, 152 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index 7b9efc8..29625c2 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -1375,6 +1375,147 @@ static const struct ieee80211_ops wl1251_ops =3D=
 {
 	.get_survey =3D wl1251_op_get_survey,
 };
=20
+static ssize_t wl1251_sysfs_show_tx_mgmt_frm_rate(struct device *dev,
+						  struct device_attribute *attr,
+						  char *buf)
+{
+	struct wl1251 *wl =3D dev_get_drvdata(dev);
+	ssize_t len;
+	int val;
+
+	/* FIXME: what's the maximum length of buf? page size?*/
+	len =3D 500;
+
+	switch (wl->tx_mgmt_frm_rate) {
+		/* skip 1 and 12 Mbps because they have same value 0x0a */
+	case RATE_2MBPS:
+		val =3D 20;
+		break;
+	case RATE_5_5MBPS:
+		val =3D 55;
+		break;
+	case RATE_11MBPS:
+		val =3D 110;
+		break;
+	case RATE_6MBPS:
+		val =3D 60;
+		break;
+	case RATE_9MBPS:
+		val =3D 90;
+		break;
+	case RATE_12MBPS:
+		val =3D 120;
+		break;
+	case RATE_18MBPS:
+		val =3D 180;
+		break;
+	case RATE_24MBPS:
+		val =3D 240;
+		break;
+	case RATE_36MBPS:
+		val =3D 360;
+		break;
+	case RATE_48MBPS:
+		val =3D 480;
+		break;
+	case RATE_54MBPS:
+		val =3D 540;
+		break;
+	default:
+		val =3D 10;
+	}
+
+	/* for 1 and 12 Mbps we have to check the modulation */
+	if (wl->tx_mgmt_frm_rate =3D=3D RATE_1MBPS) {
+		switch (wl->tx_mgmt_frm_rate) {
+		case CCK_LONG:
+			val =3D 10;
+			break;
+		case OFDM:
+			val =3D 120;
+			break;
+		default:
+			val =3D 10;
+			break;
+		}
+	}
+	len =3D snprintf(buf, len, "%d", val);
+
+	return len;
+}
+
+static ssize_t wl1251_sysfs_store_tx_mgmt_frm_rate(struct device *dev,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
+{
+	struct wl1251 *wl =3D dev_get_drvdata(dev);
+	unsigned long res;
+	int ret;
+
+	ret =3D strict_strtoul(buf, 10, &res);
+
+	if (ret < 0) {
+		wl1251_warning("incorrect value written to tx_mgmt_frm_rate");
+		return 0;
+	}
+
+	switch (res) {
+	case 10:
+		wl->tx_mgmt_frm_rate =3D RATE_1MBPS;
+		wl->tx_mgmt_frm_mod =3D CCK_LONG;
+		break;
+	case 20:
+		wl->tx_mgmt_frm_rate =3D RATE_2MBPS;
+		wl->tx_mgmt_frm_mod =3D CCK_LONG;
+		break;
+	case 55:
+		wl->tx_mgmt_frm_rate =3D RATE_5_5MBPS;
+		wl->tx_mgmt_frm_mod =3D CCK_LONG;
+		break;
+	case 110:
+		wl->tx_mgmt_frm_rate =3D RATE_11MBPS;
+		wl->tx_mgmt_frm_mod =3D CCK_LONG;
+		break;
+	case 60:
+		wl->tx_mgmt_frm_rate =3D RATE_6MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 90:
+		wl->tx_mgmt_frm_rate =3D RATE_9MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 120:
+		wl->tx_mgmt_frm_rate =3D RATE_12MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 180:
+		wl->tx_mgmt_frm_rate =3D RATE_18MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 240:
+		wl->tx_mgmt_frm_rate =3D RATE_24MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 360:
+		wl->tx_mgmt_frm_rate =3D RATE_36MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 480:
+		wl->tx_mgmt_frm_rate =3D RATE_48MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	case 540:
+		wl->tx_mgmt_frm_rate =3D RATE_54MBPS;
+		wl->tx_mgmt_frm_mod =3D OFDM;
+		break;
+	default:
+		wl1251_warning("incorrect value written to tx_mgmt_frm_rate");
+		return 0;
+	}
+
+	return count;
+}
+
 static ssize_t wl1251_sysfs_show_bt_coex_mode(struct device *dev,
 					      struct device_attribute *attr,
 					      char *buf)
@@ -1443,6 +1584,10 @@ out:
 	return count;
 }
=20
+static DEVICE_ATTR(tx_mgmt_frm_rate, S_IRUGO | S_IWUSR,
+		   wl1251_sysfs_show_tx_mgmt_frm_rate,
+		   wl1251_sysfs_store_tx_mgmt_frm_rate);
+
 static DEVICE_ATTR(bt_coex_mode, S_IRUGO | S_IWUSR,
 		   wl1251_sysfs_show_bt_coex_mode,
 		   wl1251_sysfs_store_bt_coex_mode);
@@ -1583,6 +1728,13 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
 	}
 	dev_set_drvdata(&wl1251_device.dev, wl);
=20
+	/* Create sysfs file tx_mgmt_frm_rate */
+	ret =3D device_create_file(&wl1251_device.dev,
+				 &dev_attr_tx_mgmt_frm_rate);
+	if (ret < 0) {
+		wl1251_error("failed to create sysfs file tx_mgmt_frm_rate");
+		goto out;
+	}
=20
 	/* Create sysfs file to control bt coex state */
 	ret =3D device_create_file(&wl1251_device.dev, &dev_attr_bt_coex_mode=
);
--=20
1.7.10.4
