From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Fix scaling error for 'iwlist rate' information
Date: Tue, 23 Jan 2007 14:26:35 -0600
Message-ID: <45b66f7b.qEvXToJSJL5WnxfG%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The bcm43xx scales the rate information supplied to a WE iwlist rate call incorrectly.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This fix should be applied to wireless-2.6. As it is a bug fix, it could also be sent
to 2.6.20; however, it has no real effect on system operations, and it doesn't mtter.

Larry
---
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -261,22 +261,22 @@ static int bcm43xx_wx_get_rangeparams(st
 	if (phy->type == BCM43xx_PHYTYPE_A ||
 	    phy->type == BCM43xx_PHYTYPE_G) {
 		range->num_bitrates = 8;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_6MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_9MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_12MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_18MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_24MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_36MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_48MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_54MB;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_6MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_9MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_12MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_18MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_24MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_36MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_48MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_54MB * 500000;
 	}
 	if (phy->type == BCM43xx_PHYTYPE_B ||
 	    phy->type == BCM43xx_PHYTYPE_G) {
 		range->num_bitrates += 4;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_1MB;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_2MB;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_5MB;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_11MB;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_1MB * 500000;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_2MB * 500000;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_5MB * 500000;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_11MB * 500000;
 	}
 
 	geo = ieee80211_get_geo(bcm->ieee);

---
