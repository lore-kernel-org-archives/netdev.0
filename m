From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/25] fm10k: fix unused warnings
Date: Tue, 14 Apr 2015 16:50:52 -0700
Message-ID: <1429055471-401-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447AbbDNXvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:19 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The were several functions which had parameters which were never or
sometimes used in functions.  To resolve possible compiler warnings,
use __always_unused or __maybe_unused kernel macros to resolve.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c   |  6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |  8 +++++---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 12 ++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |  6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 18 ++++++------------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 17 +++++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |  5 +++--
 7 files changed, 35 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c b/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
index 212a92d..5c7a4d7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -128,7 +128,7 @@ static int fm10k_dcbnl_ieee_setpfc(struct net_device *dev, struct ieee_pfc *pfc)
  *
  * Returns that we support only IEEE DCB for this interface
  **/
-static u8 fm10k_dcbnl_getdcbx(struct net_device *dev)
+static u8 fm10k_dcbnl_getdcbx(struct net_device __always_unused *dev)
 {
 	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
 }
@@ -140,7 +140,7 @@ static u8 fm10k_dcbnl_getdcbx(struct net_device *dev)
  *
  * Returns error on attempt to enable anything but IEEE DCB for this interface
  **/
-static u8 fm10k_dcbnl_setdcbx(struct net_device *dev, u8 mode)
+static u8 fm10k_dcbnl_setdcbx(struct net_device __always_unused *dev, u8 mode)
 {
 	return (mode != (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE)) ? 1 : 0;
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
index 4327f86..f45b4d7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -36,14 +36,16 @@ static void *fm10k_dbg_desc_seq_start(struct seq_file *s, loff_t *pos)
 	return (*pos < ring->count) ? pos : NULL;
 }
 
-static void *fm10k_dbg_desc_seq_next(struct seq_file *s, void *v, loff_t *pos)
+static void *fm10k_dbg_desc_seq_next(struct seq_file *s,
+				     void __always_unused *v, loff_t *pos)
 {
 	struct fm10k_ring *ring = s->private;
 
 	return (++(*pos) < ring->count) ? pos : NULL;
 }
 
-static void fm10k_dbg_desc_seq_stop(struct seq_file *s, void *v)
+static void fm10k_dbg_desc_seq_stop(struct seq_file __always_unused *s,
+				    __always_unused void *v)
 {
 	/* Do nothing. */
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 7dd3c9d..697a269 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -116,8 +116,7 @@ enum fm10k_self_test_types {
 	FM10K_TEST_MAX = FM10K_TEST_LEN
 };
 
-static void fm10k_get_strings(struct net_device *dev, u32 stringset,
-			      u8 *data)
+static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	char *p = (char *)data;
 	int i;
@@ -166,7 +165,8 @@ static int fm10k_get_sset_count(struct net_device *dev, int sset)
 }
 
 static void fm10k_get_ethtool_stats(struct net_device *netdev,
-				    struct ethtool_stats *stats, u64 *data)
+				    struct ethtool_stats __always_unused *stats,
+				    u64 *data)
 {
 	const int stat_count = sizeof(struct fm10k_queue_stats) / sizeof(u64);
 	struct fm10k_intfc *interface = netdev_priv(netdev);
@@ -644,7 +644,7 @@ static int fm10k_get_rss_hash_opts(struct fm10k_intfc *interface,
 }
 
 static int fm10k_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
-			   u32 *rule_locs)
+			   u32 __always_unused *rule_locs)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	int ret = -EOPNOTSUPP;
@@ -850,7 +850,7 @@ static void fm10k_self_test(struct net_device *dev,
 		eth_test->flags |= ETH_TEST_FL_FAILED;
 }
 
-static u32 fm10k_get_reta_size(struct net_device *netdev)
+static u32 fm10k_get_reta_size(struct net_device __always_unused *netdev)
 {
 	return FM10K_RETA_SIZE * FM10K_RETA_ENTRIES_PER_REG;
 }
@@ -910,7 +910,7 @@ static int fm10k_set_reta(struct net_device *netdev, const u32 *indir)
 	return 0;
 }
 
-static u32 fm10k_get_rssrk_size(struct net_device *netdev)
+static u32 fm10k_get_rssrk_size(struct net_device __always_unused *netdev)
 {
 	return FM10K_RSSRK_SIZE * FM10K_RSSRK_ENTRIES_PER_REG;
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index a02308f..69cbfde 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -488,8 +488,8 @@ int fm10k_ndo_set_vf_vlan(struct net_device *netdev, int vf_idx, u16 vid,
 	return 0;
 }
 
-int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int unused,
-			int rate)
+int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx,
+			int __always_unused unused, int rate)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c325bc0..e2c27ba 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -209,7 +209,7 @@ static inline bool fm10k_page_is_reserved(struct page *page)
 
 static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
 				    struct page *page,
-				    unsigned int truesize)
+				    unsigned int __maybe_unused truesize)
 {
 	/* avoid re-using remote pages */
 	if (unlikely(fm10k_page_is_reserved(page)))
@@ -240,7 +240,6 @@ static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
 
 /**
  * fm10k_add_rx_frag - Add contents of Rx buffer to sk_buff
- * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: buffer containing page to add
  * @rx_desc: descriptor containing length of buffer written by hardware
  * @skb: sk_buff to place the data into
@@ -253,8 +252,7 @@ static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
  * The function will then update the page offset if necessary and return
  * true if the buffer can be reused by the interface.
  **/
-static bool fm10k_add_rx_frag(struct fm10k_ring *rx_ring,
-			      struct fm10k_rx_buffer *rx_buffer,
+static bool fm10k_add_rx_frag(struct fm10k_rx_buffer *rx_buffer,
 			      union fm10k_rx_desc *rx_desc,
 			      struct sk_buff *skb)
 {
@@ -330,7 +328,7 @@ static struct sk_buff *fm10k_fetch_rx_buffer(struct fm10k_ring *rx_ring,
 				      DMA_FROM_DEVICE);
 
 	/* pull page into skb */
-	if (fm10k_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+	if (fm10k_add_rx_frag(rx_buffer, rx_desc, skb)) {
 		/* hand second half of page back to the ring */
 		fm10k_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
@@ -412,7 +410,7 @@ static void fm10k_rx_hwtstamp(struct fm10k_ring *rx_ring,
 }
 
 static void fm10k_type_trans(struct fm10k_ring *rx_ring,
-			     union fm10k_rx_desc *rx_desc,
+			     union fm10k_rx_desc __maybe_unused *rx_desc,
 			     struct sk_buff *skb)
 {
 	struct net_device *dev = rx_ring->netdev;
@@ -509,8 +507,6 @@ static bool fm10k_is_non_eop(struct fm10k_ring *rx_ring,
 
 /**
  * fm10k_pull_tail - fm10k specific version of skb_pull_tail
- * @rx_ring: rx descriptor ring packet is being transacted on
- * @rx_desc: pointer to the EOP Rx descriptor
  * @skb: pointer to current skb being adjusted
  *
  * This function is an fm10k specific version of __pskb_pull_tail.  The
@@ -520,9 +516,7 @@ static bool fm10k_is_non_eop(struct fm10k_ring *rx_ring,
  * As a result we can do things like drop a frag and maintain an accurate
  * truesize for the skb.
  */
-static void fm10k_pull_tail(struct fm10k_ring *rx_ring,
-			    union fm10k_rx_desc *rx_desc,
-			    struct sk_buff *skb)
+static void fm10k_pull_tail(struct sk_buff *skb)
 {
 	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
 	unsigned char *va;
@@ -576,7 +570,7 @@ static bool fm10k_cleanup_headers(struct fm10k_ring *rx_ring,
 
 	/* place header in linear portion of buffer */
 	if (skb_is_nonlinear(skb))
-		fm10k_pull_tail(rx_ring, rx_desc, skb);
+		fm10k_pull_tail(skb);
 
 	/* if eth_skb_pad returns an error the skb was freed */
 	if (eth_skb_pad(skb))
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 90d6fae..9d9dce6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -807,7 +807,7 @@ static void fm10k_napi_enable_all(struct fm10k_intfc *interface)
 	}
 }
 
-static irqreturn_t fm10k_msix_clean_rings(int irq, void *data)
+static irqreturn_t fm10k_msix_clean_rings(int __always_unused irq, void *data)
 {
 	struct fm10k_q_vector *q_vector = data;
 
@@ -817,7 +817,7 @@ static irqreturn_t fm10k_msix_clean_rings(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t fm10k_msix_mbx_vf(int irq, void *data)
+static irqreturn_t fm10k_msix_mbx_vf(int __always_unused irq, void *data)
 {
 	struct fm10k_intfc *interface = data;
 	struct fm10k_hw *hw = &interface->hw;
@@ -985,7 +985,7 @@ static void fm10k_reset_drop_on_empty(struct fm10k_intfc *interface, u32 eicr)
 	}
 }
 
-static irqreturn_t fm10k_msix_mbx_pf(int irq, void *data)
+static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 {
 	struct fm10k_intfc *interface = data;
 	struct fm10k_hw *hw = &interface->hw;
@@ -1090,7 +1090,7 @@ static s32 fm10k_mbx_mac_addr(struct fm10k_hw *hw, u32 **results,
 }
 
 static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
-			     struct fm10k_mbx_info *mbx)
+			     struct fm10k_mbx_info __always_unused *mbx)
 {
 	struct fm10k_intfc *interface;
 	u64 timestamp;
@@ -1110,7 +1110,7 @@ static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
 
 /* generic error handler for mailbox issues */
 static s32 fm10k_mbx_error(struct fm10k_hw *hw, u32 **results,
-			   struct fm10k_mbx_info *mbx)
+			   struct fm10k_mbx_info __always_unused *mbx)
 {
 	struct fm10k_intfc *interface;
 	struct pci_dev *pdev;
@@ -1186,7 +1186,7 @@ static s32 fm10k_lport_map(struct fm10k_hw *hw, u32 **results,
 }
 
 static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
-			     struct fm10k_mbx_info *mbx)
+			     struct fm10k_mbx_info __always_unused *mbx)
 {
 	struct fm10k_intfc *interface;
 	u16 glort, pvid;
@@ -1227,7 +1227,7 @@ static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
 }
 
 static s32 fm10k_1588_msg_pf(struct fm10k_hw *hw, u32 **results,
-			     struct fm10k_mbx_info *mbx)
+			     struct fm10k_mbx_info __always_unused *mbx)
 {
 	struct fm10k_swapi_1588_timestamp timestamp;
 	struct fm10k_iov_data *iov_data;
@@ -2005,7 +2005,8 @@ static int fm10k_resume(struct pci_dev *pdev)
  * a sleep state.  The fm10k hardware does not support wake on lan so the
  * driver simply needs to shut down the device so it is in a low power state.
  **/
-static int fm10k_suspend(struct pci_dev *pdev, pm_message_t state)
+static int fm10k_suspend(struct pci_dev *pdev,
+			 pm_message_t __always_unused state)
 {
 	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
 	struct net_device *netdev = interface->netdev;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index 02008e9..9043633 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -319,7 +319,8 @@ static int fm10k_ptp_settime(struct ptp_clock_info *ptp,
 }
 
 static int fm10k_ptp_enable(struct ptp_clock_info *ptp,
-			    struct ptp_clock_request *rq, int on)
+			    struct ptp_clock_request *rq,
+			    int __always_unused on)
 {
 	struct ptp_clock_time *t = &rq->perout.period;
 	struct fm10k_intfc *interface;
-- 
1.9.3
