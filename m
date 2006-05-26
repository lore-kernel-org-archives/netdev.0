From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/9] ixgb: remove inlines, allow compiler to choose
Date: Fri, 26 May 2006 09:52:07 -0700
Message-ID: <20060526165207.30514.66657.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:33798 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751136AbWEZQrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:47:03 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


deinline a few large functions as to allow the compiler to pick.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index a714c4d..037b5c3 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -203,7 +203,7 @@ module_exit(ixgb_exit_module);
  * @adapter: board private structure
  **/
 
-static inline void
+static void
 ixgb_irq_disable(struct ixgb_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
@@ -217,7 +217,7 @@ ixgb_irq_disable(struct ixgb_adapter *ad
  * @adapter: board private structure
  **/
 
-static inline void
+static void
 ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
 	if(atomic_dec_and_test(&adapter->irq_sem)) {
@@ -918,7 +918,7 @@ ixgb_free_tx_resources(struct ixgb_adapt
 	adapter->tx_ring.desc = NULL;
 }
 
-static inline void
+static void
 ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
 					struct ixgb_buffer *buffer_info)
 {
@@ -1179,7 +1179,7 @@ ixgb_watchdog(unsigned long data)
 #define IXGB_TX_FLAGS_VLAN		0x00000002
 #define IXGB_TX_FLAGS_TSO		0x00000004
 
-static inline int
+static int
 ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 #ifdef NETIF_F_TSO
@@ -1241,7 +1241,7 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 	return 0;
 }
 
-static inline boolean_t
+static boolean_t
 ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
@@ -1279,7 +1279,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 #define IXGB_MAX_TXD_PWR	14
 #define IXGB_MAX_DATA_PER_TXD	(1<<IXGB_MAX_TXD_PWR)
 
-static inline int
+static int
 ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 	    unsigned int first)
 {
@@ -1346,7 +1346,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	return count;
 }
 
-static inline void
+static void
 ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
@@ -1849,7 +1849,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
  * @sk_buff: socket buffer with received data
  **/
 
-static inline void
+static void
 ixgb_rx_checksum(struct ixgb_adapter *adapter,
 		 struct ixgb_rx_desc *rx_desc,
 		 struct sk_buff *skb)



--
Auke Kok <auke-jan.h.kok@intel.com>
