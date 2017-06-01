From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 3/5] net: dsa: remove dsa_uses_tagged_protocol
Date: Thu,  1 Jun 2017 16:07:13 -0400
Message-ID: <20170601200715.8438-4-vivien.didelot@savoirfairelinux.com>
References: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since dev->dsa_ptr is a pointer to a dsa_switch_tree, there is no need
to have another inline helper just to check rcv.

Remove dsa_uses_tagged_protocol and check dsa_ptr && dsa_ptr->rcv
together at the same time.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 18ca0a935c96..448d8bc77707 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -468,16 +468,10 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 struct net_device *dsa_dev_to_net_device(struct device *dev);
 
 /* Keep inline for faster access in hot path */
-static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
-{
-	return dst->rcv != NULL;
-}
-
 static inline bool netdev_uses_dsa(struct net_device *dev)
 {
 #if IS_ENABLED(CONFIG_NET_DSA)
-	if (dev->dsa_ptr != NULL)
-		return dsa_uses_tagged_protocol(dev->dsa_ptr);
+	return dev->dsa_ptr && dev->dsa_ptr->rcv;
 #endif
 	return false;
 }
-- 
2.13.0
