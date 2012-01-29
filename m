From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: Remove unnecessary k.alloc/v.alloc
 OOM messages
Date: Sun, 29 Jan 2012 14:56:23 -0800
Message-ID: <1327877783.2652.10.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc failures use dump_stack so emitting an additional
out-of-memory message is an unnecessary duplication.

Remove the allocation failure messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
Let me know if this should be broken into multiple patches.
Generated -U4 to be able to see more of the alloc calls.
Compiled tested x86 only.

 drivers/net/bonding/bond_alb.c                     |   12 +++-------
 drivers/net/can/slcan.c                            |    4 +--
 drivers/net/ethernet/amd/ni65.c                    |    4 +--
 drivers/net/ethernet/apple/bmac.c                  |    4 +--
 drivers/net/ethernet/apple/mace.c                  |    4 +--
 drivers/net/ethernet/broadcom/bnx2.c               |    4 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    4 +--
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c    |   21 ++-----------------
 drivers/net/ethernet/cisco/enic/enic_main.c        |    1 -
 drivers/net/ethernet/cisco/enic/vnic_rq.c          |    4 +--
 drivers/net/ethernet/cisco/enic/vnic_wq.c          |    4 +--
 drivers/net/ethernet/i825xx/lp486e.c               |    2 -
 drivers/net/ethernet/ibm/emac/rgmii.c              |    5 +---
 drivers/net/ethernet/ibm/emac/tah.c                |    5 +---
 drivers/net/ethernet/ibm/emac/zmii.c               |    5 +---
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    4 +--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    4 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    6 +----
 drivers/net/ethernet/korina.c                      |    1 -
 drivers/net/ethernet/marvell/pxa168_eth.c          |   10 +++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    5 +--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |    6 +---
 drivers/net/ethernet/micrel/ks8851_mll.c           |    4 +--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    9 ++-----
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |   12 ++--------
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c        |    4 +--
 drivers/net/ethernet/sis/sis900.c                  |    1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    5 +--
 drivers/net/ethernet/sun/cassini.c                 |    1 -
 drivers/net/ethernet/sun/sunvnet.c                 |    9 ++-----
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |    5 +--
 drivers/net/hamradio/yam.c                         |    1 -
 drivers/net/hippi/rrunner.c                        |    8 +------
 drivers/net/irda/donauboe.c                        |    2 -
 drivers/net/netconsole.c                           |    8 +-----
 drivers/net/ppp/pptp.c                             |    4 +--
 drivers/net/slip/slip.c                            |    4 +--
 drivers/net/tokenring/3c359.c                      |    4 ---
 drivers/net/tokenring/madgemc.c                    |    1 -
 drivers/net/vmxnet3/vmxnet3_drv.c                  |   15 ++-----------
 drivers/net/wan/c101.c                             |    4 +--
 drivers/net/wan/dscc4.c                            |    8 +-----
 drivers/net/wan/lmc/lmc_main.c                     |    1 -
 drivers/net/wan/n2.c                               |    4 +--
 drivers/net/wan/pc300too.c                         |    1 -
 drivers/net/wan/pci200syn.c                        |    1 -
 drivers/net/wan/wanxl.c                            |    1 -
 drivers/net/wan/x25_asy.c                          |    4 +--
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    5 +---
 drivers/net/wireless/hostap/hostap_hw.c            |   18 +++++-----------
 drivers/net/wireless/ipw2x00/ipw2100.c             |    5 +---
 drivers/net/wireless/libertas/if_cs.c              |    5 +--
 drivers/net/wireless/libertas/if_usb.c             |    4 +--
 drivers/net/wireless/libertas_tf/if_usb.c          |    4 +--
 drivers/net/wireless/mwifiex/pcie.c                |    4 +--
 drivers/net/wireless/mwifiex/sdio.c                |    4 +--
 drivers/net/wireless/orinoco/main.c                |    6 +---
 drivers/net/wireless/prism54/islpci_mgt.c          |    6 +---
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    5 +---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    6 +---
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    5 +---
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    5 +---
 drivers/net/xen-netback/netback.c                  |    4 +--
 63 files changed, 81 insertions(+), 245 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index f820b26..9abfde4 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -179,13 +179,11 @@ static int tlb_initialize(struct bonding *bond)
 	struct tlb_client_info *new_hashtbl;
 	int i;
 
 	new_hashtbl = kzalloc(size, GFP_KERNEL);
-	if (!new_hashtbl) {
-		pr_err("%s: Error: Failed to allocate TLB hash table\n",
-		       bond->dev->name);
+	if (!new_hashtbl)
 		return -1;
-	}
+
 	_lock_tx_hashtbl_bh(bond);
 
 	bond_info->tx_hashtbl = new_hashtbl;
 
@@ -783,13 +781,11 @@ static int rlb_initialize(struct bonding *bond)
 	int size = RLB_HASH_TABLE_SIZE * sizeof(struct rlb_client_info);
 	int i;
 
 	new_hashtbl = kmalloc(size, GFP_KERNEL);
-	if (!new_hashtbl) {
-		pr_err("%s: Error: Failed to allocate RLB hash table\n",
-		       bond->dev->name);
+	if (!new_hashtbl)
 		return -1;
-	}
+
 	_lock_rx_hashtbl_bh(bond);
 
 	bond_info->rx_hashtbl = new_hashtbl;
 
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 3f1ebcc..2659b23 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -638,12 +638,10 @@ static int __init slcan_init(void)
 	printk(banner);
 	printk(KERN_INFO "slcan: %d dynamic interface channels.\n", maxdev);
 
 	slcan_devs = kzalloc(sizeof(struct net_device *)*maxdev, GFP_KERNEL);
-	if (!slcan_devs) {
-		printk(KERN_ERR "slcan: can't allocate slcan device array!\n");
+	if (!slcan_devs)
 		return -ENOMEM;
-	}
 
 	/* Fill in our line protocol discipline, and register it */
 	status = tty_register_ldisc(N_SLCAN, &slc_ldisc);
 	if (status)  {
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 6e6aa72..735c213 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -620,12 +620,10 @@ static void *ni65_alloc_mem(struct net_device *dev,char *what,int size,int type)
 		ptr = skb->data;
 	}
 	else {
 		ret = ptr = kmalloc(T_BUF_SIZE,GFP_KERNEL | GFP_DMA);
-		if(!ret) {
-			printk(KERN_WARNING "%s: unable to allocate %s memory.\n",dev->name,what);
+		if(!ret)
 			return NULL;
-		}
 	}
 	if( (u32) virt_to_phys(ptr+size) > 0x1000000) {
 		printk(KERN_WARNING "%s: unable to allocate %s memory in lower 16MB!\n",dev->name,what);
 		if(type)
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index d070b22..4108ac8 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1659,12 +1659,10 @@ static struct macio_driver bmac_driver =
 static int __init bmac_init(void)
 {
 	if (bmac_emergency_rxbuf == NULL) {
 		bmac_emergency_rxbuf = kmalloc(RX_BUFLEN, GFP_KERNEL);
-		if (bmac_emergency_rxbuf == NULL) {
-			printk(KERN_ERR "BMAC: can't allocate emergency RX buffer\n");
+		if (bmac_emergency_rxbuf == NULL)
 			return -ENOMEM;
-		}
 	}
 
 	return macio_register_driver(&bmac_driver);
 }
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index bec87bd..45ba18e 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -135,12 +135,10 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 	 * never have more than one MACE in the system anyway)
 	 */
 	if (dummy_buf == NULL) {
 		dummy_buf = kmalloc(RX_BUFLEN+2, GFP_KERNEL);
-		if (dummy_buf == NULL) {
-			printk(KERN_ERR "MACE: couldn't allocate dummy buffer\n");
+		if (dummy_buf == NULL)
 			return -ENOMEM;
-		}
 	}
 
 	if (macio_request_resources(mdev, "mace")) {
 		printk(KERN_ERR "MACE: can't request IO resources !\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 021fb81..0a4c540 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2624,12 +2624,10 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 	u32 good_mbuf_cnt;
 	u32 val;
 
 	good_mbuf = kmalloc(512 * sizeof(u16), GFP_KERNEL);
-	if (good_mbuf == NULL) {
-		pr_err("Failed to allocate memory in %s\n", __func__);
+	if (good_mbuf == NULL)
 		return -ENOMEM;
-	}
 
 	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
 		BNX2_MISC_ENABLE_SET_BITS_RX_MBUF_ENABLE);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fea9615..582cbcf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10893,12 +10893,10 @@ static inline void be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 #define BNX2X_ALLOC_AND_SET(arr, lbl, func)				\
 do {									\
 	u32 len = be32_to_cpu(fw_hdr->arr.len);				\
 	bp->arr = kmalloc(len, GFP_KERNEL);				\
-	if (!bp->arr) {							\
-		pr_err("Failed to allocate %d bytes for "#arr"\n", len); \
+	if (!bp->arr)							\
 		goto lbl;						\
-	}								\
 	func(bp->firmware->data + be32_to_cpu(fw_hdr->arr.offset),	\
 	     (u8 *)bp->arr, len);					\
 } while (0)
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index 592ad39..c9fdceb 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -61,10 +61,8 @@ bnad_debugfs_open_fwtrc(struct inode *inode, struct file *file)
 	fw_debug->debug_buffer = kzalloc(fw_debug->buffer_len, GFP_KERNEL);
 	if (!fw_debug->debug_buffer) {
 		kfree(fw_debug);
 		fw_debug = NULL;
-		pr_warn("bna %s: Failed to allocate fwtrc buffer\n",
-			pci_name(bnad->pcidev));
 		return -ENOMEM;
 	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -104,10 +102,8 @@ bnad_debugfs_open_fwsave(struct inode *inode, struct file *file)
 	fw_debug->debug_buffer = kzalloc(fw_debug->buffer_len, GFP_KERNEL);
 	if (!fw_debug->debug_buffer) {
 		kfree(fw_debug);
 		fw_debug = NULL;
-		pr_warn("bna %s: Failed to allocate fwsave buffer\n",
-			pci_name(bnad->pcidev));
 		return -ENOMEM;
 	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -207,10 +203,8 @@ bnad_debugfs_open_drvinfo(struct inode *inode, struct file *file)
 	drv_info->debug_buffer = kzalloc(drv_info->buffer_len, GFP_KERNEL);
 	if (!drv_info->debug_buffer) {
 		kfree(drv_info);
 		drv_info = NULL;
-		pr_warn("bna %s: Failed to allocate drv info buffer\n",
-			pci_name(bnad->pcidev));
 		return -ENOMEM;
 	}
 
 	mutex_lock(&bnad->conf_mutex);
@@ -347,13 +341,10 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 	void *kern_buf;
 
 	/* Allocate memory to store the user space buf */
 	kern_buf = kzalloc(nbytes, GFP_KERNEL);
-	if (!kern_buf) {
-		pr_warn("bna %s: Failed to allocate user buffer\n",
-			pci_name(bnad->pcidev));
+	if (!kern_buf)
 		return -ENOMEM;
-	}
 
 	if (copy_from_user(kern_buf, (void  __user *)buf, nbytes)) {
 		kfree(kern_buf);
 		return -ENOMEM;
@@ -372,13 +363,10 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 	bnad->regdata = NULL;
 	bnad->reglen = 0;
 
 	bnad->regdata = kzalloc(len << 2, GFP_KERNEL);
-	if (!bnad->regdata) {
-		pr_warn("bna %s: Failed to allocate regrd buffer\n",
-			pci_name(bnad->pcidev));
+	if (!bnad->regdata)
 		return -ENOMEM;
-	}
 
 	bnad->reglen = len << 2;
 	rb = bfa_ioc_bar0(ioc);
 	addr &= BFA_REG_ADDRMSK(ioc);
@@ -420,13 +408,10 @@ bnad_debugfs_write_regwr(struct file *file, const char __user *buf,
 	void *kern_buf;
 
 	/* Allocate memory to store the user space buf */
 	kern_buf = kzalloc(nbytes, GFP_KERNEL);
-	if (!kern_buf) {
-		pr_warn("bna %s: Failed to allocate user buffer\n",
-			pci_name(bnad->pcidev));
+	if (!kern_buf)
 		return -ENOMEM;
-	}
 
 	if (copy_from_user(kern_buf, (void  __user *)buf, nbytes)) {
 		kfree(kern_buf);
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ab3f67f..07df137 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2387,9 +2387,8 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	/* Allocate structure for port profiles */
 	enic->pp = kcalloc(num_pps, sizeof(*enic->pp), GFP_KERNEL);
 	if (!enic->pp) {
-		pr_err("port profile alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_out_disable_sriov_pp;
 	}
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index 34105e0..7e1488f 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -37,12 +37,10 @@ static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 	vdev = rq->vdev;
 
 	for (i = 0; i < blks; i++) {
 		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ(count), GFP_ATOMIC);
-		if (!rq->bufs[i]) {
-			pr_err("Failed to alloc rq_bufs\n");
+		if (!rq->bufs[i])
 			return -ENOMEM;
-		}
 	}
 
 	for (i = 0; i < blks; i++) {
 		buf = rq->bufs[i];
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index df61bd9..5e0d7a2 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -37,12 +37,10 @@ static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 	vdev = wq->vdev;
 
 	for (i = 0; i < blks; i++) {
 		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ(count), GFP_ATOMIC);
-		if (!wq->bufs[i]) {
-			pr_err("Failed to alloc wq_bufs\n");
+		if (!wq->bufs[i])
 			return -ENOMEM;
-		}
 	}
 
 	for (i = 0; i < blks; i++) {
 		buf = wq->bufs[i];
diff --git a/drivers/net/ethernet/i825xx/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
index 414044b..02df5f5 100644
--- a/drivers/net/ethernet/i825xx/lp486e.c
+++ b/drivers/net/ethernet/i825xx/lp486e.c
@@ -453,10 +453,8 @@ init_rx_bufs(struct net_device *dev, int num) {
 				lp->rbd_tail = rbd;
 			}
 
 			rfd->rbd = rbd;
-		} else {
-			printk("Could not kmalloc rbd\n");
 		}
 	}
 	lp->rbd_tail->next = rfd->rbd;
 #endif
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 4fa53f3..39fe102 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -236,13 +236,10 @@ static int __devinit rgmii_probe(struct platform_device *ofdev)
 	int rc;
 
 	rc = -ENOMEM;
 	dev = kzalloc(sizeof(struct rgmii_instance), GFP_KERNEL);
-	if (dev == NULL) {
-		printk(KERN_ERR "%s: could not allocate RGMII device!\n",
-		       np->full_name);
+	if (dev == NULL)
 		goto err_gone;
-	}
 
 	mutex_init(&dev->lock);
 	dev->ofdev = ofdev;
 
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index 5f51bf7..b979359 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -95,13 +95,10 @@ static int __devinit tah_probe(struct platform_device *ofdev)
 	int rc;
 
 	rc = -ENOMEM;
 	dev = kzalloc(sizeof(struct tah_instance), GFP_KERNEL);
-	if (dev == NULL) {
-		printk(KERN_ERR "%s: could not allocate TAH device!\n",
-		       np->full_name);
+	if (dev == NULL)
 		goto err_gone;
-	}
 
 	mutex_init(&dev->lock);
 	dev->ofdev = ofdev;
 
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index 97449e7..4d9e9e9 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -239,13 +239,10 @@ static int __devinit zmii_probe(struct platform_device *ofdev)
 	int rc;
 
 	rc = -ENOMEM;
 	dev = kzalloc(sizeof(struct zmii_instance), GFP_KERNEL);
-	if (dev == NULL) {
-		printk(KERN_ERR "%s: could not allocate ZMII device!\n",
-		       np->full_name);
+	if (dev == NULL)
 		goto err_gone;
-	}
 
 	mutex_init(&dev->lock);
 	dev->ofdev = ofdev;
 	dev->mode = PHY_MODE_NA;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index e8a4759..afa9151 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -729,12 +729,10 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 	eeprom.len = ops->get_eeprom_len(netdev);
 	eeprom.offset = 0;
 
 	data = kmalloc(eeprom.len, GFP_KERNEL);
-	if (!data) {
-		pr_err("Unable to allocate memory to dump EEPROM data\n");
+	if (!data)
 		return;
-	}
 
 	ops->get_eeprom(netdev, &eeprom, data);
 
 	csum_old = (data[EEPROM_CHECKSUM_REG * 2]) +
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 9bd5faf..0024788 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1135,12 +1135,10 @@ ixgb_set_multi(struct net_device *netdev)
 	} else {
 		u8 *mta = kmalloc(IXGB_MAX_NUM_MULTICAST_ADDRESSES *
 			      ETH_ALEN, GFP_ATOMIC);
 		u8 *addr;
-		if (!mta) {
-			pr_err("allocation of multicast memory failed\n");
+		if (!mta)
 			goto alloc_failed;
-		}
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
 		addr = mta;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index bed411b..f3bc933 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2516,14 +2516,10 @@ int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbevf_rx_buffer) * rx_ring->count;
 	rx_ring->rx_buffer_info = vzalloc(size);
-	if (!rx_ring->rx_buffer_info) {
-		hw_dbg(&adapter->hw,
-		       "Unable to vmalloc buffer memory for "
-		       "the receive descriptor ring\n");
+	if (!rx_ring->rx_buffer_info)
 		goto alloc_failed;
-	}
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 6ad094f..341d101 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1149,9 +1149,8 @@ static int korina_probe(struct platform_device *pdev)
 	}
 
 	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
 	if (!lp->td_ring) {
-		printk(KERN_ERR DRV_NAME ": cannot allocate descriptors\n");
 		rc = -ENXIO;
 		goto probe_err_td_ring;
 	}
 
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 953ba58..92b4b4e 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1016,12 +1016,11 @@ static int rxq_init(struct net_device *dev)
 
 	/* Allocate RX skb rings */
 	pep->rx_skb = kmalloc(sizeof(*pep->rx_skb) * pep->rx_ring_size,
 			     GFP_KERNEL);
-	if (!pep->rx_skb) {
-		printk(KERN_ERR "%s: Cannot alloc RX skb ring\n", dev->name);
+	if (!pep->rx_skb)
 		return -ENOMEM;
-	}
+
 	/* Allocate RX ring */
 	pep->rx_desc_count = 0;
 	size = pep->rx_ring_size * sizeof(struct rx_desc);
 	pep->rx_desc_area_size = size;
@@ -1080,12 +1079,11 @@ static int txq_init(struct net_device *dev)
 	int tx_desc_num = pep->tx_ring_size;
 
 	pep->tx_skb = kmalloc(sizeof(*pep->tx_skb) * pep->tx_ring_size,
 			     GFP_KERNEL);
-	if (!pep->tx_skb) {
-		printk(KERN_ERR "%s: Cannot alloc TX skb ring\n", dev->name);
+	if (!pep->tx_skb)
 		return -ENOMEM;
-	}
+
 	/* Allocate TX ring */
 	pep->tx_desc_count = 0;
 	size = pep->tx_ring_size * sizeof(struct tx_desc);
 	pep->tx_desc_area_size = size;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 971d4b6..f61d0e0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -280,12 +280,11 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 
 	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
 					sizeof(struct skb_frag_struct));
 	ring->rx_info = vmalloc(tmp);
-	if (!ring->rx_info) {
-		en_err(priv, "Failed allocating rx_info ring\n");
+	if (!ring->rx_info)
 		return -ENOMEM;
-	}
+
 	en_dbg(DRV, priv, "Allocated rx_info ring at addr:%p size:%d\n",
 		 ring->rx_info, tmp);
 
 	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 9ef9038..ff32505 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -70,18 +70,16 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	spin_lock_init(&ring->comp_lock);
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
 	ring->tx_info = vmalloc(tmp);
-	if (!ring->tx_info) {
-		en_err(priv, "Failed allocating tx_info ring\n");
+	if (!ring->tx_info)
 		return -ENOMEM;
-	}
+
 	en_dbg(DRV, priv, "Allocated tx_info ring at addr:%p size:%d\n",
 		 ring->tx_info, tmp);
 
 	ring->bounce_buf = kmalloc(MAX_DESC_SIZE, GFP_KERNEL);
 	if (!ring->bounce_buf) {
-		en_err(priv, "Failed allocating bounce buffer\n");
 		err = -ENOMEM;
 		goto err_tx;
 	}
 	ring->buf_size = ALIGN(size * ring->stride, MLX4_EN_PAGE_SIZE);
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..98cf5e9 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1500,12 +1500,10 @@ static int ks_hw_init(struct ks_net *ks)
 	ks->all_mcast = 0;
 	ks->mcast_lst_size = 0;
 
 	ks->frame_head_info = kmalloc(MHEADER_SIZE, GFP_KERNEL);
-	if (!ks->frame_head_info) {
-		pr_err("Error: Fail to allocate frame memory\n");
+	if (!ks->frame_head_info)
 		return false;
-	}
 
 	ks_set_mac(ks, KS_DEFAULT_MAC_ADDRESS);
 	return true;
 }
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3ead111..0217991 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1586,12 +1586,10 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 	int desNo;
 
 	size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
 	tx_ring->buffer_info = vzalloc(size);
-	if (!tx_ring->buffer_info) {
-		pr_err("Unable to allocate memory for the buffer information\n");
+	if (!tx_ring->buffer_info)
 		return -ENOMEM;
-	}
 
 	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
 
 	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
@@ -1635,12 +1633,11 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 	int desNo;
 
 	size = (int)sizeof(struct pch_gbe_buffer) * rx_ring->count;
 	rx_ring->buffer_info = vzalloc(size);
-	if (!rx_ring->buffer_info) {
-		pr_err("Unable to allocate memory for the receive descriptor ring\n");
+	if (!rx_ring->buffer_info)
 		return -ENOMEM;
-	}
+
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
 	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index a8259cc..094d26c 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -279,15 +279,12 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			break;
 
 		}
 		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
-		if (rds_ring->rx_buf_arr == NULL) {
-			printk(KERN_ERR "%s: Failed to allocate "
-				"rx buffer ring %d\n",
-				netdev->name, ring);
+		if (rds_ring->rx_buf_arr == NULL)
 			/* free whatever was already allocated */
 			goto err_out;
-		}
+
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
 		 * and put them in the queues.
@@ -479,13 +476,10 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter)
 		return -EIO;
 	}
 
 	buf = kcalloc(n, sizeof(struct crb_addr_pair), GFP_KERNEL);
-	if (buf == NULL) {
-		printk("%s: netxen_pinit_from_rom: Unable to calloc memory.\n",
-				netxen_nic_driver_name);
+	if (buf == NULL)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < n; i++) {
 		if (netxen_rom_fast_read(adapter, 8*i + 4*offset, &val) != 0 ||
 		netxen_rom_fast_read(adapter, 8*i + 4*offset + 4, &addr) != 0) {
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index fca804f..58185b6 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -1823,12 +1823,10 @@ void ql_dump_hw_cb(struct ql_adapter *qdev, int size, u32 bit, u16 q_id)
 
 	pr_err("%s: Enter\n", __func__);
 
 	ptr = kmalloc(size, GFP_ATOMIC);
-	if (ptr == NULL) {
-		pr_err("%s: Couldn't allocate a buffer\n", __func__);
+	if (ptr == NULL)
 		return;
-	}
 
 	if (ql_write_cfg(qdev, ptr, size, bit, q_id)) {
 		pr_err("%s: Failed to upload control block!\n", __func__);
 		goto fail_it;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index c8efc70..91c4468 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -618,9 +618,8 @@ static int __devinit sis900_mii_probe(struct net_device * net_dev)
 			continue;
 		}
 
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
-			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
 			mii_phy = sis_priv->first_mii;
 			while (mii_phy) {
 				struct mii_phy *phy;
 				phy = mii_phy;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..ffc7581 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -953,12 +953,11 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
-	if (unlikely(priv->tm == NULL)) {
-		pr_err("%s: ERROR: timer memory alloc failed\n", __func__);
+	if (unlikely(priv->tm == NULL))
 		return -ENOMEM;
-	}
+
 	priv->tm->freq = tmrate;
 
 	/* Test if the external timer can be actually used.
 	 * In case of failure continue without timer. */
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index f459c3a..961b56a 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -834,9 +834,8 @@ static int cas_saturn_firmware_init(struct cas *cp)
 	cp->fw_size = fw->size - 2;
 	cp->fw_data = vmalloc(cp->fw_size);
 	if (!cp->fw_data) {
 		err = -ENOMEM;
-		pr_err("\"%s\" Failed %d\n", fw_name, err);
 		goto out;
 	}
 	memcpy(cp->fw_data, &fw->data[2], cp->fw_size);
 out:
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 8c6c059..2896f6e 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -948,12 +948,11 @@ static int __devinit vnet_port_alloc_tx_bufs(struct vnet_port *port)
 		void *buf = kzalloc(ETH_FRAME_LEN + 8, GFP_KERNEL);
 		int map_len = (ETH_FRAME_LEN + 7) & ~7;
 
 		err = -ENOMEM;
-		if (!buf) {
-			pr_err("TX buffer allocation failure\n");
+		if (!buf)
 			goto err_out;
-		}
+
 		err = -EFAULT;
 		if ((unsigned long)buf & (8UL - 1)) {
 			pr_err("TX buffer misaligned\n");
 			kfree(buf);
@@ -1164,12 +1163,10 @@ static int __devinit vnet_port_probe(struct vio_dev *vdev,
 	}
 
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
 	err = -ENOMEM;
-	if (!port) {
-		pr_err("Cannot allocate vnet_port\n");
+	if (!port)
 		goto err_out_put_mdesc;
-	}
 
 	for (i = 0; i < ETH_ALEN; i++)
 		port->raddr[i] = (*rmac >> (5 - i) * 8) & 0xff;
 
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index fd4ed7f..5c14f82 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1620,12 +1620,11 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 		target->eurus_index = i;
 		kfree(target->hwinfo);
 		target->hwinfo = kzalloc(be16_to_cpu(scan_info->size),
 					 GFP_KERNEL);
-		if (!target->hwinfo) {
-			pr_info("%s: kzalloc failed\n", __func__);
+		if (!target->hwinfo)
 			continue;
-		}
+
 		/* copy hw scan info */
 		memcpy(target->hwinfo, scan_info, scan_info->size);
 		target->essid_len = strnlen(scan_info->essid,
 					    sizeof(scan_info->essid));
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 96a98d2..6963277 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -402,9 +402,8 @@ static unsigned char *add_mcs(unsigned char *bits, int bitrate,
 	}
 
 	/* Allocate a new mcs */
 	if ((p = kmalloc(sizeof(struct yam_mcs), GFP_KERNEL)) == NULL) {
-		printk(KERN_WARNING "YAM: no memory to allocate mcs\n");
 		release_firmware(fw);
 		return NULL;
 	}
 	memcpy(p->bits, bits, YAM_FPGA_SIZE);
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index e68c941..2a51363 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1599,14 +1599,10 @@ static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 			return -EPERM;
 		}
 
 		image = kmalloc(EEPROM_WORDS * sizeof(u32), GFP_KERNEL);
-		if (!image){
-			printk(KERN_ERR "%s: Unable to allocate memory "
-			       "for EEPROM image\n", dev->name);
+		if (!image)
 			return -ENOMEM;
-		}
-
 
 		if (rrpriv->fw_running){
 			printk("%s: Firmware already running\n", dev->name);
 			error = -EPERM;
@@ -1636,10 +1632,8 @@ static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 		image = kmalloc(EEPROM_WORDS * sizeof(u32), GFP_KERNEL);
 		oldimage = kmalloc(EEPROM_WORDS * sizeof(u32), GFP_KERNEL);
 		if (!image || !oldimage) {
-			printk(KERN_ERR "%s: Unable to allocate memory "
-			       "for EEPROM image\n", dev->name);
 			error = -ENOMEM;
 			goto wf_out;
 		}
 
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 64f403d..617a446 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1607,9 +1607,8 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
   /* Allocate twice the size to guarantee alignment */
   self->ringbuf = kmalloc(OBOE_RING_LEN << 1, GFP_KERNEL);
   if (!self->ringbuf)
     {
-      printk (KERN_ERR DRIVER_NAME ": can't allocate DMA buffers\n");
       err = -ENOMEM;
       goto freeregion;
     }
 
@@ -1646,9 +1645,8 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
     }
 
   if (!ok)
     {
-      printk (KERN_ERR DRIVER_NAME ": can't allocate rx/tx buffers\n");
       err = -ENOMEM;
       goto freebufs;
     }
 
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index e888202..f9347ea 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -168,12 +168,10 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	 * Allocate and initialize with defaults.
 	 * Note that these targets get their config_item fields zeroed-out.
 	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
-	if (!nt) {
-		printk(KERN_ERR "netconsole: failed to allocate memory\n");
+	if (!nt)
 		goto fail;
-	}
 
 	nt->np.name = "netconsole";
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
@@ -550,12 +548,10 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	 * Allocate and initialize with defaults.
 	 * Target is disabled at creation (enabled == 0).
 	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
-	if (!nt) {
-		printk(KERN_ERR "netconsole: failed to allocate memory\n");
+	if (!nt)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	nt->np.name = "netconsole";
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index df884dd..234cd9d 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -669,12 +669,10 @@ static int __init pptp_init_module(void)
 	int err = 0;
 	pr_info("PPTP driver version " PPTP_DRIVER_VERSION "\n");
 
 	callid_sock = vzalloc((MAX_CALLID + 1) * sizeof(void *));
-	if (!callid_sock) {
-		pr_err("PPTP: cann't allocate memory\n");
+	if (!callid_sock)
 		return -ENOMEM;
-	}
 
 	err = gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
 	if (err) {
 		pr_err("PPTP: can't add gre protocol\n");
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index ba08341..69345df 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -1295,12 +1295,10 @@ static int __init slip_init(void)
 #endif
 
 	slip_devs = kzalloc(sizeof(struct net_device *)*slip_maxdev,
 								GFP_KERNEL);
-	if (!slip_devs) {
-		printk(KERN_ERR "SLIP: Can't allocate slip devices array.\n");
+	if (!slip_devs)
 		return -ENOMEM;
-	}
 
 	/* Fill in our line protocol discipline, and register it */
 	status = tty_register_ldisc(N_SLIP, &sl_ldisc);
 	if (status != 0) {
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index ef9fdf3..d7c292a 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -673,17 +673,13 @@ static int xl_open(struct net_device *dev)
 	 */
 	/* These MUST be on 8 byte boundaries */
 	xl_priv->xl_tx_ring = kzalloc((sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE) + 7, GFP_DMA | GFP_KERNEL);
 	if (xl_priv->xl_tx_ring == NULL) {
-		printk(KERN_WARNING "%s: Not enough memory to allocate tx buffers.\n",
-				     dev->name);
 		free_irq(dev->irq,dev);
 		return -ENOMEM;
 	}
 	xl_priv->xl_rx_ring = kzalloc((sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE) +7, GFP_DMA | GFP_KERNEL);
 	if (xl_priv->xl_rx_ring == NULL) {
-		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
-				     dev->name);
 		free_irq(dev->irq,dev);
 		kfree(xl_priv->xl_tx_ring);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 6153cfd..1cdc034 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -170,9 +170,8 @@ static int __devinit madgemc_probe(struct device *device)
 	dev->netdev_ops = &madgemc_netdev_ops;
 
 	card = kmalloc(sizeof(struct card_info), GFP_KERNEL);
 	if (card==NULL) {
-		printk("madgemc: unable to allocate card struct\n");
 		ret = -ENOMEM;
 		goto getout1;
 	}
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index be6aa35..87c0b58 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -536,13 +536,10 @@ vmxnet3_tq_create(struct vmxnet3_tx_queue *tq,
 	}
 
 	tq->buf_info = kcalloc(tq->tx_ring.size, sizeof(tq->buf_info[0]),
 			       GFP_KERNEL);
-	if (!tq->buf_info) {
-		printk(KERN_ERR "%s: failed to allocate tx bufinfo\n",
-		       adapter->netdev->name);
+	if (!tq->buf_info)
 		goto err;
-	}
 
 	return 0;
 
 err:
@@ -1518,13 +1515,11 @@ vmxnet3_rq_create(struct vmxnet3_rx_queue *rq, struct vmxnet3_adapter *adapter)
 
 	sz = sizeof(struct vmxnet3_rx_buf_info) * (rq->rx_ring[0].size +
 						   rq->rx_ring[1].size);
 	bi = kzalloc(sz, GFP_KERNEL);
-	if (!bi) {
-		printk(KERN_ERR "%s: failed to allocate rx bufinfo\n",
-		       adapter->netdev->name);
+	if (!bi)
 		goto err;
-	}
+
 	rq->buf_info[0] = bi;
 	rq->buf_info[1] = bi + rq->rx_ring[0].size;
 
 	return 0;
@@ -2963,20 +2958,16 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 							adapter->num_tx_queues);
 
 	adapter->pm_conf = kmalloc(sizeof(struct Vmxnet3_PMConf), GFP_KERNEL);
 	if (adapter->pm_conf == NULL) {
-		printk(KERN_ERR "Failed to allocate memory for %s\n",
-			pci_name(pdev));
 		err = -ENOMEM;
 		goto err_alloc_pm;
 	}
 
 #ifdef VMXNET3_RSS
 
 	adapter->rss_conf = kmalloc(sizeof(struct UPT1_RSSConf), GFP_KERNEL);
 	if (adapter->rss_conf == NULL) {
-		printk(KERN_ERR "Failed to allocate memory for %s\n",
-		       pci_name(pdev));
 		err = -ENOMEM;
 		goto err_alloc_rss;
 	}
 #endif /* VMXNET3_RSS */
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 54f995f..09a5075 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -324,12 +324,10 @@ static int __init c101_run(unsigned long irq, unsigned long winbase)
 		return -ENODEV;
 	}
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
-	if (card == NULL) {
-		pr_err("unable to allocate memory\n");
+	if (card == NULL)
 		return -ENOBUFS;
-	}
 
 	card->dev = alloc_hdlcdev(card);
 	if (!card->dev) {
 		pr_err("unable to allocate memory\n");
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 058e169..fe8d060 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -902,24 +902,20 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 	struct dscc4_dev_priv *root;
 	int i, ret = -ENOMEM;
 
 	root = kcalloc(dev_per_card, sizeof(*root), GFP_KERNEL);
-	if (!root) {
-		pr_err("can't allocate data\n");
+	if (!root)
 		goto err_out;
-	}
 
 	for (i = 0; i < dev_per_card; i++) {
 		root[i].dev = alloc_hdlcdev(root + i);
 		if (!root[i].dev)
 			goto err_free_dev;
 	}
 
 	ppriv = kzalloc(sizeof(*ppriv), GFP_KERNEL);
-	if (!ppriv) {
-		pr_err("can't allocate private data\n");
+	if (!ppriv)
 		goto err_free_dev;
-	}
 
 	ppriv->root = root;
 	spin_lock_init(&ppriv->lock);
 
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index b7f2358..76a8a4a 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -496,9 +496,8 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                     }
 
                     data = kmalloc(xc.len, GFP_KERNEL);
                     if (!data) {
-                            printk(KERN_WARNING "%s: Failed to allocate memory for copy\n", dev->name);
                             ret = -ENOMEM;
                             break;
                     }
                     
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 5129ad5..315bf09 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -357,12 +357,10 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 		return -ENODEV;
 	}
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
-	if (card == NULL) {
-		pr_err("unable to allocate memory\n");
+	if (card == NULL)
 		return -ENOBUFS;
-	}
 
 	card->ports[0].dev = alloc_hdlcdev(&card->ports[0]);
 	card->ports[1].dev = alloc_hdlcdev(&card->ports[1]);
 	if (!card->ports[0].dev || !card->ports[1].dev) {
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index c49c1b3..5fe246e 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -319,9 +319,8 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 	}
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
-		pr_err("unable to allocate memory\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		return -ENOBUFS;
 	}
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index 1ce2116..9659fca 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -298,9 +298,8 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	}
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
-		pr_err("unable to allocate memory\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		return -ENOBUFS;
 	}
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 44b7071..feb7541 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -603,9 +603,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 
 	alloc_size = sizeof(card_t) + ports * sizeof(port_t);
 	card = kzalloc(alloc_size, GFP_KERNEL);
 	if (card == NULL) {
-		pr_err("%s: unable to allocate memory\n", pci_name(pdev));
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		return -ENOBUFS;
 	}
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 8a10bb7..e862369 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -785,12 +785,10 @@ static int __init init_x25_asy(void)
 		x25_asy_maxdev);
 
 	x25_asy_devs = kcalloc(x25_asy_maxdev, sizeof(struct net_device *),
 				GFP_KERNEL);
-	if (!x25_asy_devs) {
-		pr_warn("Can't allocate x25_asy_ctrls[] array! Uaargh! (-> No X.25 available)\n");
+	if (!x25_asy_devs)
 		return -ENOMEM;
-	}
 
 	return tty_register_ldisc(N_X25, &x25_ldisc);
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 1b90ed8..c25226a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -430,13 +430,10 @@ struct htc_target *ath9k_htc_hw_alloc(void *hif_handle,
 	struct htc_endpoint *endpoint;
 	struct htc_target *target;
 
 	target = kzalloc(sizeof(struct htc_target), GFP_KERNEL);
-	if (!target) {
-		printk(KERN_ERR "Unable to allocate memory for"
-			"target device\n");
+	if (!target)
 		return NULL;
-	}
 
 	init_completion(&target->target_wait);
 	init_completion(&target->cmd_wait);
 
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index a8bddd8..aa15cc4 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -346,13 +346,11 @@ static int hfa384x_cmd(struct net_device *dev, u16 cmd, u16 param0,
 	if (signal_pending(current))
 		return -EINTR;
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
-	if (entry == NULL) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd - kmalloc failed\n",
-		       dev->name);
+	if (entry == NULL)
 		return -ENOMEM;
-	}
+
 	atomic_set(&entry->usecnt, 1);
 	entry->type = CMD_SLEEP;
 	entry->cmd = cmd;
 	entry->param0 = param0;
@@ -514,13 +512,11 @@ static int hfa384x_cmd_callback(struct net_device *dev, u16 cmd, u16 param0,
 		return -1;
 	}
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
-	if (entry == NULL) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd_callback - kmalloc "
-		       "failed\n", dev->name);
+	if (entry == NULL)
 		return -ENOMEM;
-	}
+
 	atomic_set(&entry->usecnt, 1);
 	entry->type = CMD_CALLBACK;
 	entry->cmd = cmd;
 	entry->param0 = param0;
@@ -2977,13 +2973,11 @@ static int prism2_set_tim(struct net_device *dev, int aid, int set)
 	iface = netdev_priv(dev);
 	local = iface->local;
 
 	new_entry = kzalloc(sizeof(*new_entry), GFP_ATOMIC);
-	if (new_entry == NULL) {
-		printk(KERN_DEBUG "%s: prism2_set_tim: kmalloc failed\n",
-		       local->dev->name);
+	if (new_entry == NULL)
 		return -ENOMEM;
-	}
+
 	new_entry->aid = aid;
 	new_entry->set = set;
 
 	spin_lock_bh(&local->set_tim_lock);
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index a0e5c21..e847737 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -3463,13 +3463,10 @@ static int ipw2100_msg_allocate(struct ipw2100_priv *priv)
 
 	priv->msg_buffers =
 	    kmalloc(IPW_COMMAND_POOL_SIZE * sizeof(struct ipw2100_tx_packet),
 		    GFP_KERNEL);
-	if (!priv->msg_buffers) {
-		printk(KERN_ERR DRV_NAME ": %s: PCI alloc failed for msg "
-		       "buffers.\n", priv->net_dev->name);
+	if (!priv->msg_buffers)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < IPW_COMMAND_POOL_SIZE; i++) {
 		v = pci_alloc_consistent(priv->pci_dev,
 					 sizeof(struct ipw2100_cmd_header), &p);
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 3f7bf4d..234ee88 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -814,12 +814,11 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 
 	lbs_deb_enter(LBS_DEB_CS);
 
 	card = kzalloc(sizeof(struct if_cs_card), GFP_KERNEL);
-	if (!card) {
-		pr_err("error in kzalloc\n");
+	if (!card)
 		goto out;
-	}
+
 	card->p_dev = p_dev;
 	p_dev->priv = card;
 
 	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index b5fbbc7..74da5f1 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -260,12 +260,10 @@ static int if_usb_probe(struct usb_interface *intf,
 
 	udev = interface_to_usbdev(intf);
 
 	cardp = kzalloc(sizeof(struct if_usb_card), GFP_KERNEL);
-	if (!cardp) {
-		pr_err("Out of memory allocating private data\n");
+	if (!cardp)
 		goto error;
-	}
 
 	setup_timer(&cardp->fw_timeout, if_usb_fw_timeo, (unsigned long)cardp);
 	init_waitqueue_head(&cardp->fw_wq);
 
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index aff8b57..7ced130 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -152,12 +152,10 @@ static int if_usb_probe(struct usb_interface *intf,
 	lbtf_deb_enter(LBTF_DEB_USB);
 	udev = interface_to_usbdev(intf);
 
 	cardp = kzalloc(sizeof(struct if_usb_card), GFP_KERNEL);
-	if (!cardp) {
-		pr_err("Out of memory allocating private data.\n");
+	if (!cardp)
 		goto error;
-	}
 
 	setup_timer(&cardp->fw_timeout, if_usb_fw_timeo, (unsigned long)cardp);
 	init_waitqueue_head(&cardp->fw_wq);
 
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 4053509..f4fbad9 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -85,12 +85,10 @@ static int mwifiex_pcie_probe(struct pci_dev *pdev,
 	pr_debug("info: vendor=0x%4.04X device=0x%4.04X rev=%d\n",
 				pdev->vendor, pdev->device, pdev->revision);
 
 	card = kzalloc(sizeof(struct pcie_service_card), GFP_KERNEL);
-	if (!card) {
-		pr_err("%s: failed to alloc memory\n", __func__);
+	if (!card)
 		return -ENOMEM;
-	}
 
 	card->dev = pdev;
 
 	if (mwifiex_add_card(card, &add_remove_card_sem, &pcie_ops,
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
index d39d845..8359027 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -69,12 +69,10 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	pr_debug("info: vendor=0x%4.04X device=0x%4.04X class=%d function=%d\n",
 	       func->vendor, func->device, func->class, func->num);
 
 	card = kzalloc(sizeof(struct sdio_mmc_card), GFP_KERNEL);
-	if (!card) {
-		pr_err("%s: failed to alloc memory\n", __func__);
+	if (!card)
 		return -ENOMEM;
-	}
 
 	card->func = func;
 
 	func->card->quirks |= MMC_QUIRK_BLKSZ_FOR_BYTE_MODE;
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 9fb77d0..dd6c64a 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -940,13 +940,11 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 	}
 
 	/* Add desc and skb to rx queue */
 	rx_data = kzalloc(sizeof(*rx_data), GFP_ATOMIC);
-	if (!rx_data) {
-		printk(KERN_WARNING "%s: Can't allocate RX packet\n",
-			dev->name);
+	if (!rx_data)
 		goto drop;
-	}
+
 	rx_data->desc = desc;
 	rx_data->skb = skb;
 	list_add_tail(&rx_data->list, &priv->rx_list);
 	tasklet_schedule(&priv->rx_tasklet);
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
index a5224f6..851fa10 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -191,13 +191,11 @@ islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 	}
 
 	err = -ENOMEM;
 	p = buf.mem = kmalloc(frag_len, GFP_KERNEL);
-	if (!buf.mem) {
-		printk(KERN_DEBUG "%s: cannot allocate mgmt frame\n",
-		       ndev->name);
+	if (!buf.mem)
 		goto error;
-	}
+
 	buf.size = frag_len;
 
 	/* create the header directly in the fragment data area */
 	pimfor_encode_header(operation, oid, length, (pimfor_header_t *) p);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 7e59b68..25466da 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -156,13 +156,10 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
 		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
 
 	/* for firmware buf */
 	rtlpriv->rtlhal.pfirmware = vzalloc(0x4000);
-	if (!rtlpriv->rtlhal.pfirmware) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't alloc buffer for fw\n");
+	if (!rtlpriv->rtlhal.pfirmware)
 		return 1;
-	}
 
 	/* request fw */
 	if (IS_VENDOR_UMC_A_CUT(rtlhal->version) &&
 	    !IS_92C_SERIAL(rtlhal->version))
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index aec8cae..9b184a8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -62,13 +62,11 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->dm.disable_framebursting = false;
 	rtlpriv->dm.thermalvalue = 0;
 	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
 	rtlpriv->rtlhal.pfirmware = vmalloc(0x4000);
-	if (!rtlpriv->rtlhal.pfirmware) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't alloc buffer for fw\n");
+	if (!rtlpriv->rtlhal.pfirmware)
 		return 1;
-	}
+
 	/* request fw */
 	err = request_firmware(&firmware, rtlpriv->cfg->fw_name,
 			rtlpriv->io.dev);
 	if (err) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index b8d7fe3..83ff17b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -171,13 +171,10 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
 
 	/* for firmware buf */
 	rtlpriv->rtlhal.pfirmware = vzalloc(0x8000);
-	if (!rtlpriv->rtlhal.pfirmware) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't alloc buffer for fw\n");
+	if (!rtlpriv->rtlhal.pfirmware)
 		return 1;
-	}
 
 	if (!header_print) {
 		pr_info("Driver for Realtek RTL8192DE WLAN interface\n");
 		pr_info("Loading firmware file %s\n", rtlpriv->cfg->fw_name);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 3bc0128..f0adfb8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -185,13 +185,10 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
 
 	/* for firmware buf */
 	rtlpriv->rtlhal.pfirmware = vzalloc(sizeof(struct rt_firmware));
-	if (!rtlpriv->rtlhal.pfirmware) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't alloc buffer for fw\n");
+	if (!rtlpriv->rtlhal.pfirmware)
 		return 1;
-	}
 
 	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
 		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
 	/* request fw */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 59effac..2596401 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1638,12 +1638,10 @@ static int __init netback_init(void)
 		return -ENODEV;
 
 	xen_netbk_group_nr = num_online_cpus();
 	xen_netbk = vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
-	if (!xen_netbk) {
-		printk(KERN_ALERT "%s: out of memory\n", __func__);
+	if (!xen_netbk)
 		return -ENOMEM;
-	}
 
 	for (group = 0; group < xen_netbk_group_nr; group++) {
 		struct xen_netbk *netbk = &xen_netbk[group];
 		skb_queue_head_init(&netbk->rx_queue);
