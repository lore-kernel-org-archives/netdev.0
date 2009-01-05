From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/8] wireless: convert wireless ioctl to net_device_ops
Date: Mon, 05 Jan 2009 12:14:45 -0800
Message-ID: <20090105201514.442703045@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35277 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399AbZAEUY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:24:26 -0500
Content-Disposition: inline; filename=wext.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/wireless/wext.c	2009-01-05 08:40:34.045826527 -0800
+++ b/net/wireless/wext.c	2009-01-05 09:33:27.362505126 -0800
@@ -1055,8 +1055,8 @@ static int wireless_process_ioctl(struct
 			return private(dev, iwr, cmd, info, handler);
 	}
 	/* Old driver API : call driver ioctl handler */
-	if (dev->do_ioctl)
-		return dev->do_ioctl(dev, ifr, cmd);
+	if (dev->netdev_ops->ndo_do_ioctl)
+		return dev->netdev_ops->ndo_do_ioctl(dev, ifr, cmd);
 	return -EOPNOTSUPP;
 }
 

-- 

