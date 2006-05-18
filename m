From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 07/10] [RFT] bcm43xx: allow PHY revision 8, dont give up on unknown phy_rev
Date: Fri, 19 May 2006 00:00:07 +0200
Message-ID: <20060519155729.021000000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:23936 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932379AbWESP5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:57:31 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-gphy_allow_rev8.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow a GPHY to have revision 8. Issue a warning instead of giving up when
dealing with an unknown core revision.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2717,10 +2717,9 @@ static int bcm43xx_probe_cores(struct bc
 			case 10:
 				break;
 			default:
-				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",
+				printk(KERN_WARNING PFX
+				       "Unsupported 80211 core revision %u\n",
 				       core_rev);
-				err = -ENODEV;
-				goto out;
 			}
 			bcm->nr_80211_available++;
 			bcm43xx_init_struct_phyinfo(&ext_80211->phy);
@@ -3377,7 +3376,7 @@ static int bcm43xx_read_phyinfo(struct b
 		bcm->ieee->freq_band = IEEE80211_24GHZ_BAND;
 		break;
 	case BCM43xx_PHYTYPE_G:
-		if (phy_rev > 7)
+		if (phy_rev > 8)
 			phy_rev_ok = 0;
 		bcm->ieee->modulation = IEEE80211_OFDM_MODULATION |
 					IEEE80211_CCK_MODULATION;

--
Ciao
Stefano
