From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 5/9] e1000: checkpatch clean
Date: Fri, 11 Jul 2008 15:17:23 -0700
Message-ID: <20080711221723.3255.58074.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62937 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593AbYGKWRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:24 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Redefine DPRINTK macro using do while(0)
__FUNCTION__ to __func__
structs {} on separate lines
Surround negative constants with ()

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a1f4a76..3aeba93 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -90,10 +90,13 @@ struct e1000_adapter;
 #define E1000_ERR(args...) printk(KERN_ERR "e1000: " args)
 
 #define PFX "e1000: "
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
+
+#define DPRINTK(nlevel, klevel, fmt, args...)				\
+do {									\
+	if (NETIF_MSG_##nlevel & adapter->msg_enable)			\
+		printk(KERN_##klevel PFX "%s: %s: " fmt,		\
+		       adapter->netdev->name, __func__, ##args);	\
+} while (0)
 
 #define E1000_MAX_INTR 10
 
@@ -151,9 +154,9 @@ struct e1000_adapter;
 #define E1000_MASTER_SLAVE	e1000_ms_hw_default
 #endif
 
-#define E1000_MNG_VLAN_NONE -1
+#define E1000_MNG_VLAN_NONE (-1)
 /* Number of packet split data buffers (not including the header buffer) */
-#define PS_PAGE_BUFFERS MAX_PS_BUFFERS-1
+#define PS_PAGE_BUFFERS (MAX_PS_BUFFERS - 1)
 
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
@@ -165,9 +168,13 @@ struct e1000_buffer {
 	u16 next_to_watch;
 };
 
+struct e1000_ps_page {
+	struct page *ps_page[PS_PAGE_BUFFERS];
+};
 
-struct e1000_ps_page { struct page *ps_page[PS_PAGE_BUFFERS]; };
-struct e1000_ps_page_dma { u64 ps_page_dma[PS_PAGE_BUFFERS]; };
+struct e1000_ps_page_dma {
+	u64 ps_page_dma[PS_PAGE_BUFFERS];
+};
 
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
@@ -217,13 +224,13 @@ struct e1000_rx_ring {
 	u16 rdt;
 };
 
-#define E1000_DESC_UNUSED(R) \
-	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
-	(R)->next_to_clean - (R)->next_to_use - 1)
+#define E1000_DESC_UNUSED(R)						\
+	((((R)->next_to_clean > (R)->next_to_use)			\
+	  ? 0 : (R)->count) + (R)->next_to_clean - (R)->next_to_use - 1)
 
-#define E1000_RX_DESC_PS(R, i)	    \
+#define E1000_RX_DESC_PS(R, i)						\
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
-#define E1000_RX_DESC_EXT(R, i)	    \
+#define E1000_RX_DESC_EXT(R, i)						\
 	(&(((union e1000_rx_desc_extended *)((R).desc))[i]))
 #define E1000_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
 #define E1000_RX_DESC(R, i)		E1000_GET_DESC(R, i, e1000_rx_desc)
@@ -317,7 +324,6 @@ struct e1000_adapter {
 	u64 gorcl_old;
 	u16 rx_ps_bsize0;
 
-
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;

