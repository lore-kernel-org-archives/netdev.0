From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv6: remove useless test in dev_forward_change()
Date: Mon, 29 Oct 2012 10:24:09 +0100
Message-ID: <1351502649-3876-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20121029015709.GA18567@localhost>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40709 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab2J2JOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 05:14:33 -0400
In-Reply-To: <20121029015709.GA18567@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

idev->dev cannot be NULL.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..c9b1cf3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -607,7 +607,7 @@ static void dev_forward_change(struct inet6_dev *idev)
 	dev = idev->dev;
 	if (idev->cnf.forwarding)
 		dev_disable_lro(dev);
-	if (dev && (dev->flags & IFF_MULTICAST)) {
+	if (dev->flags & IFF_MULTICAST) {
 		if (idev->cnf.forwarding)
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 		else
-- 
1.7.12
