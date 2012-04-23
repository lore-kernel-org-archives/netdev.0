From: Chris Boot <bootc@bootc.net>
Subject: [PATCH 2/2] e1000e: Remove special case for
	82573/82574 ASPM L1 disablement
Date: Mon, 23 Apr 2012 22:29:38 +0100
Message-ID: <1335216578-21542-3-git-send-email-bootc@bootc.net>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nix@esperi.org.uk, Chris Boot <bootc@bootc.net>,
	linux-kernel@vger.kernel.org
To: e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335216578-21542-1-git-send-email-bootc@bootc.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

For the 82573, ASPM L1 gets disabled wholesale so this special-case code
is not required. For the 82574 the previous patch does the same as for
the 82573, disabling L1 on the adapter. Thus, this code is no longer
required and can be removed.

Signed-off-by: Chris Boot <bootc@bootc.net>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 19ab215..ea96cfd 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5293,14 +5293,6 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
-	/* 82573 Errata 17 */
-	if (((adapter->hw.mac.type == e1000_82573) ||
-	     (adapter->hw.mac.type == e1000_82574)) &&
-	    (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN)) {
-		adapter->flags2 |= FLAG2_DISABLE_ASPM_L1;
-		e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L1);
-	}
-
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
-- 
1.7.10


------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
