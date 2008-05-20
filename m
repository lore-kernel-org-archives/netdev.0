From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH?] Fix call to ->change_rx_flags(dev, IFF_MULTICAST) in
	dev_change_flags()
Date: Tue, 20 May 2008 13:11:26 +0100
Message-ID: <1211285486.21380.204.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50701 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761194AbYETMLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 08:11:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am I just being particularly dim today, or can the call to
dev->change_rx_flags(dev, IFF_MULTICAST) in dev_change_flags() never
happen?

We've just set dev->flags = flags & IFF_MULTICAST, effectively. So the
condition '(dev->flags ^ flags) & IFF_MULTICAST' is _never_ going to be
true.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/net/core/dev.c b/net/core/dev.c
index a1607bc..2ea3a14 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3130,14 +3130,14 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 	dev->flags = (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP |
 			       IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
 			       IFF_AUTOMEDIA)) |
 		     (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
 				    IFF_ALLMULTI));
 
 	/*
 	 *	Load in the correct multicast list now the flags have changed.
 	 */
 
-	if (dev->change_rx_flags && (dev->flags ^ flags) & IFF_MULTICAST)
+	if (dev->change_rx_flags && (old_flags ^ flags) & IFF_MULTICAST)
 		dev->change_rx_flags(dev, IFF_MULTICAST);
 
 	dev_set_rx_mode(dev);


-- 
dwmw2

