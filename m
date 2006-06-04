From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: quiet down log spam from set_security
Date: Sun, 4 Jun 2006 23:05:49 +0200
Message-ID: <200606042305.49733.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	Jason Lunz <lunz@falooley.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49830
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932249AbWFDVGC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 17:06:02 -0400
Content-Disposition: inline
To: "John Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John, please queue for 2.6.18.

--

From: Jason Lunz <lunz@falooley.org>

The debug logging in bcm43xx_ieee80211_set_security() is pretty noisy.
Make it more silent.

Signed-off-by: Jason Lunz <lunz@falooley.org>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff -ur linux-2.6.17-rc5-git11/drivers/net/wireless/bcm43xx/bcm43xx_main.c linux-2.6.17-rc5-git11.quiet/drivers/net/wireless/bcm43xx/bcm43xx_main.c
--- linux-2.6.17-rc5-git11/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-29 12:33:56.000000000 -0400
+++ linux-2.6.17-rc5-git11.quiet/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-04 14:51:09.000000000 -0400
@@ -3568,7 +3568,7 @@
 	unsigned long flags;
 	int keyidx;
 	
-	dprintk(KERN_INFO PFX "set security called\n");
+	dprintk(KERN_INFO PFX "set security called");
 
 	bcm43xx_lock_mmio(bcm, flags);
 
@@ -3581,24 +3581,25 @@
 	
 	if (sec->flags & SEC_ACTIVE_KEY) {
 		secinfo->active_key = sec->active_key;
-		dprintk(KERN_INFO PFX "   .active_key = %d\n", sec->active_key);
+		dprintk(", .active_key = %d", sec->active_key);
 	}
 	if (sec->flags & SEC_UNICAST_GROUP) {
 		secinfo->unicast_uses_group = sec->unicast_uses_group;
-		dprintk(KERN_INFO PFX "   .unicast_uses_group = %d\n", sec->unicast_uses_group);
+		dprintk(", .unicast_uses_group = %d", sec->unicast_uses_group);
 	}
 	if (sec->flags & SEC_LEVEL) {
 		secinfo->level = sec->level;
-		dprintk(KERN_INFO PFX "   .level = %d\n", sec->level);
+		dprintk(", .level = %d", sec->level);
 	}
 	if (sec->flags & SEC_ENABLED) {
 		secinfo->enabled = sec->enabled;
-		dprintk(KERN_INFO PFX "   .enabled = %d\n", sec->enabled);
+		dprintk(", .enabled = %d", sec->enabled);
 	}
 	if (sec->flags & SEC_ENCRYPT) {
 		secinfo->encrypt = sec->encrypt;
-		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
+		dprintk(", .encrypt = %d", sec->encrypt);
 	}
+	dprintk("\n");
 	if (bcm->initialized && !bcm->ieee->host_encrypt) {
 		if (secinfo->enabled) {
 			/* upload WEP keys to hardware */

-- 
Greetings Michael.
