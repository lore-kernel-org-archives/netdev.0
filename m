From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 05/20] net: Simplify loopback and improve batching.
Date: Mon, 30 Nov 2009 00:25:29 -0800
Message-ID: <1259569530-30609-4-git-send-email-ebiederm@xmission.com>
References: <m1ljhodbtw.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36910 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbZK3IZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 03:25:34 -0500
In-Reply-To: <m1ljhodbtw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Defer calling unregister_netdevice_queue to cleanup_net.  It's simpler
and it allows the loopback device to land in the same batch as other
network devices.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/loopback.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c9f6557..eae4ad7 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -212,15 +212,7 @@ out:
 	return err;
 }
 
-static __net_exit void loopback_net_exit(struct net *net)
-{
-	struct net_device *dev = net->loopback_dev;
-
-	unregister_netdev(dev);
-}
-
 /* Registered in net/core/dev.c */
 struct pernet_operations __net_initdata loopback_net_ops = {
        .init = loopback_net_init,
-       .exit = loopback_net_exit,
 };
-- 
1.6.5.2.143.g8cc62

