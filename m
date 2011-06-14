From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Mon, 13 Jun 2011 21:02:39 -0700
Message-ID: <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
References: <cover.1308024069.git.joe@perches.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat.org>,
	David Dillow <dav
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2942 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab1FNECw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 00:02:52 -0400
In-Reply-To: <cover.1308024069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unnecessary casts of void * clutter the code.

These are the remainder casts after several specific
patches to remove netdev_priv and dev_priv.

Done via coccinelle script:

$ cat cast_void_pointer.cocci
@@
type T;
T *pt;
void *pv;
@@

- pt = (T *)pv;
+ pt = pv;

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/a2065.c                 |    2 +-
 drivers/net/appletalk/ltpc.c        |    8 +++---
 drivers/net/atl1e/atl1e_main.c      |    5 +--
 drivers/net/atlx/atl2.c             |    3 +-
 drivers/net/benet/be_cmds.c         |    3 +-
 drivers/net/benet/be_ethtool.c      |    4 +-
 drivers/net/bna/bfa_cee.c           |    2 +-
 drivers/net/bna/cna.h               |    2 +-
 drivers/net/caif/caif_shmcore.c     |    2 +-
 drivers/net/cnic.c                  |    4 +-
 drivers/net/cxgb3/cxgb3_offload.c   |    2 +-
 drivers/net/davinci_cpdma.c         |    2 +-
 drivers/net/declance.c              |   38 +++++++++++++++++------------
 drivers/net/depca.c                 |    4 +-
 drivers/net/dl2k.c                  |    4 +-
 drivers/net/ehea/ehea_qmr.c         |    2 +-
 drivers/net/epic100.c               |    4 +-
 drivers/net/fealnx.c                |    4 +-
 drivers/net/gianfar.c               |    4 +-
 drivers/net/hamachi.c               |    4 +-
 drivers/net/macmace.c               |    2 +-
 drivers/net/mlx4/en_rx.c            |    2 +-
 drivers/net/mlx4/en_tx.c            |    5 +--
 drivers/net/myri_sbus.c             |    3 +-
 drivers/net/netxen/netxen_nic_ctx.c |   16 ++++++------
 drivers/net/pxa168_eth.c            |    2 +-
 drivers/net/qla3xxx.c               |    5 +--
 drivers/net/qlcnic/qlcnic_ctx.c     |   26 ++++++++++----------
 drivers/net/qlcnic/qlcnic_ethtool.c |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c      |    3 +-
 drivers/net/qlcnic/qlcnic_main.c    |    2 +-
 drivers/net/qlge/qlge_main.c        |    4 +-
 drivers/net/s2io.c                  |   18 +++++--------
 drivers/net/sfc/siena.c             |    2 +-
 drivers/net/sis900.c                |    4 +-
 drivers/net/tokenring/madgemc.c     |    2 +-
 drivers/net/typhoon.c               |    2 +-
 drivers/net/vxge/vxge-config.c      |   44 ++++++++++++-----------------------
 drivers/net/vxge/vxge-traffic.c     |    6 ++--
 drivers/net/wan/pc300_tty.c         |    2 +-
 drivers/net/xilinx_emaclite.c       |    4 +-
 drivers/net/yellowfin.c             |    6 ++--
 42 files changed, 123 insertions(+), 142 deletions(-)

diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index deaa8bc..0230fc2 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -426,7 +426,7 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
 	volatile struct lance_regs *ll;
 	int csr0;
 
-	dev = (struct net_device *) dev_id;
+	dev = dev_id;
 
 	lp = netdev_priv(dev);
 	ll = lp->ll;
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index e69eead..34ffb54 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -652,9 +652,9 @@ static int do_write(struct net_device *dev, void *cbuf, int cbuflen,
 	int ret;
 
 	if(i) {
-		qels[i].cbuf = (unsigned char *) cbuf;
+		qels[i].cbuf = cbuf;
 		qels[i].cbuflen = cbuflen;
-		qels[i].dbuf = (unsigned char *) dbuf;
+		qels[i].dbuf = dbuf;
 		qels[i].dbuflen = dbuflen;
 		qels[i].QWrite = 1;
 		qels[i].mailbox = i;  /* this should be initted rather */
@@ -676,9 +676,9 @@ static int do_read(struct net_device *dev, void *cbuf, int cbuflen,
 	int ret;
 
 	if(i) {
-		qels[i].cbuf = (unsigned char *) cbuf;
+		qels[i].cbuf = cbuf;
 		qels[i].cbuflen = cbuflen;
-		qels[i].dbuf = (unsigned char *) dbuf;
+		qels[i].dbuf = dbuf;
 		qels[i].dbuflen = dbuflen;
 		qels[i].QWrite = 0;
 		qels[i].mailbox = i;  /* this should be initted rather */
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 86a9122..c3c5db1 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -800,8 +800,7 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 	/* Init TPD Ring */
 	tx_ring->dma = roundup(adapter->ring_dma, 8);
 	offset = tx_ring->dma - adapter->ring_dma;
-	tx_ring->desc = (struct atl1e_tpd_desc *)
-			(adapter->ring_vir_addr + offset);
+	tx_ring->desc = adapter->ring_vir_addr + offset;
 	size = sizeof(struct atl1e_tx_buffer) * (tx_ring->count);
 	tx_ring->tx_buffer = kzalloc(size, GFP_KERNEL);
 	if (tx_ring->tx_buffer == NULL) {
@@ -827,7 +826,7 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 
 	/* Init CMB dma address */
 	tx_ring->cmb_dma = adapter->ring_dma + offset;
-	tx_ring->cmb     = (u32 *)(adapter->ring_vir_addr + offset);
+	tx_ring->cmb = adapter->ring_vir_addr + offset;
 	offset += sizeof(u32);
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 16249e9..24e1592 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -311,8 +311,7 @@ static s32 atl2_setup_ring_resources(struct atl2_adapter *adapter)
 	adapter->txd_dma = adapter->ring_dma ;
 	offset = (adapter->txd_dma & 0x7) ? (8 - (adapter->txd_dma & 0x7)) : 0;
 	adapter->txd_dma += offset;
-	adapter->txd_ring = (struct tx_pkt_header *) (adapter->ring_vir_addr +
-		offset);
+	adapter->txd_ring = adapter->ring_vir_addr + offset;
 
 	/* Init TXS Ring */
 	adapter->txs_dma = adapter->txd_dma + adapter->txd_ring_size;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0c12c2d..30719f5 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -2334,8 +2334,7 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 
 	status = be_mbox_notify_wait(adapter);
 	if (!status) {
-		attribs = (struct mgmt_controller_attrib *)( attribs_cmd.va +
-					sizeof(struct be_cmd_resp_hdr));
+		attribs = attribs_cmd.va + sizeof(struct be_cmd_resp_hdr);
 		adapter->hba_port_num = attribs->hba_attribs.phy_port;
 	}
 
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index facfe3c..5572c78 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -386,7 +386,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		}
 		status = be_cmd_get_phy_info(adapter, &phy_cmd);
 		if (!status) {
-			resp = (struct be_cmd_resp_get_phy_info *) phy_cmd.va;
+			resp = phy_cmd.va;
 			intf_type = le16_to_cpu(resp->interface_type);
 
 			switch (intf_type) {
@@ -690,7 +690,7 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	status = be_cmd_get_seeprom_data(adapter, &eeprom_cmd);
 
 	if (!status) {
-		resp = (struct be_cmd_resp_seeprom_read *) eeprom_cmd.va;
+		resp = eeprom_cmd.va;
 		memcpy(data, resp->seeprom_data + eeprom->offset, eeprom->len);
 	}
 	dma_free_coherent(&adapter->pdev->dev, eeprom_cmd.size, eeprom_cmd.va,
diff --git a/drivers/net/bna/bfa_cee.c b/drivers/net/bna/bfa_cee.c
index f7b789a..dcfbf08 100644
--- a/drivers/net/bna/bfa_cee.c
+++ b/drivers/net/bna/bfa_cee.c
@@ -236,7 +236,7 @@ static void
 bfa_cee_hbfail(void *arg)
 {
 	struct bfa_cee *cee;
-	cee = (struct bfa_cee *) arg;
+	cee = arg;
 
 	if (cee->get_attr_pending == true) {
 		cee->get_attr_status = BFA_STATUS_FAILED;
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index bbd39dc..3c47dc5 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -74,7 +74,7 @@ typedef struct mac { u8 mac[MAC_ADDRLEN]; } mac_t;
 		bfa_q_next(_q) = bfa_q_next(*((struct list_head **) _qe)); \
 		bfa_q_qe_init(*((struct list_head **) _qe));		\
 	} else {							\
-		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+		*((struct list_head **)(_qe)) = NULL;			\
 	}								\
 }
 
diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_shmcore.c
index 731aa11..d4b26fb 100644
--- a/drivers/net/caif/caif_shmcore.c
+++ b/drivers/net/caif/caif_shmcore.c
@@ -134,7 +134,7 @@ int caif_shmdrv_rx_cb(u32 mbx_msg, void *priv)
 	u32 avail_emptybuff = 0;
 	unsigned long flags = 0;
 
-	pshm_drv = (struct shmdrv_layer *)priv;
+	pshm_drv = priv;
 
 	/* Check for received buffers. */
 	if (mbx_msg & SHM_FULL_MASK) {
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 363c7f3..8548cbe 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4290,7 +4290,7 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 	val = BNX2_L2CTX_CMD_TYPE_TYPE_L2 | (8 << 16);
 	cnic_ctx_wr(dev, cid_addr, offset1, val);
 
-	txbd = (struct tx_bd *) udev->l2_ring;
+	txbd = udev->l2_ring;
 
 	buf_map = udev->l2_buf_map;
 	for (i = 0; i < MAX_TX_DESC_CNT; i++, txbd++) {
@@ -4349,7 +4349,7 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 		val = BNX2_L2CTX_L2_STATUSB_NUM(sb_id);
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_HOST_BDIDX, val);
 
-	rxbd = (struct rx_bd *) (udev->l2_ring + BCM_PAGE_SIZE);
+	rxbd = udev->l2_ring + BCM_PAGE_SIZE;
 	for (i = 0; i < MAX_RX_DESC_CNT; i++, rxbd++) {
 		dma_addr_t buf_map;
 		int n = (i % cp->l2_rx_ring_size) + 1;
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 862804f..9db9068 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -567,7 +567,7 @@ static void t3_process_tid_release_list(struct work_struct *work)
 	while (td->tid_release_list) {
 		struct t3c_tid_entry *p = td->tid_release_list;
 
-		td->tid_release_list = (struct t3c_tid_entry *)p->ctx;
+		td->tid_release_list = p->ctx;
 		spin_unlock_bh(&td->tid_release_lock);
 
 		skb = alloc_skb(sizeof(struct cpl_tid_release),
diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
index ae47f23..dca9d33 100644
--- a/drivers/net/davinci_cpdma.c
+++ b/drivers/net/davinci_cpdma.c
@@ -167,7 +167,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
 	} else {
 		pool->cpumap = dma_alloc_coherent(dev, size, &pool->phys,
 						  GFP_KERNEL);
-		pool->iomap = (void __force __iomem *)pool->cpumap;
+		pool->iomap = pool->cpumap;
 		pool->hw_addr = pool->phys;
 	}
 
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 219eb5a..cabd3a5 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -326,15 +326,18 @@ static void load_csrs(struct lance_private *lp)
  */
 static void cp_to_buf(const int type, void *to, const void *from, int len)
 {
-	unsigned short *tp, *fp, clen;
-	unsigned char *rtp, *rfp;
+	unsigned short *tp;
+	const unsigned short *fp;
+	unsigned short clen;
+	unsigned char *rtp;
+	const unsigned char *rfp;
 
 	if (type == PMAD_LANCE) {
 		memcpy(to, from, len);
 	} else if (type == PMAX_LANCE) {
 		clen = len >> 1;
-		tp = (unsigned short *) to;
-		fp = (unsigned short *) from;
+		tp = to;
+		fp = from;
 
 		while (clen--) {
 			*tp++ = *fp++;
@@ -342,8 +345,8 @@ static void cp_to_buf(const int type, void *to, const void *from, int len)
 		}
 
 		clen = len & 1;
-		rtp = (unsigned char *) tp;
-		rfp = (unsigned char *) fp;
+		rtp = tp;
+		rfp = fp;
 		while (clen--) {
 			*rtp++ = *rfp++;
 		}
@@ -352,8 +355,8 @@ static void cp_to_buf(const int type, void *to, const void *from, int len)
 		 * copy 16 Byte chunks
 		 */
 		clen = len >> 4;
-		tp = (unsigned short *) to;
-		fp = (unsigned short *) from;
+		tp = to;
+		fp = from;
 		while (clen--) {
 			*tp++ = *fp++;
 			*tp++ = *fp++;
@@ -382,15 +385,18 @@ static void cp_to_buf(const int type, void *to, const void *from, int len)
 
 static void cp_from_buf(const int type, void *to, const void *from, int len)
 {
-	unsigned short *tp, *fp, clen;
-	unsigned char *rtp, *rfp;
+	unsigned short *tp;
+	const unsigned short *fp;
+	unsigned short clen;
+	unsigned char *rtp;
+	const unsigned char *rfp;
 
 	if (type == PMAD_LANCE) {
 		memcpy(to, from, len);
 	} else if (type == PMAX_LANCE) {
 		clen = len >> 1;
-		tp = (unsigned short *) to;
-		fp = (unsigned short *) from;
+		tp = to;
+		fp = from;
 		while (clen--) {
 			*tp++ = *fp++;
 			fp++;
@@ -398,8 +404,8 @@ static void cp_from_buf(const int type, void *to, const void *from, int len)
 
 		clen = len & 1;
 
-		rtp = (unsigned char *) tp;
-		rfp = (unsigned char *) fp;
+		rtp = tp;
+		rfp = fp;
 
 		while (clen--) {
 			*rtp++ = *rfp++;
@@ -410,8 +416,8 @@ static void cp_from_buf(const int type, void *to, const void *from, int len)
 		 * copy 16 Byte chunks
 		 */
 		clen = len >> 4;
-		tp = (unsigned short *) to;
-		fp = (unsigned short *) from;
+		tp = to;
+		fp = from;
 		while (clen--) {
 			*tp++ = *fp++;
 			*tp++ = *fp++;
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 8b0084d..d54a0e9 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -708,11 +708,11 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 
 	/* Tx & Rx descriptors (aligned to a quadword boundary) */
 	offset = (offset + DEPCA_ALIGN) & ~DEPCA_ALIGN;
-	lp->rx_ring = (struct depca_rx_desc __iomem *) (lp->sh_mem + offset);
+	lp->rx_ring = lp->sh_mem + offset;
 	lp->rx_ring_offset = offset;
 
 	offset += (sizeof(struct depca_rx_desc) * NUM_RX_DESC);
-	lp->tx_ring = (struct depca_tx_desc __iomem *) (lp->sh_mem + offset);
+	lp->tx_ring = lp->sh_mem + offset;
 	lp->tx_ring_offset = offset;
 
 	offset += (sizeof(struct depca_tx_desc) * NUM_TX_DESC);
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c445457..05e64b2 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -221,13 +221,13 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	ring_space = pci_alloc_consistent (pdev, TX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_iounmap;
-	np->tx_ring = (struct netdev_desc *) ring_space;
+	np->tx_ring = ring_space;
 	np->tx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent (pdev, RX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_unmap_tx;
-	np->rx_ring = (struct netdev_desc *) ring_space;
+	np->rx_ring = ring_space;
 	np->rx_ring_dma = ring_dma;
 
 	/* Parse eeprom data */
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index cd44bb8..95b9f4f 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -331,7 +331,7 @@ struct ehea_eqe *ehea_poll_eq(struct ehea_eq *eq)
 	unsigned long flags;
 
 	spin_lock_irqsave(&eq->spinlock, flags);
-	eqe = (struct ehea_eqe *)hw_eqit_eq_get_inc_valid(&eq->hw_queue);
+	eqe = hw_eqit_eq_get_inc_valid(&eq->hw_queue);
 	spin_unlock_irqrestore(&eq->spinlock, flags);
 
 	return eqe;
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index c353bf3..814c187 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -391,13 +391,13 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	ring_space = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_iounmap;
-	ep->tx_ring = (struct epic_tx_desc *)ring_space;
+	ep->tx_ring = ring_space;
 	ep->tx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent(pdev, RX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_unmap_tx;
-	ep->rx_ring = (struct epic_rx_desc *)ring_space;
+	ep->rx_ring = ring_space;
 	ep->rx_ring_dma = ring_dma;
 
 	if (dev->mem_start) {
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index dd54abe..fa8677c 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -566,7 +566,7 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_out_free_dev;
 	}
-	np->rx_ring = (struct fealnx_desc *)ring_space;
+	np->rx_ring = ring_space;
 	np->rx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &ring_dma);
@@ -574,7 +574,7 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_out_free_rx;
 	}
-	np->tx_ring = (struct fealnx_desc *)ring_space;
+	np->tx_ring = ring_space;
 	np->tx_ring_dma = ring_dma;
 
 	/* find the connected MII xcvrs */
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ff60b23..3564551 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -266,7 +266,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
 		tx_queue = priv->tx_queue[i];
-		tx_queue->tx_bd_base = (struct txbd8 *) vaddr;
+		tx_queue->tx_bd_base = vaddr;
 		tx_queue->tx_bd_dma_base = addr;
 		tx_queue->dev = ndev;
 		/* enet DMA only understands physical addresses */
@@ -277,7 +277,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 	/* Start the rx descriptor ring where the tx ring leaves off */
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
-		rx_queue->rx_bd_base = (struct rxbd8 *) vaddr;
+		rx_queue->rx_bd_base = vaddr;
 		rx_queue->rx_bd_dma_base = addr;
 		rx_queue->dev = ndev;
 		addr    += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index a09041a..c274b3d 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -648,13 +648,13 @@ static int __devinit hamachi_init_one (struct pci_dev *pdev,
 	ring_space = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_cleardev;
-	hmp->tx_ring = (struct hamachi_desc *)ring_space;
+	hmp->tx_ring = ring_space;
 	hmp->tx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent(pdev, RX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_unmap_tx;
-	hmp->rx_ring = (struct hamachi_desc *)ring_space;
+	hmp->rx_ring = ring_space;
 	hmp->rx_ring_dma = ring_dma;
 
 	/* Check for options being passed in */
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index c685a46..4286e67 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -221,7 +221,7 @@ static int __devinit mace_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	dev->base_addr = (u32)MACE_BASE;
-	mp->mace = (volatile struct mace *) MACE_BASE;
+	mp->mace = MACE_BASE;
 
 	dev->irq = IRQ_MAC_MACE;
 	mp->dma_intr = IRQ_MAC_MACE_DMA;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 277215f..5197b50 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -859,7 +859,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 				priv->rx_ring[0].cqn, &context);
 
 	ptr = ((void *) &context) + 0x3c;
-	rss_context = (struct mlx4_en_rss_context *) ptr;
+	rss_context = ptr;
 	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index b229acf..6e03de0 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -238,8 +238,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 	} else {
 		if (!tx_info->inl) {
 			if ((void *) data >= end) {
-				data = (struct mlx4_wqe_data_seg *)
-						(ring->buf + ((void *) data - end));
+				data = ring->buf + ((void *)data - end);
 			}
 
 			if (tx_info->linear) {
@@ -253,7 +252,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			for (i = 0; i < frags; i++) {
 				/* Check for wraparound before unmapping */
 				if ((void *) data >= end)
-					data = (struct mlx4_wqe_data_seg *) ring->buf;
+					data = ring->buf;
 				frag = &skb_shinfo(skb)->frags[i];
 				pci_unmap_page(mdev->pdev,
 					(dma_addr_t) be64_to_cpu(data->addr),
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 53aeea4..0f4cb88 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1041,8 +1041,7 @@ static int __devinit myri_sbus_probe(struct platform_device *op)
 
 	DET(("Shared memory base is %04x, ", mp->shmem_base));
 
-	mp->shmem = (struct myri_shmem __iomem *)
-		(mp->lanai + (mp->shmem_base * 2));
+	mp->shmem = mp->lanai + (mp->shmem_base * 2);
 	DET(("shmem mapped at %p\n", mp->shmem));
 
 	mp->rqack	= &mp->shmem->channel.recvqa;
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index f16966a..a925392 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -163,7 +163,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 				rq_size, &hostrq_phys_addr);
 	if (addr == NULL)
 		return -ENOMEM;
-	prq = (nx_hostrq_rx_ctx_t *)addr;
+	prq = addr;
 
 	addr = pci_alloc_consistent(adapter->pdev,
 			rsp_size, &cardrsp_phys_addr);
@@ -171,7 +171,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 		err = -ENOMEM;
 		goto out_free_rq;
 	}
-	prsp = (nx_cardrsp_rx_ctx_t *)addr;
+	prsp = addr;
 
 	prq->host_rsp_dma_addr = cpu_to_le64(cardrsp_phys_addr);
 
@@ -318,10 +318,10 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	}
 
 	memset(rq_addr, 0, rq_size);
-	prq = (nx_hostrq_tx_ctx_t *)rq_addr;
+	prq = rq_addr;
 
 	memset(rsp_addr, 0, rsp_size);
-	prsp = (nx_cardrsp_tx_ctx_t *)rsp_addr;
+	prsp = rsp_addr;
 
 	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
 
@@ -629,7 +629,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	}
 
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
-	recv_ctx->hwctx = (struct netxen_ring_ctx *)addr;
+	recv_ctx->hwctx = addr;
 	recv_ctx->hwctx->ctx_id = cpu_to_le32(port);
 	recv_ctx->hwctx->cmd_consumer_offset =
 		cpu_to_le64(recv_ctx->phys_addr +
@@ -648,7 +648,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		goto err_out_free;
 	}
 
-	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
+	tx_ring->desc_head = addr;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -662,7 +662,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 			err = -ENOMEM;
 			goto err_out_free;
 		}
-		rds_ring->desc_head = (struct rcv_desc *)addr;
+		rds_ring->desc_head = addr;
 
 		if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 			rds_ring->crb_rcv_producer =
@@ -683,7 +683,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 			err = -ENOMEM;
 			goto err_out_free;
 		}
-		sds_ring->desc_head = (struct status_desc *)addr;
+		sds_ring->desc_head = addr;
 
 		if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 			sds_ring->crb_sts_consumer =
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 89f7540..abd1693 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -502,7 +502,7 @@ static int add_del_hash_entry(struct pxa168_eth_private *pep,
 	 * Pick the appropriate table, start scanning for free/reusable
 	 * entries at the index obtained by hashing the specified MAC address
 	 */
-	start = (struct addr_table_entry *)(pep->htpr);
+	start = pep->htpr;
 	entry = start + hash_function(mac_addr);
 	for (i = 0; i < HOP_NUMBER; i++) {
 		if (!(le32_to_cpu(entry->lo) & HASH_ENTRY_VALID)) {
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 771bb61..2f69140 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2873,7 +2873,7 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 				     PAGE_SIZE, &qdev->shadow_reg_phy_addr);
 
 	if (qdev->shadow_reg_virt_addr != NULL) {
-		qdev->preq_consumer_index = (u16 *) qdev->shadow_reg_virt_addr;
+		qdev->preq_consumer_index = qdev->shadow_reg_virt_addr;
 		qdev->req_consumer_index_phy_addr_high =
 			MS_64BITS(qdev->shadow_reg_phy_addr);
 		qdev->req_consumer_index_phy_addr_low =
@@ -3114,8 +3114,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 	qdev->small_buf_release_cnt = 8;
 	qdev->lrg_buf_q_producer_index = qdev->num_lbufq_entries - 1;
 	qdev->lrg_buf_release_cnt = 8;
-	qdev->lrg_buf_next_free =
-	    (struct bufq_addr_element *)qdev->lrg_buf_q_virt_addr;
+	qdev->lrg_buf_next_free = qdev->lrg_buf_q_virt_addr;
 	qdev->small_buf_index = 0;
 	qdev->lrg_buf_index = 0;
 	qdev->lrg_buf_free_count = 0;
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index bab041a..c77024f 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -126,7 +126,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 		err = -EIO;
 		goto error;
 	}
-	tmp_tmpl = (struct qlcnic_dump_template_hdr *) tmp_addr;
+	tmp_tmpl = tmp_addr;
 	csum = qlcnic_temp_checksum((uint32_t *) tmp_addr, temp_size);
 	if (csum) {
 		dev_err(&adapter->pdev->dev,
@@ -139,7 +139,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 		err = -EIO;
 		goto error;
 	}
-	tmp_buf = (u32 *) tmp_addr;
+	tmp_buf = tmp_addr;
 	template = (u32 *) ahw->fw_dump.tmpl_hdr;
 	for (i = 0; i < temp_size/sizeof(u32); i++)
 		*template++ = __le32_to_cpu(*tmp_buf++);
@@ -214,7 +214,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 			&hostrq_phys_addr, GFP_KERNEL);
 	if (addr == NULL)
 		return -ENOMEM;
-	prq = (struct qlcnic_hostrq_rx_ctx *)addr;
+	prq = addr;
 
 	addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
 			&cardrsp_phys_addr, GFP_KERNEL);
@@ -222,7 +222,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		err = -ENOMEM;
 		goto out_free_rq;
 	}
-	prsp = (struct qlcnic_cardrsp_rx_ctx *)addr;
+	prsp = addr;
 
 	prq->host_rsp_dma_addr = cpu_to_le64(cardrsp_phys_addr);
 
@@ -380,10 +380,10 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	}
 
 	memset(rq_addr, 0, rq_size);
-	prq = (struct qlcnic_hostrq_tx_ctx *)rq_addr;
+	prq = rq_addr;
 
 	memset(rsp_addr, 0, rsp_size);
-	prsp = (struct qlcnic_cardrsp_tx_ctx *)rsp_addr;
+	prsp = rsp_addr;
 
 	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
 
@@ -493,7 +493,7 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 		goto err_out_free;
 	}
 
-	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
+	tx_ring->desc_head = addr;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -506,7 +506,7 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 			err = -ENOMEM;
 			goto err_out_free;
 		}
-		rds_ring->desc_head = (struct rcv_desc *)addr;
+		rds_ring->desc_head = addr;
 
 	}
 
@@ -522,7 +522,7 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 			err = -ENOMEM;
 			goto err_out_free;
 		}
-		sds_ring->desc_head = (struct status_desc *)addr;
+		sds_ring->desc_head = addr;
 	}
 
 	return 0;
@@ -662,7 +662,7 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 	memset(nic_info_addr, 0, nic_size);
 
-	nic_info = (struct qlcnic_info *) nic_info_addr;
+	nic_info = nic_info_addr;
 	err = qlcnic_issue_cmd(adapter,
 			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
@@ -720,7 +720,7 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 		return -ENOMEM;
 
 	memset(nic_info_addr, 0, nic_size);
-	nic_info = (struct qlcnic_info *)nic_info_addr;
+	nic_info = nic_info_addr;
 
 	nic_info->pci_func = cpu_to_le16(nic->pci_func);
 	nic_info->op_mode = cpu_to_le16(nic->op_mode);
@@ -769,7 +769,7 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 	memset(pci_info_addr, 0, pci_size);
 
-	npar = (struct qlcnic_pci_info *) pci_info_addr;
+	npar = pci_info_addr;
 	err = qlcnic_issue_cmd(adapter,
 			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
@@ -877,7 +877,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 			QLCNIC_CDRP_CMD_GET_ESWITCH_STATS);
 
 	if (!err) {
-		stats = (struct __qlcnic_esw_statistics *)stats_addr;
+		stats = stats_addr;
 		esw_stats->context_id = le16_to_cpu(stats->context_id);
 		esw_stats->version = le16_to_cpu(stats->version);
 		esw_stats->size = le16_to_cpu(stats->size);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 9efc690..8ea8001 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -996,7 +996,7 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 	/* Copy template header first */
 	copy_sz = fw_dump->tmpl_hdr->size;
 	hdr_ptr = (u32 *) fw_dump->tmpl_hdr;
-	data = (u32 *) buffer;
+	data = buffer;
 	for (i = 0; i < copy_sz/sizeof(u32); i++)
 		*data++ = cpu_to_le32(*hdr_ptr++);
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index e965661..ea0f11e 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1672,8 +1672,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	tmpl_hdr->sys_info[1] = adapter->fw_version;
 
 	for (i = 0; i < no_entries; i++) {
-		entry = (struct qlcnic_dump_entry *) ((void *) tmpl_hdr +
-			entry_offset);
+		entry = (void *)tmpl_hdr + entry_offset;
 		if (!(entry->hdr.mask & tmpl_hdr->drv_cap_mask)) {
 			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
 			entry_offset += entry->hdr.offset;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3ab7d2c..0a6c1c9 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1861,7 +1861,7 @@ qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 		return;
 
 	adapter->fhash.fmax = QLCNIC_LB_MAX_FILTERS;
-	adapter->fhash.fhead = (struct hlist_head *)head;
+	adapter->fhash.fhead = head;
 
 	for (i = 0; i < adapter->fhash.fmax; i++)
 		INIT_HLIST_HEAD(&adapter->fhash.fhead[i]);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 930ae45..be89610 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3096,7 +3096,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	if (rx_ring->lbq_len) {
 		cqicb->flags |= FLAGS_LL;	/* Load lbq values */
 		tmp = (u64)rx_ring->lbq_base_dma;
-		base_indirect_ptr = (__le64 *) rx_ring->lbq_base_indirect;
+		base_indirect_ptr = rx_ring->lbq_base_indirect;
 		page_entries = 0;
 		do {
 			*base_indirect_ptr = cpu_to_le64(tmp);
@@ -3120,7 +3120,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	if (rx_ring->sbq_len) {
 		cqicb->flags |= FLAGS_LS;	/* Load sbq values */
 		tmp = (u64)rx_ring->sbq_base_dma;
-		base_indirect_ptr = (__le64 *) rx_ring->sbq_base_indirect;
+		base_indirect_ptr = rx_ring->sbq_base_indirect;
 		page_entries = 0;
 		do {
 			*base_indirect_ptr = cpu_to_le64(tmp);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index df0d2c8..f4d80f9 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -841,7 +841,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			tmp_p_addr = ring->rx_blocks[j].block_dma_addr;
 			tmp_p_addr_next = ring->rx_blocks[next].block_dma_addr;
 
-			pre_rxd_blk = (struct RxD_block *)tmp_v_addr;
+			pre_rxd_blk = tmp_v_addr;
 			pre_rxd_blk->reserved_2_pNext_RxD_block =
 				(unsigned long)tmp_v_addr_next;
 			pre_rxd_blk->pNext_RxD_Blk_physical =
@@ -918,7 +918,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 	mac_control->stats_mem_sz = size;
 
 	tmp_v_addr = mac_control->stats_mem;
-	mac_control->stats_info = (struct stat_block *)tmp_v_addr;
+	mac_control->stats_info = tmp_v_addr;
 	memset(tmp_v_addr, 0, size);
 	DBG_PRINT(INIT_DBG, "%s: Ring Mem PHY: 0x%llx\n",
 		dev_name(&nic->pdev->dev), (unsigned long long)tmp_p_addr);
@@ -2439,7 +2439,7 @@ static void free_tx_buffers(struct s2io_nic *nic)
 
 		spin_lock_irqsave(&fifo->tx_lock, flags);
 		for (j = 0; j < tx_cfg->fifo_len; j++) {
-			txdp = (struct TxD *)fifo->list_info[j].list_virt_addr;
+			txdp = fifo->list_info[j].list_virt_addr;
 			skb = s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);
 			if (skb) {
 				swstats->mem_freed += skb->truesize;
@@ -3075,8 +3075,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 
 	get_info = fifo_data->tx_curr_get_info;
 	memcpy(&put_info, &fifo_data->tx_curr_put_info, sizeof(put_info));
-	txdlp = (struct TxD *)
-		fifo_data->list_info[get_info.offset].list_virt_addr;
+	txdlp = fifo_data->list_info[get_info.offset].list_virt_addr;
 	while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
 	       (get_info.offset != put_info.offset) &&
 	       (txdlp->Host_Control)) {
@@ -3129,8 +3128,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		get_info.offset++;
 		if (get_info.offset == get_info.fifo_len + 1)
 			get_info.offset = 0;
-		txdlp = (struct TxD *)
-			fifo_data->list_info[get_info.offset].list_virt_addr;
+		txdlp = fifo_data->list_info[get_info.offset].list_virt_addr;
 		fifo_data->tx_curr_get_info.offset = get_info.offset;
 	}
 
@@ -4163,7 +4161,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	put_off = (u16)fifo->tx_curr_put_info.offset;
 	get_off = (u16)fifo->tx_curr_get_info.offset;
-	txdp = (struct TxD *)fifo->list_info[put_off].list_virt_addr;
+	txdp = fifo->list_info[put_off].list_virt_addr;
 
 	queue_len = fifo->tx_curr_put_info.fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
@@ -7972,9 +7970,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	/* Initializing the BAR1 address as the start of the FIFO pointer. */
 	for (j = 0; j < MAX_TX_FIFOS; j++) {
-		mac_control->tx_FIFO_start[j] =
-			(struct TxFIFO_element __iomem *)
-			(sp->bar1 + (j * 0x00020000));
+		mac_control->tx_FIFO_start[j] = sp->bar1 + (j * 0x00020000);
 	}
 
 	/*  Driver entry points */
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index fb4721f..a66818e 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -400,7 +400,7 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	u64 generation_end;
 
 	mac_stats = &efx->mac_stats;
-	dma_stats = (u64 *)efx->stats_buffer.addr;
+	dma_stats = efx->stats_buffer.addr;
 
 	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
 	if (generation_end == STATS_GENERATION_INVALID)
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 484f795..658a192 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -482,7 +482,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 		ret = -ENOMEM;
 		goto err_out_cleardev;
 	}
-	sis_priv->tx_ring = (BufferDesc *)ring_space;
+	sis_priv->tx_ring = ring_space;
 	sis_priv->tx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent(pci_dev, RX_TOTAL_SIZE, &ring_dma);
@@ -490,7 +490,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 		ret = -ENOMEM;
 		goto err_unmap_tx;
 	}
-	sis_priv->rx_ring = (BufferDesc *)ring_space;
+	sis_priv->rx_ring = ring_space;
 	sis_priv->rx_ring_dma = ring_dma;
 
 	/* The SiS900-specific entries in the device structure. */
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 2bedc0a..6153cfd 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -418,7 +418,7 @@ static irqreturn_t madgemc_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	}
 
-	dev = (struct net_device *)dev_id;
+	dev = dev_id;
 
 	/* Make sure its really us. -- the Madge way */
 	pending = inb(dev->base_addr + MC_CONTROL_REG0);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 3de4283..1d5091a 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2367,7 +2367,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->irq = pdev->irq;
 	tp = netdev_priv(dev);
-	tp->shared = (struct typhoon_shared *) shared;
+	tp->shared = shared;
 	tp->shared_dma = shared_dma;
 	tp->pdev = pdev;
 	tp->tx_pdev = pdev;
diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 32763b2..857618a 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -582,7 +582,7 @@ __vxge_hw_device_toc_get(void __iomem *bar0)
 		goto exit;
 
 	val64 =	readq(&legacy_reg->toc_first_pointer);
-	toc = (struct vxge_hw_toc_reg __iomem *)(bar0+val64);
+	toc = bar0 + val64;
 exit:
 	return toc;
 }
@@ -600,7 +600,7 @@ __vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev)
 	u32 i;
 	enum vxge_hw_status status = VXGE_HW_OK;
 
-	hldev->legacy_reg = (struct vxge_hw_legacy_reg __iomem *)hldev->bar0;
+	hldev->legacy_reg = hldev->bar0;
 
 	hldev->toc_reg = __vxge_hw_device_toc_get(hldev->bar0);
 	if (hldev->toc_reg  == NULL) {
@@ -609,39 +609,31 @@ __vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev)
 	}
 
 	val64 = readq(&hldev->toc_reg->toc_common_pointer);
-	hldev->common_reg =
-	(struct vxge_hw_common_reg __iomem *)(hldev->bar0 + val64);
+	hldev->common_reg = hldev->bar0 + val64;
 
 	val64 = readq(&hldev->toc_reg->toc_mrpcim_pointer);
-	hldev->mrpcim_reg =
-		(struct vxge_hw_mrpcim_reg __iomem *)(hldev->bar0 + val64);
+	hldev->mrpcim_reg = hldev->bar0 + val64;
 
 	for (i = 0; i < VXGE_HW_TITAN_SRPCIM_REG_SPACES; i++) {
 		val64 = readq(&hldev->toc_reg->toc_srpcim_pointer[i]);
-		hldev->srpcim_reg[i] =
-			(struct vxge_hw_srpcim_reg __iomem *)
-				(hldev->bar0 + val64);
+		hldev->srpcim_reg[i] = hldev->bar0 + val64;
 	}
 
 	for (i = 0; i < VXGE_HW_TITAN_VPMGMT_REG_SPACES; i++) {
 		val64 = readq(&hldev->toc_reg->toc_vpmgmt_pointer[i]);
-		hldev->vpmgmt_reg[i] =
-		(struct vxge_hw_vpmgmt_reg __iomem *)(hldev->bar0 + val64);
+		hldev->vpmgmt_reg[i] = hldev->bar0 + val64;
 	}
 
 	for (i = 0; i < VXGE_HW_TITAN_VPATH_REG_SPACES; i++) {
 		val64 = readq(&hldev->toc_reg->toc_vpath_pointer[i]);
-		hldev->vpath_reg[i] =
-			(struct vxge_hw_vpath_reg __iomem *)
-				(hldev->bar0 + val64);
+		hldev->vpath_reg[i] = hldev->bar0 + val64;
 	}
 
 	val64 = readq(&hldev->toc_reg->toc_kdfc);
 
 	switch (VXGE_HW_TOC_GET_KDFC_INITIAL_BIR(val64)) {
 	case 0:
-		hldev->kdfc = (u8 __iomem *)(hldev->bar0 +
-			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
+		hldev->kdfc = hldev->bar0 + VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64) ;
 		break;
 	default:
 		break;
@@ -1024,7 +1016,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 	}
 
 	val64 = readq(&toc->toc_common_pointer);
-	common_reg = (struct vxge_hw_common_reg __iomem *)(bar0 + val64);
+	common_reg = bar0 + val64;
 
 	status = __vxge_hw_device_vpath_reset_in_prog_check(
 		(u64 __iomem *)&common_reg->vpath_rst_in_prog);
@@ -1044,8 +1036,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 
 		val64 = readq(&toc->toc_vpmgmt_pointer[i]);
 
-		vpmgmt_reg = (struct vxge_hw_vpmgmt_reg __iomem *)
-				(bar0 + val64);
+		vpmgmt_reg = bar0 + val64;
 
 		hw_info->func_id = __vxge_hw_vpath_func_id_get(vpmgmt_reg);
 		if (__vxge_hw_device_access_rights_get(hw_info->host_type,
@@ -1054,8 +1045,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 
 			val64 = readq(&toc->toc_mrpcim_pointer);
 
-			mrpcim_reg = (struct vxge_hw_mrpcim_reg __iomem *)
-					(bar0 + val64);
+			mrpcim_reg = bar0 + val64;
 
 			writeq(0, &mrpcim_reg->xgmac_gen_fw_memo_mask);
 			wmb();
@@ -1064,8 +1054,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 		val64 = readq(&toc->toc_vpath_pointer[i]);
 
 		spin_lock_init(&vpath.lock);
-		vpath.vp_reg = (struct vxge_hw_vpath_reg __iomem *)
-			       (bar0 + val64);
+		vpath.vp_reg = bar0 + val64;
 		vpath.vp_open = VXGE_HW_VP_NOT_OPEN;
 
 		status = __vxge_hw_vpath_pci_func_mode_get(&vpath, hw_info);
@@ -1088,8 +1077,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 			continue;
 
 		val64 = readq(&toc->toc_vpath_pointer[i]);
-		vpath.vp_reg = (struct vxge_hw_vpath_reg __iomem *)
-			       (bar0 + val64);
+		vpath.vp_reg = bar0 + val64;
 		vpath.vp_open = VXGE_HW_VP_NOT_OPEN;
 
 		status =  __vxge_hw_vpath_addr_get(&vpath,
@@ -2140,8 +2128,7 @@ __vxge_hw_ring_mempool_item_alloc(struct vxge_hw_mempool *mempoolh,
 					memblock_index, item,
 					&memblock_item_idx);
 
-		rxdp = (struct vxge_hw_ring_rxd_1 *)
-				ring->channel.reserve_arr[reserve_index];
+		rxdp = ring->channel.reserve_arr[reserve_index];
 
 		uld_priv = ((u8 *)rxdblock_priv + ring->rxd_priv_size * i);
 
@@ -4880,8 +4867,7 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
 		goto vpath_open_exit8;
 	}
 
-	vpath->hw_stats = (struct vxge_hw_vpath_stats_hw_info *)vpath->
-			stats_block->memblock;
+	vpath->hw_stats = vpath->stats_block->memblock;
 	memset(vpath->hw_stats, 0,
 		sizeof(struct vxge_hw_vpath_stats_hw_info));
 
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index f935170..ad64ce0 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -1309,7 +1309,7 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_completed(
 
 	vxge_hw_channel_dtr_try_complete(channel, rxdh);
 
-	rxdp = (struct vxge_hw_ring_rxd_1 *)*rxdh;
+	rxdp = *rxdh;
 	if (rxdp == NULL) {
 		status = VXGE_HW_INF_NO_MORE_COMPLETED_DESCRIPTORS;
 		goto exit;
@@ -1565,7 +1565,7 @@ void vxge_hw_fifo_txdl_post(struct __vxge_hw_fifo *fifo, void *txdlh)
 	channel = &fifo->channel;
 
 	txdl_priv = __vxge_hw_fifo_txdl_priv(fifo, txdlh);
-	txdp_first = (struct vxge_hw_fifo_txd *)txdlh;
+	txdp_first = txdlh;
 
 	txdp_last = (struct vxge_hw_fifo_txd *)txdlh  +  (txdl_priv->frags - 1);
 	txdp_last->control_0 |=
@@ -1631,7 +1631,7 @@ enum vxge_hw_status vxge_hw_fifo_txdl_next_completed(
 
 	vxge_hw_channel_dtr_try_complete(channel, txdlh);
 
-	txdp = (struct vxge_hw_fifo_txd *)*txdlh;
+	txdp = *txdlh;
 	if (txdp == NULL) {
 		status = VXGE_HW_INF_NO_MORE_COMPLETED_DESCRIPTORS;
 		goto exit;
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index 1c65d1c..850fc84 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -755,7 +755,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 
 	dsr_rx = cpc_readb(card->hw.scabase + DSR_RX(ch));
 
-	cpc_tty = (st_cpc_tty_area *)pc300dev->cpc_tty; 
+	cpc_tty = pc300dev->cpc_tty; 
 
 	while (1) { 
 		rx_len = 0;
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 9cb4cdc..bbb8c65 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -252,11 +252,11 @@ static void xemaclite_aligned_write(void *src_ptr, u32 *dest_ptr,
 	u16 *from_u16_ptr, *to_u16_ptr;
 
 	to_u32_ptr = dest_ptr;
-	from_u16_ptr = (u16 *) src_ptr;
+	from_u16_ptr = src_ptr;
 	align_buffer = 0;
 
 	for (; length > 3; length -= 4) {
-		to_u16_ptr = (u16 *) ((void *) &align_buffer);
+		to_u16_ptr = (u16 *)&align_buffer;
 		*to_u16_ptr++ = *from_u16_ptr++;
 		*to_u16_ptr++ = *from_u16_ptr++;
 
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index ec47e22..3e5ac60 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -442,19 +442,19 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 	ring_space = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_cleardev;
-	np->tx_ring = (struct yellowfin_desc *)ring_space;
+	np->tx_ring = ring_space;
 	np->tx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent(pdev, RX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_unmap_tx;
-	np->rx_ring = (struct yellowfin_desc *)ring_space;
+	np->rx_ring = ring_space;
 	np->rx_ring_dma = ring_dma;
 
 	ring_space = pci_alloc_consistent(pdev, STATUS_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_unmap_rx;
-	np->tx_status = (struct tx_status_words *)ring_space;
+	np->tx_status = ring_space;
 	np->tx_status_dma = ring_dma;
 
 	if (dev->mem_start)
-- 
1.7.6.rc0

