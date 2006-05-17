From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Wed, 17 May 2006 15:34:11 -0400
Message-ID: <20060517193405.GB17895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:32015 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751029AbWEQTef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 15:34:35 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 0c056c50a6218e0e577817c16ba8851af593d742:
  Linus Torvalds:
        Merge master.kernel.org:/.../gregkh/spi-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

David Woodhouse:
      bcm43xx: associate on 'ifconfig up'

 drivers/net/wireless/bcm43xx/bcm43xx_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index e2982a8..7ed18ca 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3271,6 +3271,9 @@ static int bcm43xx_init_board(struct bcm
 	bcm43xx_sysfs_register(bcm);
 	//FIXME: check for bcm43xx_sysfs_register failure. This function is a bit messy regarding unwinding, though...
 
+	/*FIXME: This should be handled by softmac instead. */
+	schedule_work(&bcm->softmac->associnfo.work);
+
 	assert(err == 0);
 out:
 	return err;
@@ -3946,9 +3949,6 @@ static int bcm43xx_resume(struct pci_dev
 
 	netif_device_attach(net_dev);
 	
-	/*FIXME: This should be handled by softmac instead. */
-	schedule_work(&bcm->softmac->associnfo.work);
-
 	dprintk(KERN_INFO PFX "Device resumed.\n");
 
 	return 0;
-- 
John W. Linville
linville@tuxdriver.com
