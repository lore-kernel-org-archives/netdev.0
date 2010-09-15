From: Brandon Philips <bphilips@suse.de>
Subject: [PATCH] ixgbe: add GRO to vlan_features
Date: Tue, 14 Sep 2010 18:50:53 -0700
Message-ID: <20100915015052.GA6602@mmm.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmo
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When running a vlan -> bridge -> domU setup I was noticing poor RX
performance. It seems ixgbe and other drivers don't have NETIF_F_GRO set
in vlan_features and thus GRO is off by default for vlans.

I see no reason why the other drivers shouldn't be fixed. If this is OK
I will go off and fix the rest.

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/net/ixgbe/ixgbe_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d03eef9..0b39757 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6817,6 +6817,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_IP_CSUM;
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
+	netdev->vlan_features |= NETIF_F_GRO;
 
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
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
