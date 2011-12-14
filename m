From: Jiang Wang <Jiang.Wang@riverbed.com>
Subject: [PATCH 2/2] e100: power off PHY after reset when
	interface is down
Date: Tue, 13 Dec 2011 18:49:56 -0800
Message-ID: <1323830996-16388-2-git-send-email-Jiang.Wang@riverbed.com>
References: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Francis.St.Amant@riverbed.com, miles.ito@intel.com, clala@riverbed.com,
	ppanchamukhi@riverbed.com, Jiang Wang <Jiang.Wang@riverbed.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

PHYs supported by e100 re-starts auto-negotiation after writing to
BMCR_RESET bit. This patch powers down PHY when the interface is down
and reset is issued.

Signed-off-by: Jiang Wang <Jiang.Wang@riverbed.com>
---
 drivers/net/ethernet/intel/e100.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 9824e0a..b8e4910 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2386,6 +2386,13 @@ static int e100_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	err = mii_ethtool_sset(&nic->mii, cmd);
 	e100_exec_cb(nic, NULL, e100_configure);
 
+	if (!netif_running(netdev) && !(nic->flags & wol_magic)) {
+		uint16_t phy_data;
+		phy_data = mdio_read(nic->netdev, nic->mii.phy_id, MII_BMCR);
+		phy_data |= BMCR_PDOWN;
+		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, phy_data);
+	}
+
 	return err;
 }
 
-- 
1.7.1


------------------------------------------------------------------------------
Cloud Computing - Latest Buzzword or a Glimpse of the Future?
This paper surveys cloud computing today: What are the benefits? 
Why are businesses embracing it? What are its payoffs and pitfalls?
http://www.accelacomm.com/jaw/sdnl/114/51425149/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
