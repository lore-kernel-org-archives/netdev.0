From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v4 13/19] net: rdma: use __ethtool_get_ksettings
Date: Wed,  9 Dec 2015 09:59:23 -0800
Message-ID: <1449683969-7305-14-git-send-email-ddecotig@gmail.com>
References: <1449683969-7305-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Eugenia Emantayev <eugenia@mellanox.co.il>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Ed Swierk <eswierk@skyportsystems.com>,
        Robert Love <robert.w.love@intel.com>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-api@vger.kernel.org, linux-mips@linux-mips.org,
        fcoe-devel@open-fcoe.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1449683969-7305-1-git-send-email-ddecotig@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/rdma/ib_addr.h | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index 1152859..1820f26 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -254,24 +254,22 @@ static inline enum ib_mtu iboe_get_mtu(int mtu)
 
 static inline int iboe_get_rate(struct net_device *dev)
 {
-	struct ethtool_cmd cmd;
-	u32 speed;
+	struct ethtool_ksettings cmd;
 	int err;
 
 	rtnl_lock();
-	err = __ethtool_get_settings(dev, &cmd);
+	err = __ethtool_get_ksettings(dev, &cmd);
 	rtnl_unlock();
 	if (err)
 		return IB_RATE_PORT_CURRENT;
 
-	speed = ethtool_cmd_speed(&cmd);
-	if (speed >= 40000)
+	if (cmd.parent.speed >= 40000)
 		return IB_RATE_40_GBPS;
-	else if (speed >= 30000)
+	else if (cmd.parent.speed >= 30000)
 		return IB_RATE_30_GBPS;
-	else if (speed >= 20000)
+	else if (cmd.parent.speed >= 20000)
 		return IB_RATE_20_GBPS;
-	else if (speed >= 10000)
+	else if (cmd.parent.speed >= 10000)
 		return IB_RATE_10_GBPS;
 	else
 		return IB_RATE_PORT_CURRENT;
-- 
2.6.0.rc2.230.g3dd15c0
