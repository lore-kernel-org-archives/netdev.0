From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/10] drivers/net/ixgb - Convert u_int64_t to
	u64
Date: Tue, 18 Mar 2008 09:13:53 -0700
Message-ID: <0aca1d064826976cd13e5c8bde3ebdfb182805c2.1205779120.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
	<1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
	<c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
	<cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
	<ce1830668a3c8a8d63f514ba26dae26dbf71f1f2.1205779120.git.joe@perches.com>
	<45f493409623e31dc2395ecd86d46ada7f077642.1205779120.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <45f493409623e31dc2395ecd86d46ada7f077642.1205779120.git.joe@perches.com>
In-Reply-To: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
References: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgb/ixgb.h         |    8 +-
 drivers/net/ixgb/ixgb_ethtool.c |    4 +-
 drivers/net/ixgb/ixgb_hw.h      |  120 +++++++++++++++++++-------------------
 drivers/net/ixgb/ixgb_main.c    |    4 +-
 4 files changed, 68 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index c1ec56c..16f9c75 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -168,8 +168,8 @@ struct ixgb_adapter {
 	unsigned int restart_queue;
 	unsigned long timeo_start;
 	u32 tx_cmd_type;
-	uint64_t hw_csum_tx_good;
-	uint64_t hw_csum_tx_error;
+	u64 hw_csum_tx_good;
+	u64 hw_csum_tx_error;
 	u32 tx_int_delay;
 	u32 tx_timeout_count;
 	bool tx_int_delay_enable;
@@ -177,8 +177,8 @@ struct ixgb_adapter {
 
 	/* RX */
 	struct ixgb_desc_ring rx_ring;
-	uint64_t hw_csum_rx_error;
-	uint64_t hw_csum_rx_good;
+	u64 hw_csum_rx_error;
+	u64 hw_csum_rx_good;
 	u32 rx_int_delay;
 	bool rx_csum;
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index cfdfa1c..8464d8a 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -660,7 +660,7 @@ ixgb_get_sset_count(struct net_device *netdev, int sset)
 
 static void 
 ixgb_get_ethtool_stats(struct net_device *netdev, 
-		struct ethtool_stats *stats, uint64_t *data)
+		struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -669,7 +669,7 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 	for(i = 0; i < IXGB_STATS_LEN; i++) {
 		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
 		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(u32 *)p;
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 }
 
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index f31cba0..39cfa47 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -720,66 +720,66 @@ struct ixgb_hw {
 
 /* Statistics reported by the hardware */
 struct ixgb_hw_stats {
-	uint64_t tprl;
-	uint64_t tprh;
-	uint64_t gprcl;
-	uint64_t gprch;
-	uint64_t bprcl;
-	uint64_t bprch;
-	uint64_t mprcl;
-	uint64_t mprch;
-	uint64_t uprcl;
-	uint64_t uprch;
-	uint64_t vprcl;
-	uint64_t vprch;
-	uint64_t jprcl;
-	uint64_t jprch;
-	uint64_t gorcl;
-	uint64_t gorch;
-	uint64_t torl;
-	uint64_t torh;
-	uint64_t rnbc;
-	uint64_t ruc;
-	uint64_t roc;
-	uint64_t rlec;
-	uint64_t crcerrs;
-	uint64_t icbc;
-	uint64_t ecbc;
-	uint64_t mpc;
-	uint64_t tptl;
-	uint64_t tpth;
-	uint64_t gptcl;
-	uint64_t gptch;
-	uint64_t bptcl;
-	uint64_t bptch;
-	uint64_t mptcl;
-	uint64_t mptch;
-	uint64_t uptcl;
-	uint64_t uptch;
-	uint64_t vptcl;
-	uint64_t vptch;
-	uint64_t jptcl;
-	uint64_t jptch;
-	uint64_t gotcl;
-	uint64_t gotch;
-	uint64_t totl;
-	uint64_t toth;
-	uint64_t dc;
-	uint64_t plt64c;
-	uint64_t tsctc;
-	uint64_t tsctfc;
-	uint64_t ibic;
-	uint64_t rfc;
-	uint64_t lfc;
-	uint64_t pfrc;
-	uint64_t pftc;
-	uint64_t mcfrc;
-	uint64_t mcftc;
-	uint64_t xonrxc;
-	uint64_t xontxc;
-	uint64_t xoffrxc;
-	uint64_t xofftxc;
-	uint64_t rjc;
+	u64 tprl;
+	u64 tprh;
+	u64 gprcl;
+	u64 gprch;
+	u64 bprcl;
+	u64 bprch;
+	u64 mprcl;
+	u64 mprch;
+	u64 uprcl;
+	u64 uprch;
+	u64 vprcl;
+	u64 vprch;
+	u64 jprcl;
+	u64 jprch;
+	u64 gorcl;
+	u64 gorch;
+	u64 torl;
+	u64 torh;
+	u64 rnbc;
+	u64 ruc;
+	u64 roc;
+	u64 rlec;
+	u64 crcerrs;
+	u64 icbc;
+	u64 ecbc;
+	u64 mpc;
+	u64 tptl;
+	u64 tpth;
+	u64 gptcl;
+	u64 gptch;
+	u64 bptcl;
+	u64 bptch;
+	u64 mptcl;
+	u64 mptch;
+	u64 uptcl;
+	u64 uptch;
+	u64 vptcl;
+	u64 vptch;
+	u64 jptcl;
+	u64 jptch;
+	u64 gotcl;
+	u64 gotch;
+	u64 totl;
+	u64 toth;
+	u64 dc;
+	u64 plt64c;
+	u64 tsctc;
+	u64 tsctfc;
+	u64 ibic;
+	u64 rfc;
+	u64 lfc;
+	u64 pfrc;
+	u64 pftc;
+	u64 mcfrc;
+	u64 mcftc;
+	u64 xonrxc;
+	u64 xontxc;
+	u64 xoffrxc;
+	u64 xofftxc;
+	u64 rjc;
 };
 
 /* Function Prototypes */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e99b855..cb8dadd 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -718,7 +718,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 static void
 ixgb_configure_tx(struct ixgb_adapter *adapter)
 {
-	uint64_t tdba = adapter->tx_ring.dma;
+	u64 tdba = adapter->tx_ring.dma;
 	u32 tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
 	u32 tctl;
 	struct ixgb_hw *hw = &adapter->hw;
@@ -841,7 +841,7 @@ ixgb_setup_rctl(struct ixgb_adapter *adapter)
 static void
 ixgb_configure_rx(struct ixgb_adapter *adapter)
 {
-	uint64_t rdba = adapter->rx_ring.dma;
+	u64 rdba = adapter->rx_ring.dma;
 	u32 rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
 	struct ixgb_hw *hw = &adapter->hw;
 	u32 rctl;
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
