From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH] ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER
	from hw_features
Date: Tue, 10 Mar 2015 20:03:38 -0700
Message-ID: <20150311030305.1337.10832.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: h-shimamoto@ct.jp.nec.com
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This change makes it so that the HW_VLAN_STAG_FILTER bit is not falsely
advertised as being a feature that can be toggled on ixgbe parts.  The
driver was setting the bit in features and letting it be inherited by
hw_features, however the driver was actually ignoring the value of the bit
and just assuming it was always set.  As a result VLAN filtering was always
enabled which is a requirement for SR-IOV, VMDq, DCB, FCoE, and possibly
other features within the adapters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 21aea7e..08c27ed 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8406,7 +8406,6 @@ skip_sriov:
 			   NETIF_F_IPV6_CSUM |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
-			   NETIF_F_HW_VLAN_CTAG_FILTER |
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
@@ -8428,6 +8427,7 @@ skip_sriov:
 	}
 
 	netdev->hw_features |= NETIF_F_RXALL;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
