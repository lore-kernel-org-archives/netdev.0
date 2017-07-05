From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 05/12] tun/tap: Remove references to NETIF_F_UFO.
Date: Wed, 05 Jul 2017 16:04:51 +0100 (WEST)
Message-ID: <20170705.160451.873219710959864045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdGEPE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:04:57 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id A3FDC126C97C5
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:04:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tap.c | 7 ++-----
 drivers/net/tun.c | 7 +------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 9af3239..d4579a3 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -943,9 +943,6 @@ static int set_offload(struct tap_queue *q, unsigned long arg)
 			if (arg & TUN_F_TSO6)
 				feature_mask |= NETIF_F_TSO6;
 		}
-
-		if (arg & TUN_F_UFO)
-			feature_mask |= NETIF_F_UFO;
 	}
 
 	/* tun/tap driver inverts the usage for TSO offloads, where
@@ -956,7 +953,7 @@ static int set_offload(struct tap_queue *q, unsigned long arg)
 	 * When user space turns off TSO, we turn off GSO/LRO so that
 	 * user-space will not receive TSO frames.
 	 */
-	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
+	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6))
 		features |= RX_OFFLOADS;
 	else
 		features &= ~RX_OFFLOADS;
@@ -1078,7 +1075,7 @@ static long tap_ioctl(struct file *file, unsigned int cmd,
 	case TUNSETOFFLOAD:
 		/* let the user check for future flags */
 		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-			    TUN_F_TSO_ECN | TUN_F_UFO))
+			    TUN_F_TSO_ECN))
 			return -EINVAL;
 
 		rtnl_lock();
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3d4c245..a93392d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -199,7 +199,7 @@ struct tun_struct {
 	struct net_device	*dev;
 	netdev_features_t	set_features;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
-			  NETIF_F_TSO6|NETIF_F_UFO)
+			  NETIF_F_TSO6)
 
 	int			align;
 	int			vnet_hdr_sz;
@@ -1921,11 +1921,6 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
 				features |= NETIF_F_TSO6;
 			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
 		}
-
-		if (arg & TUN_F_UFO) {
-			features |= NETIF_F_UFO;
-			arg &= ~TUN_F_UFO;
-		}
 	}
 
 	/* This gives the user a way to test for new features in future by
-- 
2.9.4
