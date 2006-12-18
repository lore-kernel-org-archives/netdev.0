From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 7/8] NetXen: Fix for PPC machines.
Date: Mon, 18 Dec 2006 05:53:59 -0800
Message-ID: <200612181353.kBIDrx7D012229@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4130 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754062AbWLROWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:53 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com> 
 
 netxen_nic.h      |    2 +-
 netxen_nic_init.c |   12 ++++++------
 netxen_nic_main.c |    4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)
    

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 86dcd52..31b2553 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,7 +63,7 @@
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "2"
+#define NETXEN_NIC_BUILD_NO     "3"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
 #define _NETXEN_NIC_LINUX_SUBVERSION 2
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c147943..c0cbc30 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -928,7 +928,7 @@ u32 netxen_process_rcv_ring(struct netxe
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
 		netxen_clear_sts_owner(desc);
-		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
+		netxen_set_sts_owner(desc, cpu_to_le16(STATUS_OWNER_PHANTOM));
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
@@ -1138,13 +1138,13 @@ void netxen_post_rx_buffers(struct netxe
 		 */
 		dma = pci_map_single(pdev, skb->data, rcv_desc->dma_size,
 				     PCI_DMA_FROMDEVICE);
-		pdesc->addr_buffer = dma;
+		pdesc->addr_buffer = cpu_to_le64(dma);
 		buffer->skb = skb;
 		buffer->state = NETXEN_BUFFER_BUSY;
 		buffer->dma = dma;
 		/* make a rcv descriptor  */
-		pdesc->reference_handle = buffer->ref_handle;
-		pdesc->buffer_length = rcv_desc->dma_size;
+		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
+		pdesc->buffer_length = cpu_to_le32(rcv_desc->dma_size);
 		DPRINTK(INFO, "done writing descripter\n");
 		producer =
 		    get_next_index(producer, rcv_desc->max_rx_desc_count);
@@ -1232,8 +1232,8 @@ void netxen_post_rx_buffers_nodb(struct
 					     PCI_DMA_FROMDEVICE);
 
 		/* make a rcv descriptor  */
-		pdesc->reference_handle = le16_to_cpu(buffer->ref_handle);
-		pdesc->buffer_length = le16_to_cpu(rcv_desc->dma_size);
+		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
+		pdesc->buffer_length = cpu_to_le16(rcv_desc->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 		DPRINTK(INFO, "done writing descripter\n");
 		producer =
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index bc08d21..aecc07d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -822,8 +822,8 @@ static int netxen_nic_xmit_frame(struct
 	/* Take skb->data itself */
 	pbuf = &adapter->cmd_buf_arr[producer];
 	if ((netdev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size > 0) {
-		pbuf->mss = skb_shinfo(skb)->gso_size;
-		hwdesc->mss = skb_shinfo(skb)->gso_size;
+		pbuf->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+		hwdesc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 	} else {
 		pbuf->mss = 0;
 		hwdesc->mss = 0;
