From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 4/5] d80211/bcm43xx: fix build for ARM
Date: Tue, 22 Aug 2006 10:34:03 -0700
Message-ID: <20060822173403.GE12500@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-9.dex002.intermedia.net ([64.78.21.63]:6301 "EHLO
	dhost002-9.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751181AbWHVReE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 13:34:04 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="bcm43xx-udelay.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARM targets support udelay(N) where N <= 2000.
Use mdelay() when N >= 2000.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
@@ -291,7 +291,7 @@ int bcm43xx_pctl_set_crystal(struct bcm4
 		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCTL_OUT, out);
 		if (err)
 			goto err_pci;
-		udelay(5000);
+		mdelay(5);
 	} else {
 		if (bcm->current_core->rev < 5)
 			return 0;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
@@ -1687,7 +1687,7 @@ int bcm43xx_radio_selectchannel(struct b
 	radio->channel = channel;
 	//XXX: Using the longer of 2 timeouts (8000 vs 2000 usecs). Specs states
 	//     that 2000 usecs might suffice.
-	udelay(8000);
+	mdelay(8);
 
 	return 0;
 }

--
