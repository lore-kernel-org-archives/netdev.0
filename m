From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Correct out of sequence initialization step for bcm43xx-softmac
Date: Mon, 11 Sep 2006 14:36:35 -0500
Message-ID: <4505BAC3.2020406@lwfinger.net>
References: <44E9C6A0.3090107@lwfinger.net> <200608211653.01997.mb@bu3sch.de> <20060911182857.GA19326@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406010504030707090400"
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:64963 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964952AbWIKTgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 15:36:39 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060911182857.GA19326@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070406010504030707090400
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

John,

Please apply the following patch to wireless-2.6. It addresses Michael 
Buesch's comments, which I seem to have missed, regarding the previous 
patch entitled "bcm43xx-softmac: Init, shutdown and restart fixes".

My copy of the wireless-2.6 indicates that the original patch has 
already been applied, thus this one only moves the call to 
bcm43xx_periodic_tasks_setup.

Larry

===============================

This patch fixes an out of sequence step in the bcm43xx_init_board 
routine for bcm43xx-softmac.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3540,13 +3540,13 @@ static int bcm43xx_init_board(struct bcm
  	if (err)
  		goto err_crystal_off;

-	bcm43xx_periodic_tasks_setup(bcm);
  	err = bcm43xx_sysfs_register(bcm);
  	if (err)
  		goto err_wlshutdown;
  	err = bcm43xx_rng_init(bcm);
  	if (err)
  		goto err_sysfs_unreg;
+	bcm43xx_periodic_tasks_setup(bcm);

  	/*FIXME: This should be handled by softmac instead. */
  	schedule_work(&bcm->softmac->associnfo.work);


--------------070406010504030707090400
Content-Type: text/plain;
 name="patch_rng_init"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_rng_init"

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3540,13 +3540,13 @@ static int bcm43xx_init_board(struct bcm
 	if (err)
 		goto err_crystal_off;
 
-	bcm43xx_periodic_tasks_setup(bcm);
 	err = bcm43xx_sysfs_register(bcm);
 	if (err)
 		goto err_wlshutdown;
 	err = bcm43xx_rng_init(bcm);
 	if (err)
 		goto err_sysfs_unreg;
+	bcm43xx_periodic_tasks_setup(bcm);
 
 	/*FIXME: This should be handled by softmac instead. */
 	schedule_work(&bcm->softmac->associnfo.work);


--------------070406010504030707090400--
