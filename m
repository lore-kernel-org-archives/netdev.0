From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: stop Features changed message
Date: Fri, 20 May 2011 09:02:08 -0700
Message-ID: <20110520090208.7709bec3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52414 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934147Ab1ETQCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 12:02:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new in 2.6.39 message "Features changed:" occurs a lot
on many configurations. It provides information to driver developers
but is not user friendly. Printing out hex values is just confusing.
Reduce priority so that it doesn't show up unless debugging.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2011-05-20 08:59:40.248885114 -0700
+++ b/net/core/dev.c	2011-05-20 09:00:32.925437770 -0700
@@ -5258,7 +5258,7 @@ void netdev_update_features(struct net_d
 	if (dev->features == features)
 		return;
 
-	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
+	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
 		dev->features, features);
 
 	if (dev->netdev_ops->ndo_set_features)
