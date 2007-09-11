From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH netdev-2.6/ALL] DIV_ROUND_UP/roundup cleanup (under drivers/net/)
Date: Wed, 12 Sep 2007 00:29:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709120016460.11602@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2127863750-1189546183=:11602"
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Eugene Surovegin <ebs@ebshome.net>,
	Roland Dreier <rolandd@cisco.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Ion Badulescu <ionut@badula.org>,
	Jeremy Fitzhardinge <jeremy@xensource.com>
To: Jeff Garzik <jeff@garzik.org>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34877 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbXIKV3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 17:29:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2127863750-1189546183=:11602
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/arcnet/rfc1201.c        |    3 ++-
 drivers/net/atl1/atl1_main.c        |   17 +++++++----------
 drivers/net/gianfar_ethtool.c       |    2 +-
 drivers/net/ibm_emac/ibm_emac_mal.h |    3 ++-
 drivers/net/mlx4/alloc.c            |    3 ++-
 drivers/net/mlx4/icm.c              |    3 ++-
 drivers/net/s2io.c                  |   11 ++++-------
 drivers/net/sb1250-mac.c            |    2 +-
 drivers/net/starfire.c              |    6 +++---
 drivers/net/wan/sbni.c              |    2 +-
 drivers/net/xen-netfront.c          |    2 +-
 11 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 460a095..126ee5b 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -23,6 +23,7 @@
  *
  * **********************
  */
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/if_arp.h>
@@ -493,7 +494,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 		out->length = length - RFC1201_HDR_SIZE;
 		out->dataleft = lp->outgoing.length;
-		out->numsegs = (out->dataleft + maxsegsize - 1) / maxsegsize;
+		out->numsegs = DIV_ROUND_UP(out->dataleft, maxsegsize);
 		out->segnum = 0;
 
 		BUGMSG(D_DURING, "rfc1201 prep_tx: ready for %d-segment split "
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index c8deefa..b198f70 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -51,6 +51,7 @@
  */
 
 #include <linux/types.h>
+#include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
 #include <linux/spinlock.h>
@@ -1132,8 +1133,7 @@ static void atl1_update_rfd_index(struct atl1_adapter *adapter,
 {
 	u16 num_buf;
 
-	num_buf = (rrd->xsz.xsum_sz.pkt_size + adapter->rx_buffer_len - 1) /
-		adapter->rx_buffer_len;
+	num_buf = DIV_ROUND_UP(rrd->xsz.xsum_sz.pkt_size, adapter->rx_buffer_len);
 	if (rrd->num_buf == num_buf)
 		/* clean alloc flag for bad rrd */
 		atl1_clean_alloc_flag(adapter, rrd, num_buf);
@@ -1537,8 +1537,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 
 		if (first_buf_len > proto_hdr_len) {
 			len12 = first_buf_len - proto_hdr_len;
-			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) /
-				ATL1_MAX_TX_BUF_LEN;
+			m = DIV_ROUND_UP(len12, ATL1_MAX_TX_BUF_LEN);
 			for (i = 0; i < m; i++) {
 				buffer_info =
 				    &tpd_ring->buffer_info[tpd_next_to_use];
@@ -1578,7 +1577,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 		frag = &skb_shinfo(skb)->frags[f];
 		lenf = frag->size;
 
-		m = (lenf + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
+		m = DIV_ROUND_UP(lenf, ATL1_MAX_TX_BUF_LEN);
 		for (i = 0; i < m; i++) {
 			buffer_info = &tpd_ring->buffer_info[tpd_next_to_use];
 			if (unlikely(buffer_info->skb))
@@ -1681,8 +1680,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	for (f = 0; f < nr_frags; f++) {
 		frag_size = skb_shinfo(skb)->frags[f].size;
 		if (frag_size)
-			count += (frag_size + ATL1_MAX_TX_BUF_LEN - 1) /
-				ATL1_MAX_TX_BUF_LEN;
+			count += DIV_ROUND_UP(frag_size, ATL1_MAX_TX_BUF_LEN);
 	}
 
 	/* mss will be nonzero if we're doing segment offload (TSO/GSO) */
@@ -1697,9 +1695,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			}
 			/* need additional TPD ? */
 			if (proto_hdr_len != len)
-				count += (len - proto_hdr_len +
-					ATL1_MAX_TX_BUF_LEN - 1) /
-					ATL1_MAX_TX_BUF_LEN;
+				count += DIV_ROUND_UP(len - proto_hdr_len,
+						      ATL1_MAX_TX_BUF_LEN);
 		}
 	}
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 2470903..8352754 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -245,7 +245,7 @@ static unsigned int gfar_usecs2ticks(struct gfar_private *priv, unsigned int use
 
 	/* Make sure we return a number greater than 0
 	 * if usecs > 0 */
-	return ((usecs * 1000 + count - 1) / count);
+	return DIV_ROUND_UP(usecs * 1000, count);
 }
 
 /* Convert ethernet clock ticks to microseconds */
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index 64bc338..6bac886 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -20,6 +20,7 @@
 #define __IBM_EMAC_MAL_H_
 
 #include <linux/init.h>
+#include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
 
@@ -143,7 +144,7 @@ static inline int mal_rx_size(int len)
 
 static inline int mal_tx_chunks(int len)
 {
-	return (len + MAL_MAX_TX_SIZE - 1) / MAL_MAX_TX_SIZE;
+	return DIV_ROUND_UP(len, MAL_MAX_TX_SIZE);
 }
 
 #define MAL_CHAN_MASK(n)	(0x80000000 >> (n))
diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index f8d63d3..ea51b41 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -31,6 +31,7 @@
  */
 
 #include <linux/errno.h>
+#include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/bitmap.h>
 #include <linux/dma-mapping.h>
@@ -132,7 +133,7 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 	} else {
 		int i;
 
-		buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
+		buf->nbufs       = DIV_ROUND_UP(size, PAGE_SIZE);
 		buf->npages      = buf->nbufs;
 		buf->page_shift  = PAGE_SHIFT;
 		buf->u.page_list = kzalloc(buf->nbufs * sizeof *buf->u.page_list,
diff --git a/drivers/net/mlx4/icm.c b/drivers/net/mlx4/icm.c
index b7a4aa8..a99cca6 100644
--- a/drivers/net/mlx4/icm.c
+++ b/drivers/net/mlx4/icm.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/mm.h>
 
@@ -317,7 +318,7 @@ int mlx4_init_icm_table(struct mlx4_dev *dev, struct mlx4_icm_table *table,
 	int i;
 
 	obj_per_chunk = MLX4_TABLE_CHUNK_SIZE / obj_size;
-	num_icm = (nobj + obj_per_chunk - 1) / obj_per_chunk;
+	num_icm = DIV_ROUND_UP(nobj, obj_per_chunk);
 
 	table->icm      = kcalloc(num_icm, sizeof *table->icm, GFP_KERNEL);
 	if (!table->icm)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 3d47793..ddd0f12 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -484,9 +484,6 @@ static struct pci_driver s2io_driver = {
       .err_handler = &s2io_err_handler,
 };
 
-/* A simplifier macro used both by init and free shared_mem Fns(). */
-#define TXD_MEM_PAGE_CNT(len, per_each) ((len+per_each - 1) / per_each)
-
 /**
  * init_shared_mem - Allocation and Initialization of Memory
  * @nic: Device private variable.
@@ -543,8 +540,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
-						lst_per_page);
+		int page_num = DIV_ROUND_UP(config->tx_cfg[i].fifo_len,
+					    lst_per_page);
 		mac_control->fifos[i].tx_curr_put_info.offset = 0;
 		mac_control->fifos[i].tx_curr_put_info.fifo_len =
 		    config->tx_cfg[i].fifo_len - 1;
@@ -813,8 +810,8 @@ static void free_shared_mem(struct s2io_nic *nic)
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		ufo_size += config->tx_cfg[i].fifo_len;
-		page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
-							lst_per_page);
+		page_num = DIV_ROUND_UP(config->tx_cfg[i].fifo_len,
+					lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
 			if (!mac_control->fifos[i].list_info)
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index fb7ed67..75e93a0 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -162,7 +162,7 @@ typedef enum { sbmac_state_uninit, sbmac_state_off, sbmac_state_on,
 			  (d)->sbdma_dscrtable : (d)->f+1)
 
 
-#define NUMCACHEBLKS(x) (((x)+SMP_CACHE_BYTES-1)/SMP_CACHE_BYTES)
+#define NUMCACHEBLKS(x) DIV_ROUND_UP((x), SMP_CACHE_BYTES)
 
 #define SBMAC_MAX_TXDESCR	256
 #define SBMAC_MAX_RXDESCR	256
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 8b64786..645b634 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -966,9 +966,9 @@ static int netdev_open(struct net_device *dev)
 
 	/* Allocate the various queues. */
 	if (np->queue_mem == 0) {
-		tx_done_q_size = ((sizeof(struct tx_done_desc) * DONE_Q_SIZE + QUEUE_ALIGN - 1) / QUEUE_ALIGN) * QUEUE_ALIGN;
-		rx_done_q_size = ((sizeof(rx_done_desc) * DONE_Q_SIZE + QUEUE_ALIGN - 1) / QUEUE_ALIGN) * QUEUE_ALIGN;
-		tx_ring_size = ((sizeof(starfire_tx_desc) * TX_RING_SIZE + QUEUE_ALIGN - 1) / QUEUE_ALIGN) * QUEUE_ALIGN;
+		tx_done_q_size = roundup(sizeof(struct tx_done_desc) * DONE_Q_SIZE, QUEUE_ALIGN);
+		rx_done_q_size = roundup(sizeof(rx_done_desc) * DONE_Q_SIZE, QUEUE_ALIGN);
+		tx_ring_size = roundup(sizeof(starfire_tx_desc) * TX_RING_SIZE, QUEUE_ALIGN);
 		rx_ring_size = sizeof(struct starfire_rx_desc) * RX_RING_SIZE;
 		np->queue_mem_size = tx_done_q_size + rx_done_q_size + tx_ring_size + rx_ring_size;
 		np->queue_mem = pci_alloc_consistent(np->pci_dev, np->queue_mem_size, &np->queue_mem_dma);
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 1cc18e7..ba240a5 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -857,7 +857,7 @@ prepare_to_send( struct sk_buff  *skb,  struct net_device  *dev )
 		len = SBNI_MIN_LEN;
 
 	nl->tx_buf_p	= skb;
-	nl->tx_frameno	= (len + nl->maxframe - 1) / nl->maxframe;
+	nl->tx_frameno	= DIV_ROUND_UP(len, nl->maxframe);
 	nl->framelen	= len < nl->maxframe  ?  len  :  nl->maxframe;
 
 	outb( inb( dev->base_addr + CSR0 ) | TR_REQ,  dev->base_addr + CSR0 );
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 17d3636..fe4bf52 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -456,7 +456,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 
-	frags += (offset + len + PAGE_SIZE - 1) / PAGE_SIZE;
+	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
 	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
 		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
 		       frags);
-- 
1.5.0.6

---696243703-2127863750-1189546183=:11602--
