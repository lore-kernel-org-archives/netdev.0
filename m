From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/6] drivers/net/e1000 - Convert u_int64_t to
	u64
Date: Tue, 18 Mar 2008 09:13:47 -0700
Message-ID: <84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, Jeb Cramer <cramerj@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
In-Reply-To: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
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
 drivers/net/e1000/e1000.h         |   16 ++--
 drivers/net/e1000/e1000_ethtool.c |   28 ++++----
 drivers/net/e1000/e1000_hw.c      |    2 +-
 drivers/net/e1000/e1000_hw.h      |  138 ++++++++++++++++++------------------
 drivers/net/e1000/e1000_main.c    |    4 +-
 5 files changed, 94 insertions(+), 94 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index c92bc65..31feae1 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -167,7 +167,7 @@ struct e1000_buffer {
 
 
 struct e1000_ps_page { struct page *ps_page[PS_PAGE_BUFFERS]; };
-struct e1000_ps_page_dma { uint64_t ps_page_dma[PS_PAGE_BUFFERS]; };
+struct e1000_ps_page_dma { u64 ps_page_dma[PS_PAGE_BUFFERS]; };
 
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
@@ -273,9 +273,9 @@ struct e1000_adapter {
 	u32 tx_int_delay;
 	u32 tx_abs_int_delay;
 	u32 gotcl;
-	uint64_t gotcl_old;
-	uint64_t tpt_old;
-	uint64_t colc_old;
+	u64 gotcl_old;
+	u64 tpt_old;
+	u64 colc_old;
 	u32 tx_timeout_count;
 	u32 tx_fifo_head;
 	u32 tx_head_addr;
@@ -305,16 +305,16 @@ struct e1000_adapter {
 	int num_tx_queues;
 	int num_rx_queues;
 
-	uint64_t hw_csum_err;
-	uint64_t hw_csum_good;
-	uint64_t rx_hdr_split;
+	u64 hw_csum_err;
+	u64 hw_csum_good;
+	u64 rx_hdr_split;
 	u32 alloc_rx_buff_failed;
 	u32 rx_int_delay;
 	u32 rx_abs_int_delay;
 	bool rx_csum;
 	unsigned int rx_ps_pages;
 	u32 gorcl;
-	uint64_t gorcl_old;
+	u64 gorcl_old;
 	u16 rx_ps_bsize0;
 
 
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 11bbd50..701531e 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -728,7 +728,7 @@ err_setup:
 	return err;
 }
 
-static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
+static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 			     int reg, u32 mask, u32 write)
 {
 	static const u32 test[] =
@@ -751,7 +751,7 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
 	return false;
 }
 
-static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
+static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 			      int reg, u32 mask, u32 write)
 {
 	u8 __iomem *address = adapter->hw.hw_addr + reg;
@@ -788,7 +788,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
 	} while (0)
 
 static int
-e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 {
 	u32 value, before, after;
 	u32 i, toggle;
@@ -884,7 +884,7 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 }
 
 static int
-e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 {
 	u16 temp;
 	u16 checksum = 0;
@@ -919,7 +919,7 @@ e1000_test_intr(int irq, void *data)
 }
 
 static int
-e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 mask, i = 0;
@@ -1096,8 +1096,8 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
 	E1000_WRITE_REG(&adapter->hw, TDBAL,
-			((uint64_t) txdr->dma & 0x00000000FFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, TDBAH, ((uint64_t) txdr->dma >> 32));
+			((u64) txdr->dma & 0x00000000FFFFFFFF));
+	E1000_WRITE_REG(&adapter->hw, TDBAH, ((u64) txdr->dma >> 32));
 	E1000_WRITE_REG(&adapter->hw, TDLEN,
 			txdr->count * sizeof(struct e1000_tx_desc));
 	E1000_WRITE_REG(&adapter->hw, TDH, 0);
@@ -1153,8 +1153,8 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rctl = E1000_READ_REG(&adapter->hw, RCTL);
 	E1000_WRITE_REG(&adapter->hw, RCTL, rctl & ~E1000_RCTL_EN);
 	E1000_WRITE_REG(&adapter->hw, RDBAL,
-			((uint64_t) rxdr->dma & 0xFFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, RDBAH, ((uint64_t) rxdr->dma >> 32));
+			((u64) rxdr->dma & 0xFFFFFFFF));
+	E1000_WRITE_REG(&adapter->hw, RDBAH, ((u64) rxdr->dma >> 32));
 	E1000_WRITE_REG(&adapter->hw, RDLEN, rxdr->size);
 	E1000_WRITE_REG(&adapter->hw, RDH, 0);
 	E1000_WRITE_REG(&adapter->hw, RDT, 0);
@@ -1578,7 +1578,7 @@ e1000_run_loopback_test(struct e1000_adapter *adapter)
 }
 
 static int
-e1000_loopback_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
 	/* PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active */
@@ -1603,7 +1603,7 @@ out:
 }
 
 static int
-e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 {
 	*data = 0;
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
@@ -1647,7 +1647,7 @@ e1000_get_sset_count(struct net_device *netdev, int sset)
 
 static void
 e1000_diag_test(struct net_device *netdev,
-		   struct ethtool_test *eth_test, uint64_t *data)
+		   struct ethtool_test *eth_test, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	bool if_running = netif_running(netdev);
@@ -1927,7 +1927,7 @@ e1000_nway_reset(struct net_device *netdev)
 
 static void
 e1000_get_ethtool_stats(struct net_device *netdev,
-		struct ethtool_stats *stats, uint64_t *data)
+		struct ethtool_stats *stats, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -1936,7 +1936,7 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		char *p = (char *)adapter+e1000_gstrings_stats[i].stat_offset;
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(u32 *)p;
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 33bdd62..5d6c624 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -6498,7 +6498,7 @@ e1000_tbi_adjust_stats(struct e1000_hw *hw,
                        u32 frame_len,
                        u8 *mac_addr)
 {
-    uint64_t carry_bit;
+    u64 carry_bit;
 
     /* First adjust the frame length. */
     frame_len--;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 2cf3d99..696e8cb 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1309,75 +1309,75 @@ struct e1000_ffvt_entry {
 
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
-	uint64_t		crcerrs;
-	uint64_t		algnerrc;
-	uint64_t		symerrs;
-	uint64_t		rxerrc;
-	uint64_t		txerrc;
-	uint64_t		mpc;
-	uint64_t		scc;
-	uint64_t		ecol;
-	uint64_t		mcc;
-	uint64_t		latecol;
-	uint64_t		colc;
-	uint64_t		dc;
-	uint64_t		tncrs;
-	uint64_t		sec;
-	uint64_t		cexterr;
-	uint64_t		rlec;
-	uint64_t		xonrxc;
-	uint64_t		xontxc;
-	uint64_t		xoffrxc;
-	uint64_t		xofftxc;
-	uint64_t		fcruc;
-	uint64_t		prc64;
-	uint64_t		prc127;
-	uint64_t		prc255;
-	uint64_t		prc511;
-	uint64_t		prc1023;
-	uint64_t		prc1522;
-	uint64_t		gprc;
-	uint64_t		bprc;
-	uint64_t		mprc;
-	uint64_t		gptc;
-	uint64_t		gorcl;
-	uint64_t		gorch;
-	uint64_t		gotcl;
-	uint64_t		gotch;
-	uint64_t		rnbc;
-	uint64_t		ruc;
-	uint64_t		rfc;
-	uint64_t		roc;
-	uint64_t		rlerrc;
-	uint64_t		rjc;
-	uint64_t		mgprc;
-	uint64_t		mgpdc;
-	uint64_t		mgptc;
-	uint64_t		torl;
-	uint64_t		torh;
-	uint64_t		totl;
-	uint64_t		toth;
-	uint64_t		tpr;
-	uint64_t		tpt;
-	uint64_t		ptc64;
-	uint64_t		ptc127;
-	uint64_t		ptc255;
-	uint64_t		ptc511;
-	uint64_t		ptc1023;
-	uint64_t		ptc1522;
-	uint64_t		mptc;
-	uint64_t		bptc;
-	uint64_t		tsctc;
-	uint64_t		tsctfc;
-	uint64_t		iac;
-	uint64_t		icrxptc;
-	uint64_t		icrxatc;
-	uint64_t		ictxptc;
-	uint64_t		ictxatc;
-	uint64_t		ictxqec;
-	uint64_t		ictxqmtc;
-	uint64_t		icrxdmtc;
-	uint64_t		icrxoc;
+	u64		crcerrs;
+	u64		algnerrc;
+	u64		symerrs;
+	u64		rxerrc;
+	u64		txerrc;
+	u64		mpc;
+	u64		scc;
+	u64		ecol;
+	u64		mcc;
+	u64		latecol;
+	u64		colc;
+	u64		dc;
+	u64		tncrs;
+	u64		sec;
+	u64		cexterr;
+	u64		rlec;
+	u64		xonrxc;
+	u64		xontxc;
+	u64		xoffrxc;
+	u64		xofftxc;
+	u64		fcruc;
+	u64		prc64;
+	u64		prc127;
+	u64		prc255;
+	u64		prc511;
+	u64		prc1023;
+	u64		prc1522;
+	u64		gprc;
+	u64		bprc;
+	u64		mprc;
+	u64		gptc;
+	u64		gorcl;
+	u64		gorch;
+	u64		gotcl;
+	u64		gotch;
+	u64		rnbc;
+	u64		ruc;
+	u64		rfc;
+	u64		roc;
+	u64		rlerrc;
+	u64		rjc;
+	u64		mgprc;
+	u64		mgpdc;
+	u64		mgptc;
+	u64		torl;
+	u64		torh;
+	u64		totl;
+	u64		toth;
+	u64		tpr;
+	u64		tpt;
+	u64		ptc64;
+	u64		ptc127;
+	u64		ptc255;
+	u64		ptc511;
+	u64		ptc1023;
+	u64		ptc1522;
+	u64		mptc;
+	u64		bptc;
+	u64		tsctc;
+	u64		tsctfc;
+	u64		iac;
+	u64		icrxptc;
+	u64		icrxatc;
+	u64		ictxptc;
+	u64		ictxatc;
+	u64		ictxqec;
+	u64		ictxqmtc;
+	u64		icrxdmtc;
+	u64		icrxoc;
 };
 
 /* Structure containing variables used by the shared code (e1000_hw.c) */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 93e0700..04a7f71 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1702,7 +1702,7 @@ e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
 static void
 e1000_configure_tx(struct e1000_adapter *adapter)
 {
-	uint64_t tdba;
+	u64 tdba;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tdlen, tctl, tipg, tarc;
 	u32 ipgr1, ipgr2;
@@ -2065,7 +2065,7 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 static void
 e1000_configure_rx(struct e1000_adapter *adapter)
 {
-	uint64_t rdba;
+	u64 rdba;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rdlen, rctl, rxcsum, ctrl_ext;
 
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
