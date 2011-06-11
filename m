From: Dan Carpenter <error27@gmail.com>
Subject: [patch] netpoll: call dev_put() on error in netpoll_setup()
Date: Sat, 11 Jun 2011 18:50:47 +0300
Message-ID: <20110611155047.GA3583@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: WANG Cong <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:40533 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758690Ab1FKPv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 11:51:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a dev_put(ndev) missing on an error path.  This was
introduced in 0c1ad04aecb "netpoll: prevent netpoll setup on slave
devices".

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
This is a static checker bug, and it's possible I've misunderstood
something.

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 42ea4b0..18d9cbd 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -795,7 +795,8 @@ int netpoll_setup(struct netpoll *np)
 	if (ndev->master) {
 		printk(KERN_ERR "%s: %s is a slave device, aborting.\n",
 		       np->name, np->dev_name);
-		return -EBUSY;
+		err = -EBUSY;
+		goto put;
 	}
 
 	if (!netif_running(ndev)) {
