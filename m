From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] bcm43xx: enable shared key authentication
Date: Fri, 16 Jun 2006 20:50:22 +0100 (BST)
Message-ID: <20060616195022.E73CD8A3591@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:12373 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751495AbWFPTuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 15:50:18 -0400
To: linville@tuxdriver.com
Cc: mb@bu3sch.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I recently patched softmac to enable shared key authentication. This small patch
will enable crazy or unfortunate bcm43xx users to use this new capability.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3599,6 +3599,10 @@ static void bcm43xx_ieee80211_set_securi
 		secinfo->encrypt = sec->encrypt;
 		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
 	}
+	if (sec->flags & SEC_AUTH_MODE) {
+		secinfo->auth_mode = sec->auth_mode;
+		dprintk(KERN_INFO PFX "   .auth_mode = %d\n", sec->auth_mode);
+	}
 	if (bcm->initialized && !bcm->ieee->host_encrypt) {
 		if (secinfo->enabled) {
 			/* upload WEP keys to hardware */
