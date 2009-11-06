From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] decnet: netdevice refcount leak
Date: Fri, 06 Nov 2009 09:43:31 +0100
Message-ID: <4AF3E1B3.8070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59967 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbZKFIn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 03:43:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, if you accept the following patch for net-2.6, it would help me
if you also can pull it in net-next-2.6

Thanks

[PATCH] decnet: netdevice refcount leak

While working on device refcount stuff, I found a device refcount leak
through DECNET.
This nasty bug can be used to hold refcounts on any !DECNET netdevice.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/decnet/sysctl_net_decnet.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 26b0ab1..2036568 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -263,11 +263,10 @@ static int dn_def_dev_strategy(ctl_table *table,
 			return -ENODEV;
 
 		rv = -ENODEV;
-		if (dev->dn_ptr != NULL) {
+		if (dev->dn_ptr != NULL)
 			rv = dn_dev_set_default(dev, 1);
-			if (rv)
-				dev_put(dev);
-		}
+		if (rv)
+			dev_put(dev);
 	}
 
 	return rv;
