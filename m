From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 4/7] ipv6: hash is calculated but not used afterwards
Date: Fri, 25 Feb 2011 16:45:18 +0100
Message-ID: <1298648721-3026-4-git-send-email-hagen@jauu.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57599 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932367Ab1BYPx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:26 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hash is declared and assigned but not used anymore. ipv6_addr_hash()
exhibit no side-effects.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/addrconf.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fd6782e..3daaf3c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -718,12 +718,9 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	struct inet6_ifaddr *ifa, *ifn;
 	struct inet6_dev *idev = ifp->idev;
 	int state;
-	int hash;
 	int deleted = 0, onlink = 0;
 	unsigned long expires = jiffies;
 
-	hash = ipv6_addr_hash(&ifp->addr);
-
 	spin_lock_bh(&ifp->state_lock);
 	state = ifp->state;
 	ifp->state = INET6_IFADDR_STATE_DEAD;
-- 
1.7.2.3

