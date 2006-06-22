From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'upstream' branch
Date: Fri, 23 Jun 2006 01:20:48 +0200
Message-ID: <20060622232048.GA9790@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roy Marples <uberlord@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:15299 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750779AbWFVXV5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 19:21:57 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'upstream' to get the change below:

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

Patch applies to jeff#upstream, jeff#upstream-fixes and jeff#upstream-linus.

Shortlog
--------

Roy Marples:
      via-velocity: the link is not correctly detected when the device starts
    
Patch
-----

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 2eb6b5f..09e05fe 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -248,6 +248,7 @@ static void velocity_free_rd_ring(struct
 static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *);
 static int velocity_soft_reset(struct velocity_info *vptr);
 static void mii_init(struct velocity_info *vptr, u32 mii_status);
+static u32 velocity_get_link(struct net_device *dev);
 static u32 velocity_get_opt_media_mode(struct velocity_info *vptr);
 static void velocity_print_link_status(struct velocity_info *vptr);
 static void safe_disable_mii_autopoll(struct mac_regs __iomem * regs);
@@ -798,6 +799,9 @@ #endif
 	if (ret < 0)
 		goto err_iounmap;
 
+	if (velocity_get_link(dev))
+		netif_carrier_off(dev);
+
 	velocity_print_info(vptr);
 	pci_set_drvdata(pdev, dev);
 	
@@ -1653,8 +1657,10 @@ static void velocity_error(struct veloci
 
 		if (linked) {
 			vptr->mii_status &= ~VELOCITY_LINK_FAIL;
+			netif_carrier_on(vptr->dev);
 		} else {
 			vptr->mii_status |= VELOCITY_LINK_FAIL;
+			netif_carrier_off(vptr->dev);
 		}
 
 		velocity_print_link_status(vptr);
