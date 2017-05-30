From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/6] net: dsa: remove dsa_uses_tagged_protocol
Date: Tue, 30 May 2017 14:33:16 -0400
Message-ID: <20170530183319.10718-4-vivien.didelot@savoirfairelinux.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since dev->dsa_ptr is a pointer to a dsa_switch_tree, there is no need
to have another inline helper just to check rcv.

Remove dsa_uses_tagged_protocol and check dsa_ptr && dsa_ptr->rcv
together at the same time.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 58297e4c6b31..4675b52c964c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -467,16 +467,10 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
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
