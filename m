From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 2/5] net: dsa: do not cast dst
Date: Thu,  1 Jun 2017 16:07:12 -0400
Message-ID: <20170601200715.8438-3-vivien.didelot@savoirfairelinux.com>
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

dsa_ptr is not a void pointer anymore since Nov 2011, as of cf50dcc24f82
("dsa: Change dsa_uses_{dsa, trailer}_tags() into inline functions"),
but an explicit dsa_switch_tree pointer, thus remove the (void *) cast.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c   | 2 +-
 net/dsa/legacy.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index c0a4576db4a2..21b44a9828f6 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -454,7 +454,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dst->master_netdev->dsa_ptr = (void *)dst;
+	dst->master_netdev->dsa_ptr = dst;
 	dst->applied = true;
 
 	return 0;
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index ac4379b8d7ac..d70a1a788d17 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -651,7 +651,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dev->dsa_ptr = (void *)dst;
+	dev->dsa_ptr = dst;
 
 	return 0;
 }
-- 
2.13.0
