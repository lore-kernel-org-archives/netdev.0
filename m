From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Thu, 18 Jan 2007 10:48:02 -0500
Message-ID: <20070118154801.GB31580@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3964 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932437AbXARQ0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 11:26:11 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit a8b3485287731978899ced11f24628c927890e78:
  Linus Torvalds (1):
        Linux v2.6.20-rc5

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Larry Finger (1):
      bcm43xx: Fix failure to deliver PCI-E interrupts

 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 2ec2e5a..91b752e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2701,8 +2701,8 @@ static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
 		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
 		/* extract core_id, core_rev, core_vendor */
-		core_id = (sb_id_hi & 0xFFF0) >> 4;
-		core_rev = (sb_id_hi & 0xF);
+		core_id = (sb_id_hi & 0x8FF0) >> 4;
+		core_rev = ((sb_id_hi & 0xF) | ((sb_id_hi & 0x7000) >> 8));
 		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
 		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x\n",
@@ -2873,7 +2873,10 @@ static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm,
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		sbimconfiglow |= 0x32;
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
+			sbimconfiglow |= 0x32;
+		else
+			sbimconfiglow |= 0x53;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 
@@ -3077,7 +3080,7 @@ static int bcm43xx_setup_backplane_pci_connection(struct bcm43xx_private *bcm,
 	if (err)
 		goto out;
 
-	if (bcm->current_core->rev < 6 ||
+	if (bcm->current_core->rev < 6 &&
 		bcm->current_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
 		value |= (1 << backplane_flag_nr);
-- 
John W. Linville
linville@tuxdriver.com
