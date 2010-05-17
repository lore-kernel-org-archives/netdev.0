From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] bridge: fix build for CONFIG_SYSFS disabled
Date: Mon, 17 May 2010 09:17:56 -0700
Message-ID: <20100517091756.e232bdc2.randy.dunlap@oracle.com>
References: <20100517163521.649526d0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100517163521.649526d0.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build when CONFIG_SYSFS is not enabled:

net/bridge/br_if.c:136: error: 'struct net_bridge_port' has no member named 'sysfs_name'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/bridge/br_if.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20100517.orig/net/bridge/br_if.c
+++ linux-next-20100517/net/bridge/br_if.c
@@ -133,7 +133,9 @@ static void del_nbp(struct net_bridge_po
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
+#ifdef CONFIG_SYSFS
 	sysfs_remove_link(br->ifobj, p->sysfs_name);
+#endif
 
 	dev_set_promiscuity(dev, -1);
 
