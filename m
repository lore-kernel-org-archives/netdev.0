From: Sven Hartge <sven@svenhartge.de>
Subject: [PATCH] via-velocity: earlier name allocation
Date: Thu, 23 Oct 2008 01:24:25 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0810230114180.17076@ds9.feds.ath.cx>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenhartge.de ([81.169.140.245]:39782 "EHLO svenhartge.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbYJVXxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 19:53:04 -0400
Received: from ds9.argh.org ([10.19.78.3])
	by svenhartge.de with esmtp (Exim 4.69)
	(envelope-from <sven@svenhartge.de>)
	id 1Ksn3y-0005sB-Vz
	for netdev@vger.kernel.org; Thu, 23 Oct 2008 01:24:27 +0200
Received: from localhost ([127.0.0.1] ident=oweh)
	by ds9.feds.ath.cx with esmtps (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <sven@svenhartge.de>)
	id 1Ksn3y-0003qi-IK
	for netdev@vger.kernel.org; Thu, 23 Oct 2008 01:24:26 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This is my first attempt at a kernel patch ever, so please be gentle :)
(And please CC me, as I am not subscribed to netdev.)

This patch corrects a cosmetic bug in the via-velocity driver which 
bothered me for some time.

The messages printed during device init look like the following:

[    8.486422] eth%d: set value of parameter Wake On Lan options to 0
                  ^^!
[    8.487340] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter

Note the unresolved format string.

I just copied and adapted the name allocation code from register_netdev 
and call it before the first use of dev->name 

Even if my attempt is incorrect, it should give you an idea what needs 
fixing here.

Signed-off-by: Sven Hartge <sven@svenhartge.de>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 2dced38..15f2c19 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -934,6 +934,16 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
+	/*
+	 *  Do name allocation.
+	 */
+
+	if (strchr(dev->name, '%')) {
+		ret = dev_alloc_name(dev, dev->name);
+			if (ret < 0)
+				dev_err(&pdev->dev, "Name allocation failed.\n");
+				goto err_disable;
+	}
 
 	velocity_get_options(&vptr->options, velocity_nics, dev->name);
 


