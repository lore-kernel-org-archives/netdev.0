From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH] net: Do not enable tx-nocache-copy by default
Date: Mon,  6 Jan 2014 18:20:19 -0500
Message-ID: <1389050419-9060-1-git-send-email-bpoirier@suse.de>
References: <1389041855.12212.210.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389041855.12212.210.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are many cases where this feature does not improve performance or even
reduces it. See the following discussion for example perf numbers:
http://thread.gmane.org/gmane.linux.network/298345

CC: Tom Herbert <therbert@google.com>
Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 net/core/dev.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 153ee2f..2e242583 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5783,13 +5783,8 @@ int register_netdevice(struct net_device *dev)
 	dev->features |= NETIF_F_SOFT_FEATURES;
 	dev->wanted_features = dev->features & dev->hw_features;
 
-	/* Turn on no cache copy if HW is doing checksum */
 	if (!(dev->flags & IFF_LOOPBACK)) {
 		dev->hw_features |= NETIF_F_NOCACHE_COPY;
-		if (dev->features & NETIF_F_ALL_CSUM) {
-			dev->wanted_features |= NETIF_F_NOCACHE_COPY;
-			dev->features |= NETIF_F_NOCACHE_COPY;
-		}
 	}
 
 	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
-- 
1.8.4
