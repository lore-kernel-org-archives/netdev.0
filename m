From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] macsonic, jazzsonic - fix oops on module unload
Date: Wed, 22 Jul 2009 01:40:02 +1000 (EST)
Message-ID: <alpine.OSX.2.00.0907220119060.796@silk.local>
References: <20090711170548.GC5205@suse.de> <1247345591-22643-8-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-9-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-10-git-send-email-u.kleine-koenig@pengutronix.de>
 <1247345591-22643-11-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-12-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-13-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-14-git-send-email-u.kleine-koenig@pengutronix.de>
 <1247345591-22643-15-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-16-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-17-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-18-git-send-email-u.kleine-koenig@pengutronix.de>
 <1247345591-22643-19-git-send-email-u.kleine-koenig@pengutronix.de> <1247345591-22643-20-git-send-email-u.kleine-koenig@pengutronix.de> <alpine.OSX.2.00.0907220032230.796@silk.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, Greg KH <gregkh@suse.de>,
	=?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.telegraphics.com.au ([204.15.192.19]:53359 "EHLO
	mail.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325AbZGUPrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 11:47:52 -0400
In-Reply-To: <alpine.OSX.2.00.0907220032230.796@silk.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Set the driver data before using it. Fixes an oops when doing rmmod.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

--- a/drivers/net/macsonic.c	2009-07-22 00:47:46.000000000 +1000
+++ b/drivers/net/macsonic.c	2009-07-22 00:49:39.000000000 +1000
@@ -575,6 +575,7 @@
  	lp = netdev_priv(dev);
  	lp->device = &pdev->dev;
  	SET_NETDEV_DEV(dev, &pdev->dev);
+	platform_set_drvdata(pdev, dev);

  	/* This will catch fatal stuff like -ENOMEM as well as success */
  	err = mac_onboard_sonic_probe(dev);
--- a/drivers/net/jazzsonic.c	2009-07-22 00:47:52.000000000 +1000
+++ b/drivers/net/jazzsonic.c	2009-07-22 00:52:41.000000000 +1000
@@ -222,6 +222,7 @@
  	lp = netdev_priv(dev);
  	lp->device = &pdev->dev;
  	SET_NETDEV_DEV(dev, &pdev->dev);
+	platform_set_drvdata(pdev, dev);

  	netdev_boot_setup_check(dev);

