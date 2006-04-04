From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] bcm43xx_phy.c: fix a memory leak
Date: Tue, 4 Apr 2006 20:56:22 +0200
Message-ID: <20060404185622.GX6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750803AbWDDS4Y@vger.kernel.org>
To: Martin Langer <martin-langer@gmx.de>,
	Stefano Brivio <st3@riseup.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Danny van Dyk <kugelfang@gentoo.org>,
	Andreas Jaggi <andreas.jaggi@waterwave.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a memory leak spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/wireless/bcm43xx/bcm43xx_phy.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.17-rc1-mm1-full/drivers/net/wireless/bcm43xx/bcm43xx_phy.c.old	2006-04-04 19:43:04.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-04-04 19:43:38.000000000 +0200
@@ -2143,22 +2143,23 @@ int bcm43xx_phy_init_tssi2dbm_table(stru
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
 			printk(KERN_ERR PFX "Could not allocate memory"
 					    "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
 		for (idx = 0; idx < 64; idx++)
 			if (bcm43xx_tssi2dbm_entry(dyn_tssi2dbm, idx, pab0, pab1, pab2)) {
 				phy->tssi2dbm = NULL;
 				printk(KERN_ERR PFX "Could not generate "
 						    "tssi2dBm table\n");
+				kfree(dyn_tssi2dbm);
 				return -ENODEV;
 			}
 		phy->tssi2dbm = dyn_tssi2dbm;
 		phy->dyn_tssi_tbl = 1;
 	} else {
 		/* pabX values not set in SPROM. */
 		switch (phy->type) {
 		case BCM43xx_PHYTYPE_A:
 			/* APHY needs a generated table. */
 			phy->tssi2dbm = NULL;
 			printk(KERN_ERR PFX "Could not generate tssi2dBm "
