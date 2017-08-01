From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 7/7] ipvlan: Fix 64-bit statistics seqcount initialization
Date: Tue,  1 Aug 2017 12:11:13 -0700
Message-ID: <20170801191113.8754-9-f.fainelli@gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Gao Feng <fgao@ikuai8.com>, David Ahern <dsahern@gmail.com>,
        Matthias Schiffer <mschiffer@universe-factory.net>,
        Krister Johansen <kjlx@templeofstupid.com>,
        Florian Westphal <fw@strlen.de>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
lockdep splat indicating this seqcount is not correctly initialized, fix
that by using the proper helper function: netdev_alloc_pcpu_stats().

Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f37e3c1fd4e7..8dab74a81303 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -192,7 +192,7 @@ static int ipvlan_init(struct net_device *dev)
 
 	netdev_lockdep_set_classes(dev);
 
-	ipvlan->pcpu_stats = alloc_percpu(struct ipvl_pcpu_stats);
+	ipvlan->pcpu_stats = netdev_alloc_pcpu_stats(struct ipvl_pcpu_stats);
 	if (!ipvlan->pcpu_stats)
 		return -ENOMEM;
 
-- 
2.9.3
