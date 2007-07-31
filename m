From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH] Get rid of dead code in net/wanrouter/wanmain.c
Date: Tue, 31 Jul 2007 22:36:36 +0200
Message-ID: <46AF9D54.6060807@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	"Netdev" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:31748 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933213AbXGaUg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 16:36:59 -0400
Received: by nf-out-0910.google.com with SMTP id g13so250160nfb
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 13:36:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

File /home/devel/linux-rdc/net/wanrouter/wanmain.c line 569
Unknown CONFIG option! CONFIG_WANPIPE_MULTPPP
File /home/devel/linux-rdc/net/wanrouter/wanmain.c line 590
Unknown CONFIG option! CONFIG_WANPIPE_MULTPPP
File /home/devel/linux-rdc/net/wanrouter/wanmain.c line 663
Unknown CONFIG option! CONFIG_WANPIPE_MULTPPP

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

--- linux-rdc-clean/net/wanrouter/wanmain.c	2007-07-09 01:32:17.000000000 +0200
+++ linux-rdc/net/wanrouter/wanmain.c	2007-07-31 18:04:58.000000000 +0200
@@ -566,9 +566,6 @@ static int wanrouter_device_new_if(struc
 {
 	wanif_conf_t *cnf;
 	struct net_device *dev = NULL;
-#ifdef CONFIG_WANPIPE_MULTPPP
-	struct ppp_device *pppdev=NULL;
-#endif
 	int err;
 
 	if ((wandev->state == WAN_UNCONFIGURED) || (wandev->new_if == NULL))
@@ -587,25 +584,10 @@ static int wanrouter_device_new_if(struc
 		goto out;
 
 	if (cnf->config_id == WANCONFIG_MPPP) {
-#ifdef CONFIG_WANPIPE_MULTPPP
-		pppdev = kzalloc(sizeof(struct ppp_device), GFP_KERNEL);
-		err = -ENOBUFS;
-		if (pppdev == NULL)
-			goto out;
-		pppdev->dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
-		if (pppdev->dev == NULL) {
-			kfree(pppdev);
-			err = -ENOBUFS;
-			goto out;
-		}
-		err = wandev->new_if(wandev, (struct net_device *)pppdev, cnf);
-		dev = pppdev->dev;
-#else
 		printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
 				wandev->name);
 		err = -EPROTONOSUPPORT;
 		goto out;
-#endif
 	} else {
 		dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
 		err = -ENOBUFS;
@@ -660,16 +642,9 @@ static int wanrouter_device_new_if(struc
 	kfree(dev->priv);
 	dev->priv = NULL;
 
-#ifdef CONFIG_WANPIPE_MULTPPP
-	if (cnf->config_id == WANCONFIG_MPPP)
-		kfree(pppdev);
-	else
-		kfree(dev);
-#else
 	/* Sync PPP is disabled */
 	if (cnf->config_id != WANCONFIG_MPPP)
 		kfree(dev);
-#endif
 
 out:
 	kfree(cnf);
