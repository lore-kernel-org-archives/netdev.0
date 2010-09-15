From: Brandon Philips <bphilips@suse.de>
Subject: [PATCH] net: enable GRO by default for vlan devices
Date: Wed, 15 Sep 2010 12:24:24 -0700
Message-ID: <20100915192424.GE4191@mmm.home.ifup.org>
References: <20100914.213544.112598547.davem@davemloft.net>
	<20100915163749.GA4191@mmm.home.ifup.org>
	<1284570520.2462.5.camel@edumazet-laptop>
	<20100915.101418.59680213.davem@davemloft.net>
	<1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Currently vlan devices don't have GRO by default as none of the Ethernet
drivers add NETIF_F_GRO to their vlan_features.

As GRO is a software feature add GRO to dev->vlan_features in
register_netdevice() and let vlan_dev_init() take care that it gets
enabled only when dev->features has NETIF_F_GRO too.

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 net/core/dev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fc2dc93..e7a6bff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5057,6 +5057,11 @@ int register_netdevice(struct net_device *dev)
 	if (dev->features & NETIF_F_SG)
 		dev->features |= NETIF_F_GSO;
 
+	/* Enable GRO for vlans by default if dev->features has GRO also. 
+	 * vlan_dev_init() will do the dev->features check.
+	 */
+	dev->vlan_features |= NETIF_F_GRO;
+
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
 	if (ret)
-- 
1.7.1


------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
