From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: re-expose net_device_stats to user headers
Date: Mon, 23 Aug 2010 08:32:58 -0700
Message-ID: <20100823083258.0777e83d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50041 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523Ab0HWPdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 11:33:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit broke iproute2 build:

commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Tue Jun 8 07:19:54 2010 +0000

    net: Enable 64-bit net device statistics on 32-bit architectures
    
    Use struct rtnl_link_stats64 as the statistics structure.

Iproute2 uses a the kernel exported headers, and the structure
net_device_stats which is part of the netlink IFLA_STATS message
was no longer exposed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
This patch needs to be applied to net-2.6 (2.6.36)
    

--- a/include/linux/netdevice.h	2010-08-23 08:22:17.801906612 -0700
+++ b/include/linux/netdevice.h	2010-08-23 08:25:23.502078638 -0700
@@ -165,6 +165,8 @@ static inline bool dev_xmit_complete(int
 #define MAX_HEADER (LL_MAX_HEADER + 48)
 #endif
 
+#endif  /*  __KERNEL__  */
+
 /*
  *	Old network device statistics. Fields are native words
  *	(unsigned long) so they can be read and written atomically.
@@ -196,9 +198,6 @@ struct net_device_stats {
 	unsigned long	tx_compressed;
 };
 
-#endif  /*  __KERNEL__  */
-
-
 /* Media selection options. */
 enum {
         IF_PORT_UNKNOWN = 0,
