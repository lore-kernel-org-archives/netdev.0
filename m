From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 3/7] NetXen: Multi PCI support for Quad cards
Date: Fri, 20 Apr 2007 07:53:52 -0700
Message-ID: <200704201453.l3KErqw1004511@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:19701 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767122AbXDTOxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 10:53:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix the multi PCI function for cards with more than 2 ports.
This patch fixes the working of multi PCI capable driver on cards with 
more than 2 ports by adding the addresses for their rings and sizes.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic_hw.c       |  115 +++++++++++++++++++--
 drivers/net/netxen/netxen_nic_init.c     |    4 
 drivers/net/netxen/netxen_nic_main.c     |   61 +++++------
 drivers/net/netxen/netxen_nic_phan_reg.h |    6 -
 4 files changed, 144 insertions(+), 42 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a066208..c464bc7 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -140,8 +140,105 @@ struct netxen_recv_crb recv_crb_register
 	 NETXEN_NIC_REG(0x180),
 	 /* crb_status_ring_size */
 	 NETXEN_NIC_REG(0x184),
-
 	 },
+	/*
+	 * Instance 3,
+	 */
+	{
+	  {
+	    {
+	    /* crb_rcv_producer_offset: */
+	    NETXEN_NIC_REG(0x1d8),
+	    /* crb_rcv_consumer_offset: */
+	    NETXEN_NIC_REG(0x1dc),
+	    /* crb_gloablrcv_ring: */
+	    NETXEN_NIC_REG(0x1f0),
+	    /* crb_rcv_ring_size */
+	    NETXEN_NIC_REG(0x1f4),
+	    },
+	    /* Jumbo frames */
+	    {
+	    /* crb_rcv_producer_offset: */		    
+	    NETXEN_NIC_REG(0x1f8),
+	    /* crb_rcv_consumer_offset: */
+	    NETXEN_NIC_REG(0x1fc),
+	    /* crb_gloablrcv_ring: */
+	    NETXEN_NIC_REG(0x200),
+	    /* crb_rcv_ring_size */
+	    NETXEN_NIC_REG(0x204),
+	    },
+	    /* LRO */
+	    {
+	    /* crb_rcv_producer_offset: */
+	    NETXEN_NIC_REG(0x208),
+	    /* crb_rcv_consumer_offset: */
+	    NETXEN_NIC_REG(0x20c),
+	    /* crb_gloablrcv_ring: */
+	    NETXEN_NIC_REG(0x210),
+	    /* crb_rcv_ring_size */
+	    NETXEN_NIC_REG(0x214),
+	    }
+	  },
+	  /* crb_rcvstatus_ring: */
+	  NETXEN_NIC_REG(0x218),
+	  /* crb_rcv_status_producer: */
+	  NETXEN_NIC_REG(0x21c),
+	  /* crb_rcv_status_consumer: */
+	  NETXEN_NIC_REG(0x220),
+	  /* crb_rcvpeg_state: */
+	  NETXEN_NIC_REG(0x224),
+	  /* crb_status_ring_size */
+	  NETXEN_NIC_REG(0x228),
+	},
+	/*
+	 * Instance 4,
+	 */
+	{
+	  {
+	    {
+	    /* crb_rcv_producer_offset: */
+	    NETXEN_NIC_REG(0x22c),
+	    /* crb_rcv_consumer_offset: */
+	    NETXEN_NIC_REG(0x230),
+	    /* crb_gloablrcv_ring: */
+	    NETXEN_NIC_REG(0x234),
+	    /* crb_rcv_ring_size */
+	    NETXEN_NIC_REG(0x238),
+	    },
+	    /* Jumbo frames */
+	    {
+	    /* crb_rcv_producer_offset: */ 
+	    NETXEN_NIC_REG(0x23c),
+	    /* crb_rcv_consumer_offset: */
+	    NETXEN_NIC_REG(0x240),
+	    /* crb_gloablrcv_ring: */
+	    NETXEN_NIC_REG(0x244),
+	    /* crb_rcv_ring_size */
+	    NETXEN_NIC_REG(0x248),
+	    },
+	    /* LRO */
+	    {
+	    /* crb_rcv_producer_offset: */
+	    NETXEN_NIC_REG(0x24c),
+	    /* crb_rcv_consumer_offset: */
+	    NETXEN_NIC_REG(0x250),
+	    /* crb_gloablrcv_ring: */
+	    NETXEN_NIC_REG(0x254),
+	    /* crb_rcv_ring_size */
+	    NETXEN_NIC_REG(0x258),
+	    }
+	  },
+	  /* crb_rcvstatus_ring: */
+	  NETXEN_NIC_REG(0x25c),
+	  /* crb_rcv_status_producer: */
+	  NETXEN_NIC_REG(0x260),
+	  /* crb_rcv_status_consumer: */
+	  NETXEN_NIC_REG(0x264),
+	  /* crb_rcvpeg_state: */
+	  NETXEN_NIC_REG(0x268),
+	  /* crb_status_ring_size */
+	  NETXEN_NIC_REG(0x26c),
+	},
 };
 
 u64 ctx_addr_sig_regs[][3] = {
@@ -294,6 +391,7 @@ int netxen_nic_hw_resources(struct netxe
 	u32 card_cmdring = 0;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
+	int func_id = adapter->portnum;
 
 	DPRINTK(INFO, "crb_base: %lx %x", NETXEN_PCI_CRBSPACE,
 		PCI_OFFSET_SECOND_RANGE(adapter, NETXEN_PCI_CRBSPACE));
@@ -349,6 +447,7 @@ int netxen_nic_hw_resources(struct netxe
 	}
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
 	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
+	adapter->ctx_desc->ctx_id = adapter->portnum;
 	adapter->ctx_desc->cmd_consumer_offset =
 	    cpu_to_le64(adapter->ctx_desc_phys_addr +
 			sizeof(struct netxen_ring_ctx));
@@ -419,11 +518,11 @@ int netxen_nic_hw_resources(struct netxe
 	/* Window = 1 */
 
 	writel(lower32(adapter->ctx_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_LO));
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_LO(func_id)));
 	writel(upper32(adapter->ctx_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_HI));
-	writel(NETXEN_CTX_SIGNATURE,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_SIGNATURE_REG));
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_HI(func_id)));
+	writel(NETXEN_CTX_SIGNATURE | func_id,
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_SIGNATURE_REG(func_id)));
 	return err;
 }
 
@@ -964,9 +1063,11 @@ int netxen_nic_set_mtu_xgb(struct netxen
 {
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
 	if (adapter->portnum == 0)
-	    netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
+		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, 
+				new_mtu);
 	else if (adapter->portnum == 1)
-	    netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE, new_mtu);
+		netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE,
+				new_mtu);
 	return 0;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 13f36d3..9a4047b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -226,7 +226,6 @@ void netxen_initialize_adapter_ops(struc
 		adapter->unset_promisc = netxen_niu_set_promiscuous_mode;
 		adapter->phy_read = netxen_niu_gbe_phy_read;
 		adapter->phy_write = netxen_niu_gbe_phy_write;
-		adapter->init_port = netxen_niu_gbe_init_port;
 		adapter->init_niu = netxen_nic_init_niu_gb;
 		adapter->stop_port = netxen_niu_disable_gbe_port;
 		break;
@@ -438,7 +437,6 @@ do_rom_fast_read_words(struct netxen_ada
 
 	for (addridx = addr; addridx < (addr + size); addridx += 4) {
 		ret = do_rom_fast_read(adapter, addridx, (int *)bytes);
-		*(int *)bytes = cpu_to_le32(*(int *)bytes);
 		if (ret != 0)
 			break;
 		bytes += 4;
@@ -498,7 +496,7 @@ static inline int do_rom_fast_write_word
 		int timeout = 0;
 		int data;
 
-		data = le32_to_cpu((*(u32*)bytes));
+		data = *(u32*)bytes;
 
 		ret = do_rom_fast_write(adapter, addridx, data);
 		if (ret < 0)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 07faea9..d2bb50c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -285,7 +285,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
 	adapter->max_lro_rx_desc_count = MAX_LRO_RCV_DESCRIPTORS;
 
-	pci_set_drvdata(pdev, adapter);
+	pci_set_drvdata(pdev, netdev);
 
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
@@ -387,6 +387,11 @@ #endif
 	adapter->ahw.db_len = db_len;
 	spin_lock_init(&adapter->tx_lock);
 	spin_lock_init(&adapter->lock);
+	/* initialize the adapter */
+	netxen_initialize_adapter_hw(adapter);
+
+	netxen_initialize_adapter_ops(adapter);
+
 	netxen_initialize_adapter_sw(adapter);	/* initialize the buffers in adapter */
 	/* Mezz cards have PCI function 0,2,3 enabled */
 	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
@@ -411,11 +416,6 @@ #endif
 	 *  initializing the ports
 	 */
 
-	/* initialize the adapter */
-	netxen_initialize_adapter_hw(adapter);
-
-	netxen_initialize_adapter_ops(adapter);
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->ahw.xg_linkup = 0;
 	adapter->watchdog_timer.function = &netxen_watchdog;
@@ -577,8 +577,8 @@ static void __devexit netxen_nic_remove(
 	int i;
 	int ctxid, ring;
 
-	adapter = pci_get_drvdata(pdev);
-	netdev = adapter->netdev;
+	netdev = pci_get_drvdata(pdev);
+	adapter = netdev_priv(netdev);
 	if (adapter == NULL)
 		return;
 
@@ -587,15 +587,15 @@ static void __devexit netxen_nic_remove(
 
 	if (adapter->irq)
 		free_irq(adapter->irq, adapter);
-	/* leave the hw in the same state as reboot */
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-	netxen_pinit_from_rom(adapter, 0);
-	netxen_load_firmware(adapter);
-	netxen_free_adapter_offload(adapter);
+	if(adapter->portnum == 0) {
+		/* leave the hw in the same state as reboot */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+		netxen_pinit_from_rom(adapter, 0);
+		netxen_load_firmware(adapter);
+		netxen_free_adapter_offload(adapter);
+	}
 
 	udelay(500);
-	unregister_netdev(netdev);
-	free_netdev(netdev);
 
 	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
 		pci_disable_msi(pdev);
@@ -607,10 +607,6 @@ static void __devexit netxen_nic_remove(
 	iounmap(adapter->ahw.pci_base1);
 	iounmap(adapter->ahw.pci_base2);
 
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
-
 	for (ctxid = 0; ctxid < MAX_RCV_CTX; ++ctxid) {
 		recv_ctx = &adapter->recv_ctx[ctxid];
 		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
@@ -630,7 +626,13 @@ static void __devexit netxen_nic_remove(
 	}
 
 	vfree(adapter->cmd_buf_arr);
-	kfree(adapter);
+	unregister_netdev(netdev);
+	free_netdev(netdev);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+
 }
 
 /*
@@ -650,8 +652,6 @@ static int netxen_nic_open(struct net_de
 			return -EIO;
 		}
 		netxen_nic_flash_print(adapter);
-		if (adapter->init_niu)
-			adapter->init_niu(adapter);
 
 		/* setup all the resources for the Phantom... */
 		/* this include the descriptors for rcv, tx, and status */
@@ -662,13 +662,6 @@ static int netxen_nic_open(struct net_de
 			       err);
 			return err;
 		}
-		if (adapter->init_port
-		    && adapter->init_port(adapter, adapter->portnum) != 0) {
-			printk(KERN_ERR "%s: Failed to initialize port %d\n",
-			       netxen_nic_driver_name, adapter->portnum);
-			netxen_free_hw_resources(adapter);
-			return -EIO;
-		}
 		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 			for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
 				netxen_post_rx_buffers(adapter, ctx, ring);
@@ -694,6 +687,15 @@ static int netxen_nic_open(struct net_de
 	 * we set it */
 	if (adapter->macaddr_set)
 		adapter->macaddr_set(adapter, netdev->dev_addr);
+	if (adapter->init_port
+	    && adapter->init_port(adapter, adapter->portnum) != 0) {
+		printk(KERN_ERR "%s: Failed to initialize port %d\n",
+				netxen_nic_driver_name, adapter->portnum);
+		free_irq(adapter->irq, adapter);
+		netxen_free_hw_resources(adapter);
+		return -EIO;
+	}
+
 	netxen_nic_set_link_parameters(adapter);
 
 	netxen_nic_set_multi(netdev);
@@ -1026,6 +1028,7 @@ netxen_handle_int(struct netxen_adapter 
 	u32 ret = 0;
 
 	DPRINTK(INFO, "Entered handle ISR\n");
+	adapter->stats.ints++;
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		int count = 0;
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index f7eb627..cb9acf1 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -151,9 +151,9 @@ #else
 extern struct netxen_recv_crb recv_crb_registers[];
 extern u64 ctx_addr_sig_regs[][3];
 #endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
-#define CRB_CTX_ADDR_REG_LO            (ctx_addr_sig_regs[0][0])
-#define CRB_CTX_ADDR_REG_HI            (ctx_addr_sig_regs[0][2])
-#define CRB_CTX_SIGNATURE_REG       (ctx_addr_sig_regs[0][1])
+#define CRB_CTX_ADDR_REG_LO(FUNC_ID)		(ctx_addr_sig_regs[FUNC_ID][0])
+#define CRB_CTX_ADDR_REG_HI(FUNC_ID)		(ctx_addr_sig_regs[FUNC_ID][2])
+#define CRB_CTX_SIGNATURE_REG(FUNC_ID)		(ctx_addr_sig_regs[FUNC_ID][1])
 
 /*
  * Temperature control.
