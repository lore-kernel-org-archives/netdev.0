From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH stable] Revert "dev: set iflink to 0 for virtual interfaces"
Date: Tue, 25 Aug 2015 14:09:58 -0700
Message-ID: <20150825140958.0271ad4e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35927 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbbHYVJr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:09:47 -0400
Received: by pacgr6 with SMTP id gr6so2461604pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 14:09:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave could you include this in next update to 4.1 stable update?

>From a72f813bf1aab4dfe47e3d4ab5e2e07bbcdf2b58 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 6 Jul 2015 17:25:10 +0200
Subject: [PATCH] Revert "dev: set iflink to 0 for virtual interfaces"

commit 95ec655bc465ccb2a3329d4aff9a45e3c8188db5 upstream.
It should be applied to 4.1.y stable tree.

This reverts commit e1622baf54df8cc958bf29d71de5ad545ea7d93c.

The side effect of this commit is to add a '@NONE' after each virtual
interface name with a 'ip link'. It may break existing scripts.

Reported-by: Olivier Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index aa82f9a..8c416c99 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -672,10 +672,6 @@ int dev_get_iflink(const struct net_device *dev)
 	if (dev->netdev_ops && dev->netdev_ops->ndo_get_iflink)
 		return dev->netdev_ops->ndo_get_iflink(dev);
 
-	/* If dev->rtnl_link_ops is set, it's a virtual interface. */
-	if (dev->rtnl_link_ops)
-		return 0;
-
 	return dev->ifindex;
 }
 EXPORT_SYMBOL(dev_get_iflink);
-- 
2.1.4
