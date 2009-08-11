From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] libertas: name the network device wlan%d
Date: Tue, 11 Aug 2009 17:33:54 +0200
Message-ID: <20090811153354.GQ19257@buzzloop.caiaq.de>
References: <1250000012-25673-1-git-send-email-daniel@caiaq.de> <20090811151051.GA18186@guralp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roel Kluin <roel.kluin@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: libertas-dev@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:41979 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbZHKPeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 11:34:02 -0400
Content-Disposition: inline
In-Reply-To: <20090811151051.GA18186@guralp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2009 at 04:10:51PM +0100, Bob Dunlop wrote:
> On Tue, Aug 11 at 04:13, Daniel Mack wrote:
> > Devices created by the libertas driver are currently called eth%d. Which
> > is wrong, because the device does not at all have anything to do with
> > Ethernet. And it is also confusing when used on devices with more than
> > one network device.
> > 
> > Fix this by calling it wlan%d.
> 
> Just a nit pick but shouldn't the patch also include:
> 
> @@ -1176,7 +1176,7 @@
>  	/* Allocate an Ethernet device and register it */
>  	dev = alloc_etherdev(sizeof(struct lbs_private));
>  	if (!dev) {
> -		lbs_pr_err("init ethX device failed\n");
> +		lbs_pr_err("init wlanX device failed\n");
>  		goto done;
>  	}
>  	priv = netdev_priv(dev);
> 
> 
> So collars and cuffs match.

Oh, of course.

Thanks,
Daniel

>From 63ace51c76ef513553f4b30da80603f1f81114d0 Mon Sep 17 00:00:00 2001
From: Daniel Mack <daniel@caiaq.de>
Date: Tue, 11 Aug 2009 16:09:34 +0200
Subject: [PATCH] libertas: name the network device wlan%d

Devices created by the libertas driver are currently called eth%d. Which
is wrong, because the device does not at all have anything to do with
Ethernet. And it is also confusing when used on devices with more than
one network device.

Fix this by calling it wlan%d.

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: Roel Kluin <roel.kluin@gmail.com>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/libertas/main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 89575e4..8df1cfd 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1176,7 +1176,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 	/* Allocate an Ethernet device and register it */
 	dev = alloc_etherdev(sizeof(struct lbs_private));
 	if (!dev) {
-		lbs_pr_err("init ethX device failed\n");
+		lbs_pr_err("init wlanX device failed\n");
 		goto done;
 	}
 	priv = netdev_priv(dev);
@@ -1204,6 +1204,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 	SET_NETDEV_DEV(dev, dmdev);
 
 	priv->rtap_net_dev = NULL;
+	strcpy(dev->name, "wlan%d");
 
 	lbs_deb_thread("Starting main thread...\n");
 	init_waitqueue_head(&priv->waitq);
-- 
1.6.3.3

