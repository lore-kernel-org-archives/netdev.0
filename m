From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Associate on 'ifconfig up'
Date: Sat, 06 May 2006 19:24:08 +0100
Message-ID: <1146939849.2503.108.camel@shinybook.infradead.org>
References: <1146847107.2766.13.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56730 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751074AbWEFSYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 14:24:19 -0400
To: bcm43xx-dev@lists.berlios.de
In-Reply-To: <1146847107.2766.13.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-05 at 17:38 +0100, David Woodhouse wrote:
> I still need this hack to work around the fact that softmac doesn't
> attempt to associate when we bring the device up...

It'd be quite good to get this fixed in 2.6.17 too. Otherwise, the
device doesn't manage to associate if you use the fairly common sequence
of iwconfig then dhclient.

It's a bit of an evil hack and it should really be fixed in softmac --
but it's only moving an _existing_ hack from one place in the driver to
another.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

--- linux-2.6.16.ppc/drivers/net/wireless/bcm43xx/bcm43xx_main.c.orig	2006-05-05 17:14:26.000000000 +0100
+++ linux-2.6.16.ppc/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 17:15:19.000000000 +0100
@@ -3263,6 +3263,9 @@ static int bcm43xx_init_board(struct bcm
 	bcm43xx_sysfs_register(bcm);
 	//FIXME: check for bcm43xx_sysfs_register failure. This function is a bit messy regarding unwinding, though...
 
+	/*FIXME: This should be handled by softmac instead. */
+	schedule_work(&bcm->softmac->associnfo.work);
+
 	assert(err == 0);
 out:
 	return err;
@@ -3937,9 +3940,6 @@ static int bcm43xx_resume(struct pci_dev
 
 	netif_device_attach(net_dev);
 	
-	/*FIXME: This should be handled by softmac instead. */
-	schedule_work(&bcm->softmac->associnfo.work);
-
 	dprintk(KERN_INFO PFX "Device resumed.\n");
 
 	return 0;

-- 
dwmw2

