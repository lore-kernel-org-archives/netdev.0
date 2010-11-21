From: Joe Perches <joe@perches.com>
Subject: [PATCH 59/62] rndis_wlan: Use static const
Date: Sat, 20 Nov 2010 18:39:00 -0800
Message-ID: <0b953a3dc6bb044f9aee4033caeb1693ac0796fc.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  41757	   2205	   9896	  53858	   d262	drivers/net/wireless/rndis_wlan.o.old
  41653	   2205	   9880	  53738	   d1ea	drivers/net/wireless/rndis_wlan.o.new

Changed functions rndis_set_oid and set_bssid to take const *'s.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rndis_wlan.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index ee08bca..19f3d56 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -817,7 +817,8 @@ exit_unlock:
 	return ret;
 }
 
-static int rndis_set_oid(struct usbnet *dev, __le32 oid, void *data, int len)
+static int rndis_set_oid(struct usbnet *dev, __le32 oid, const void *data,
+			 int len)
 {
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(dev);
 	union {
@@ -1033,7 +1034,7 @@ static int set_essid(struct usbnet *usbdev, struct ndis_80211_ssid *ssid)
 	return ret;
 }
 
-static int set_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
+static int set_bssid(struct usbnet *usbdev, const u8 *bssid)
 {
 	int ret;
 
@@ -1049,7 +1050,9 @@ static int set_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 
 static int clear_bssid(struct usbnet *usbdev)
 {
-	u8 broadcast_mac[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	static const u8 broadcast_mac[ETH_ALEN] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
 
 	return set_bssid(usbdev, broadcast_mac);
 }
-- 
1.7.3.2.245.g03276.dirty
