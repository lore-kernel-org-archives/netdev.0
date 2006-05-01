From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: fix iwmode crash when down
Date: Mon, 1 May 2006 22:43:00 +0200
Message-ID: <200605012243.01010.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57779
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932234AbWEAUg5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 16:36:57 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Second attempt, now unmangled and with signed-off-by line, uh...)
This should go into 2.6.17, as it fixes a user exploitable crash.

--

This fixes a crash when
iwconfig ethX mode foo
is done before
ifconfig ethX up
or after
ifconfig ethX down

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-04-22 17:47:03.000000000 +0200
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-05-01 22:10:18.000000000 +0200
@@ -182,8 +182,11 @@
 		mode = BCM43xx_INITIAL_IWMODE;
 
 	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->ieee->iw_mode != mode)
-		bcm43xx_set_iwmode(bcm, mode);
+	if (bcm->initialized) {
+		if (bcm->ieee->iw_mode != mode)
+			bcm43xx_set_iwmode(bcm, mode);
+	} else
+		bcm->ieee->iw_mode = mode;
 	bcm43xx_unlock_mmio(bcm, flags);
 
 	return 0;


-- 
Greetings Michael.
