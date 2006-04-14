From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/10] e1000: De-inline functions to benefit from compiler smartness
Date: Fri, 14 Apr 2006 11:36:54 -0700
Message-ID: <20060414183653.3461.13570.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:49156 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751395AbWDNSdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:16 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


De-inline functions to benefit from compiler smartness


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000_main.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8de9f9a..5e7b4ee 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -208,8 +208,8 @@ static void e1000_leave_82542_rst(struct
 static void e1000_tx_timeout(struct net_device *dev);
 static void e1000_reset_task(struct net_device *dev);
 static void e1000_smartspeed(struct e1000_adapter *adapter);
-static inline int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
-					      struct sk_buff *skb);
+static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
+                                       struct sk_buff *skb);
 
 static void e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
@@ -291,7 +291,7 @@ module_exit(e1000_exit_module);
  * @adapter: board private structure
  **/
 
-static inline void
+static void
 e1000_irq_disable(struct e1000_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
@@ -305,7 +305,7 @@ e1000_irq_disable(struct e1000_adapter *
  * @adapter: board private structure
  **/
 
-static inline void
+static void
 e1000_irq_enable(struct e1000_adapter *adapter)
 {
 	if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
@@ -349,7 +349,7 @@ e1000_update_mng_vlan(struct e1000_adapt
  * 
  **/
 
-static inline void 
+static void
 e1000_release_hw_control(struct e1000_adapter *adapter)
 {
 	uint32_t ctrl_ext;
@@ -384,7 +384,7 @@ e1000_release_hw_control(struct e1000_ad
  * 
  **/
 
-static inline void 
+static void
 e1000_get_hw_control(struct e1000_adapter *adapter)
 {
 	uint32_t ctrl_ext;
@@ -1181,7 +1181,7 @@ e1000_close(struct net_device *netdev)
  * @start: address of beginning of memory
  * @len: length of memory
  **/
-static inline boolean_t
+static boolean_t
 e1000_check_64k_bound(struct e1000_adapter *adapter,
 		      void *start, unsigned long len)
 {
@@ -1807,7 +1807,7 @@ e1000_free_all_tx_resources(struct e1000
 		e1000_free_tx_resources(adapter, &adapter->tx_ring[i]);
 }
 
-static inline void
+static void
 e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 			struct e1000_buffer *buffer_info)
 {
@@ -2400,7 +2400,7 @@ e1000_watchdog_task(struct e1000_adapter
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
-static inline int
+static int
 e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
           struct sk_buff *skb)
 {
@@ -2480,7 +2480,7 @@ e1000_tso(struct e1000_adapter *adapter,
 	return FALSE;
 }
 
-static inline boolean_t
+static boolean_t
 e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
               struct sk_buff *skb)
 {
@@ -2516,7 +2516,7 @@ e1000_tx_csum(struct e1000_adapter *adap
 #define E1000_MAX_TXD_PWR	12
 #define E1000_MAX_DATA_PER_TXD	(1<<E1000_MAX_TXD_PWR)
 
-static inline int
+static int
 e1000_tx_map(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
              struct sk_buff *skb, unsigned int first, unsigned int max_per_txd,
              unsigned int nr_frags, unsigned int mss)
@@ -2625,7 +2625,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 	return count;
 }
 
-static inline void
+static void
 e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
                int tx_flags, int count)
 {
@@ -2689,7 +2689,7 @@ e1000_tx_queue(struct e1000_adapter *ada
 #define E1000_FIFO_HDR			0x10
 #define E1000_82547_PAD_LEN		0x3E0
 
-static inline int
+static int
 e1000_82547_fifo_workaround(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
 	uint32_t fifo_space = adapter->tx_fifo_size - adapter->tx_fifo_head;
@@ -2716,7 +2716,7 @@ no_fifo_stall_required:
 }
 
 #define MINIMUM_DHCP_PACKET_SIZE 282
-static inline int
+static int
 e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
 	struct e1000_hw *hw =  &adapter->hw;
@@ -3445,7 +3445,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
  * @sk_buff:     socket buffer with received data
  **/
 
-static inline void
+static void
 e1000_rx_checksum(struct e1000_adapter *adapter,
 		  uint32_t status_err, uint32_t csum,
 		  struct sk_buff *skb)



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
