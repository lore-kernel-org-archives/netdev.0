From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] ieee80211_wx.c: remove dead code
Date: Wed, 15 Mar 2006 17:40:15 +0100
Message-ID: <20060315164015.GZ13973@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751992AbWCOQkS@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since sec->key_sizes[] is an u8, len can't be < 0.

Spotted by the Coverity checker.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc6-mm1-full/net/ieee80211/ieee80211_wx.c.old	2006-03-14 03:01:43.000000000 +0100
+++ linux-2.6.16-rc6-mm1-full/net/ieee80211/ieee80211_wx.c	2006-03-14 03:02:02.000000000 +0100
@@ -505,7 +505,7 @@ int ieee80211_wx_get_encode(struct ieee8
 	len = sec->key_sizes[key];
 	memcpy(keybuf, sec->keys[key], len);
 
-	erq->length = (len >= 0 ? len : 0);
+	erq->length = len;
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	if (ieee->open_wep)
