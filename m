From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .26
Date: Tue, 13 May 2008 01:56:23 -0400
Message-ID: <20080513055623.GA16928@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:59701 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928AbYEMF4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:56:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Notes:
- lotsa LOC change in sfc, but it's a new driver, so no possible
  regressions

- we add some non-net exports required for ehea (drivers/base/memory.c)


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 MAINTAINERS                                    |    6 +-
 drivers/base/memory.c                          |    2 +
 drivers/net/Kconfig                            |    2 +-
 drivers/net/atlx/atl1.c                        |  157 ++++--
 drivers/net/atlx/atl1.h                        |    2 +-
 drivers/net/atlx/atlx.c                        |    2 +-
 drivers/net/atlx/atlx.h                        |    7 +-
 drivers/net/cxgb3/adapter.h                    |    1 +
 drivers/net/cxgb3/common.h                     |    1 +
 drivers/net/cxgb3/cxgb3_main.c                 |   40 +-
 drivers/net/cxgb3/regs.h                       |    8 +
 drivers/net/cxgb3/sge.c                        |   29 +-
 drivers/net/cxgb3/t3_hw.c                      |   28 +
 drivers/net/dm9000.c                           |   37 ++-
 drivers/net/ehea/ehea.h                        |   27 +-
 drivers/net/ehea/ehea_main.c                   |   25 +
 drivers/net/ehea/ehea_qmr.c                    |  286 +++++++---
 drivers/net/gianfar.c                          |    2 +
 drivers/net/myri10ge/myri10ge.c                |  730 +++++++++++++----------
 drivers/net/myri10ge/myri10ge_mcp.h            |   56 ++-
 drivers/net/myri10ge/myri10ge_mcp_gen_header.h |   39 +-
 drivers/net/sfc/Makefile                       |    4 +-
 drivers/net/sfc/boards.h                       |    2 +
 drivers/net/sfc/efx.c                          |    4 +-
 drivers/net/sfc/enum.h                         |   49 ++
 drivers/net/sfc/ethtool.c                      |  259 +++++++++-
 drivers/net/sfc/falcon.c                       |    8 +-
 drivers/net/sfc/falcon_hwdefs.h                |   16 +-
 drivers/net/sfc/falcon_xmac.c                  |   82 +++-
 drivers/net/sfc/mdio_10g.c                     |   78 +++
 drivers/net/sfc/mdio_10g.h                     |   24 +-
 drivers/net/sfc/net_driver.h                   |   28 +-
 drivers/net/sfc/rx.c                           |   11 +-
 drivers/net/sfc/selftest.c                     |  717 +++++++++++++++++++++++
 drivers/net/sfc/selftest.h                     |   50 ++
 drivers/net/sfc/sfe4001.c                      |   14 +
 drivers/net/sfc/tenxpress.c                    |   91 +++-
 drivers/net/sfc/tx.c                           |  664 +++++++++++++++++++++
 drivers/net/sfc/xfp_phy.c                      |   36 ++
 drivers/net/sky2.h                             |    4 +-
 40 files changed, 3081 insertions(+), 547 deletions(-)
 create mode 100644 drivers/net/sfc/selftest.c
 create mode 100644 drivers/net/sfc/selftest.h

Andy Fleming (1):
      gianfar: Fix a bug where the pointer never moves for dma_unmap...

Auke Kok (1):
      New maintainer for Intel ethernet adapters

Ben Dooks (1):
      DM9000: Use delayed work to update MII PHY state

Ben Hutchings (9):
      [netdrvr] sfc: Add TSO support
      [netdrvr] sfc: Add phy_flash_cfg module parameter and implementation
      [netdrvr] sfc: Removed bogus 'fall-thru' comments
      [netdrvr] sfc: Remove garbage from comment
      [netdrvr] sfc: Remove kernel-doc comments for removed members of struct efx_nic
      [netdrvr] sfc: Fix code formatting
      [netdrvr] sfc: Remove unused macro EFX_XAUI_RETRAIN_MAX
      [netdrvr] sfc: Increment rx_reset when reported as driver event
      [netdrvr] sfc: sfc: Add self-test support

Brice Goglin (11):
      myri10ge: update firmware headers
      myri10ge: fix module parameter descriptions
      myri10ge: increase and fix handoff timeout
      myri10ge: properly align scratch buffers
      myri10ge: report FIBER in ethtool for XFP based NIC
      myri10ge: add barrier in myri10ge_send_cmd
      myri10ge: trivial formatting fix
      myri10ge: fix potential infinite loop in enable_ecrc
      myri10ge: move data structures into a single slice
      myri10ge: cleanup retrieving of firmware capabilities
      myri10ge: fix the number of interrupt slots

Divy Le Ray (2):
      cxgb3 - fix port up/down error path
      cxgb3 - fix EEH

Enrico Scholz (2):
      DM9000: Add __devinit and __devexit attributes to probe and remove
      DM9000: Update and fix driver debugging messages

Hannes Hering (3):
      memory: Introduce exports for memory notifiers
      ehea: Add dependency to Kconfig
      ehea: Add DLPAR memory remove support

Jay Cliburn (4):
      atl1: add PHY power save mode
      atl1: fix broken suspend and resume
      atl1: add shutdown callback
      atl1: bump version number

Jesse Brandeburg (1):
      sky2: fix simple define thinko

diff --git a/MAINTAINERS b/MAINTAINERS
index c3a533d..0cc47b9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2104,12 +2104,10 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 
 INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/ixgb/ixgbe)
-P:	Auke Kok
-M:	auke-jan.h.kok@intel.com
-P:	Jesse Brandeburg
-M:	jesse.brandeburg@intel.com
 P:	Jeff Kirsher
 M:	jeffrey.t.kirsher@intel.com
+P:	Jesse Brandeburg
+M:	jesse.brandeburg@intel.com
 P:	Bruce Allan
 M:	bruce.w.allan@intel.com
 P:	John Ronciak
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 8ce6de5..937e825 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -53,11 +53,13 @@ int register_memory_notifier(struct notifier_block *nb)
 {
         return blocking_notifier_chain_register(&memory_chain, nb);
 }
+EXPORT_SYMBOL(register_memory_notifier);
 
 void unregister_memory_notifier(struct notifier_block *nb)
 {
         blocking_notifier_chain_unregister(&memory_chain, nb);
 }
+EXPORT_SYMBOL(unregister_memory_notifier);
 
 /*
  * register_memory - Setup a sysfs device for a memory block
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d27f54a..9f6cc8a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2426,7 +2426,7 @@ config CHELSIO_T3
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM
+	depends on IBMEBUS && INET && SPARSEMEM && MEMORY_HOTPLUG
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 0afe522..9c2394d 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1,7 +1,7 @@
 /*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
+ * Copyright(c) 2006 - 2008 Jay Cliburn <jcliburn@gmail.com>
  *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
@@ -36,7 +36,6 @@
  * A very incomplete list of things that need to be dealt with:
  *
  * TODO:
- * Wake on LAN.
  * Add more ethtool functions.
  * Fix abstruse irq enable/disable condition described here:
  *	http://marc.theaimsgroup.com/?l=linux-netdev&m=116398508500553&w=2
@@ -638,21 +637,18 @@ static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
 }
 
 /*
- *TODO: do something or get rid of this
+ * Force the PHY into power saving mode using vendor magic.
  */
 #ifdef CONFIG_PM
-static s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
+static void atl1_phy_enter_power_saving(struct atl1_hw *hw)
 {
-/*    s32 ret_val;
- *    u16 phy_data;
- */
+	atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
+	atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
+	atl1_write_phy_reg(hw, MII_DBG_ADDR, 2);
+	atl1_write_phy_reg(hw, MII_DBG_DATA, 0x3000);
+	atl1_write_phy_reg(hw, MII_DBG_ADDR, 3);
+	atl1_write_phy_reg(hw, MII_DBG_DATA, 0);
 
-/*
-    ret_val = atl1_write_phy_reg(hw, ...);
-    ret_val = atl1_write_phy_reg(hw, ...);
-    ....
-*/
-	return 0;
 }
 #endif
 
@@ -2784,64 +2780,93 @@ static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct atl1_hw *hw = &adapter->hw;
 	u32 ctrl = 0;
 	u32 wufc = adapter->wol;
+	u32 val;
+	int retval;
+	u16 speed;
+	u16 duplex;
 
 	netif_device_detach(netdev);
 	if (netif_running(netdev))
 		atl1_down(adapter);
 
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
+
 	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
 	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
-	if (ctrl & BMSR_LSTATUS)
+	val = ctrl & BMSR_LSTATUS;
+	if (val)
 		wufc &= ~ATLX_WUFC_LNKC;
 
-	/* reduce speed to 10/100M */
-	if (wufc) {
-		atl1_phy_enter_power_saving(hw);
-		/* if resume, let driver to re- setup link */
-		hw->phy_configured = false;
-		atl1_set_mac_addr(hw);
-		atlx_set_multi(netdev);
+	if (val && wufc) {
+		val = atl1_get_speed_and_duplex(hw, &speed, &duplex);
+		if (val) {
+			if (netif_msg_ifdown(adapter))
+				dev_printk(KERN_DEBUG, &pdev->dev,
+					"error getting speed/duplex\n");
+			goto disable_wol;
+		}
 
 		ctrl = 0;
-		/* turn on magic packet wol */
-		if (wufc & ATLX_WUFC_MAG)
-			ctrl = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
 
-		/* turn on Link change WOL */
-		if (wufc & ATLX_WUFC_LNKC)
-			ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
+		/* enable magic packet WOL */
+		if (wufc & ATLX_WUFC_MAG)
+			ctrl |= (WOL_MAGIC_EN | WOL_MAGIC_PME_EN);
 		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
-
-		/* turn on all-multi mode if wake on multicast is enabled */
-		ctrl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_DBG;
-		ctrl &= ~MAC_CTRL_PROMIS_EN;
-		if (wufc & ATLX_WUFC_MC)
-			ctrl |= MAC_CTRL_MC_ALL_EN;
-		else
-			ctrl &= ~MAC_CTRL_MC_ALL_EN;
-
-		/* turn on broadcast mode if wake on-BC is enabled */
-		if (wufc & ATLX_WUFC_BC)
+		ioread32(hw->hw_addr + REG_WOL_CTRL);
+
+		/* configure the mac */
+		ctrl = MAC_CTRL_RX_EN;
+		ctrl |= ((u32)((speed == SPEED_1000) ? MAC_CTRL_SPEED_1000 :
+			MAC_CTRL_SPEED_10_100) << MAC_CTRL_SPEED_SHIFT);
+		if (duplex == FULL_DUPLEX)
+			ctrl |= MAC_CTRL_DUPLX;
+		ctrl |= (((u32)adapter->hw.preamble_len &
+			MAC_CTRL_PRMLEN_MASK) << MAC_CTRL_PRMLEN_SHIFT);
+		if (adapter->vlgrp)
+			ctrl |= MAC_CTRL_RMV_VLAN;
+		if (wufc & ATLX_WUFC_MAG)
 			ctrl |= MAC_CTRL_BC_EN;
-		else
-			ctrl &= ~MAC_CTRL_BC_EN;
-
-		/* enable RX */
-		ctrl |= MAC_CTRL_RX_EN;
 		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
-		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
+		ioread32(hw->hw_addr + REG_MAC_CTRL);
+
+		/* poke the PHY */
+		ctrl = ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
+		ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
+		iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
+		ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
+
+		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
+		goto exit;
 	}
 
-	pci_save_state(pdev);
+	if (!val && wufc) {
+		ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
+		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
+		ioread32(hw->hw_addr + REG_WOL_CTRL);
+		iowrite32(0, hw->hw_addr + REG_MAC_CTRL);
+		ioread32(hw->hw_addr + REG_MAC_CTRL);
+		hw->phy_configured = false;
+		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
+		goto exit;
+	}
+
+disable_wol:
+	iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
+	ioread32(hw->hw_addr + REG_WOL_CTRL);
+	ctrl = ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
+	ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
+	iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
+	ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
+	atl1_phy_enter_power_saving(hw);
+	hw->phy_configured = false;
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
+exit:
+	if (netif_running(netdev))
+		pci_disable_msi(adapter->pdev);
 	pci_disable_device(pdev);
-
-	pci_set_power_state(pdev, PCI_D3hot);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
@@ -2855,20 +2880,26 @@ static int atl1_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	/* FIXME: check and handle */
 	err = pci_enable_device(pdev);
+	if (err) {
+		if (netif_msg_ifup(adapter))
+			dev_printk(KERN_DEBUG, &pdev->dev,
+				"error enabling pci device\n");
+		return err;
+	}
+
+	pci_set_master(pdev);
+	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
-	atl1_reset(adapter);
+	atl1_reset_hw(&adapter->hw);
+	adapter->cmb.cmb->int_stats = 0;
 
 	if (netif_running(netdev))
 		atl1_up(adapter);
 	netif_device_attach(netdev);
 
-	atl1_via_workaround(adapter);
-
 	return 0;
 }
 #else
@@ -2876,6 +2907,13 @@ static int atl1_resume(struct pci_dev *pdev)
 #define atl1_resume NULL
 #endif
 
+static void atl1_shutdown(struct pci_dev *pdev)
+{
+#ifdef CONFIG_PM
+	atl1_suspend(pdev, PMSG_SUSPEND);
+#endif
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void atl1_poll_controller(struct net_device *netdev)
 {
@@ -3122,7 +3160,8 @@ static struct pci_driver atl1_driver = {
 	.probe = atl1_probe,
 	.remove = __devexit_p(atl1_remove),
 	.suspend = atl1_suspend,
-	.resume = atl1_resume
+	.resume = atl1_resume,
+	.shutdown = atl1_shutdown
 };
 
 /*
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 51893d6..a5015b1 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -1,7 +1,7 @@
 /*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
+ * Copyright(c) 2006 - 2008 Jay Cliburn <jcliburn@gmail.com>
  *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index f06b854..b3e7fcf 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -2,7 +2,7 @@
  *
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
+ * Copyright(c) 2006 - 2008 Jay Cliburn <jcliburn@gmail.com>
  * Copyright(c) 2007 Atheros Corporation. All rights reserved.
  *
  * Derived from Intel e1000 driver
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/atlx/atlx.h
index 3be7c09..297a03d 100644
--- a/drivers/net/atlx/atlx.h
+++ b/drivers/net/atlx/atlx.h
@@ -2,7 +2,7 @@
  *
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
+ * Copyright(c) 2006 - 2008 Jay Cliburn <jcliburn@gmail.com>
  * Copyright(c) 2007 Atheros Corporation. All rights reserved.
  *
  * Derived from Intel e1000 driver
@@ -29,7 +29,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 
-#define ATLX_DRIVER_VERSION "2.1.1"
+#define ATLX_DRIVER_VERSION "2.1.3"
 MODULE_AUTHOR("Xiong Huang <xiong.huang@atheros.com>, \
 	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
 MODULE_LICENSE("GPL");
@@ -460,6 +460,9 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 #define MII_ATLX_PSSR_100MBS		0x4000	/* 01=100Mbs */
 #define MII_ATLX_PSSR_1000MBS		0x8000	/* 10=1000Mbs */
 
+#define MII_DBG_ADDR			0x1D
+#define MII_DBG_DATA			0x1E
+
 /* PCI Command Register Bit Definitions */
 #define PCI_REG_COMMAND			0x04	/* PCI Command Register */
 #define CMD_IO_SPACE			0x0001
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 4fdb13f..acebe43 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -71,6 +71,7 @@ enum {				/* adapter flags */
 	USING_MSIX = (1 << 2),
 	QUEUES_BOUND = (1 << 3),
 	TP_PARITY_INIT = (1 << 4),
+	NAPI_INIT = (1 << 5),
 };
 
 struct fl_pg_chunk {
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 91ee727..579bee4 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -698,6 +698,7 @@ void mac_prep(struct cmac *mac, struct adapter *adapter, int index);
 void early_hw_init(struct adapter *adapter, const struct adapter_info *ai);
 int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 		    int reset);
+int t3_replay_prep_adapter(struct adapter *adapter);
 void t3_led_ready(struct adapter *adapter);
 void t3_fatal_err(struct adapter *adapter);
 void t3_set_vlan_accel(struct adapter *adapter, unsigned int ports, int on);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index ce949d5..3a31272 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -421,6 +421,13 @@ static void init_napi(struct adapter *adap)
 			netif_napi_add(qs->netdev, &qs->napi, qs->napi.poll,
 				       64);
 	}
+
+	/*
+	 * netif_napi_add() can be called only once per napi_struct because it
+	 * adds each new napi_struct to a list.  Be careful not to call it a
+	 * second time, e.g., during EEH recovery, by making a note of it.
+	 */
+	adap->flags |= NAPI_INIT;
 }
 
 /*
@@ -896,7 +903,8 @@ static int cxgb_up(struct adapter *adap)
 			goto out;
 
 		setup_rss(adap);
-		init_napi(adap);
+		if (!(adap->flags & NAPI_INIT))
+			init_napi(adap);
 		adap->flags |= FULL_INIT_DONE;
 	}
 
@@ -999,7 +1007,7 @@ static int offload_open(struct net_device *dev)
 		return 0;
 
 	if (!adap_up && (err = cxgb_up(adapter)) < 0)
-		return err;
+		goto out;
 
 	t3_tp_set_offload_mode(adapter, 1);
 	tdev->lldev = adapter->port[0];
@@ -1061,10 +1069,8 @@ static int cxgb_open(struct net_device *dev)
 	int other_ports = adapter->open_device_map & PORT_MASK;
 	int err;
 
-	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0) {
-		quiesce_rx(adapter);
+	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
 		return err;
-	}
 
 	set_bit(pi->port_id, &adapter->open_device_map);
 	if (is_offload(adapter) && !ofld_disable) {
@@ -2424,14 +2430,11 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 	    test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
 		offload_close(&adapter->tdev);
 
-	/* Free sge resources */
-	t3_free_sge_resources(adapter);
-
 	adapter->flags &= ~FULL_INIT_DONE;
 
 	pci_disable_device(pdev);
 
-	/* Request a slot slot reset. */
+	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
@@ -2448,13 +2451,20 @@ static pci_ers_result_t t3_io_slot_reset(struct pci_dev *pdev)
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
-		return PCI_ERS_RESULT_DISCONNECT;
+		goto err;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
 
-	t3_prep_adapter(adapter, adapter->params.info, 1);
+	/* Free sge resources */
+	t3_free_sge_resources(adapter);
+
+	if (t3_replay_prep_adapter(adapter))
+		goto err;
 
 	return PCI_ERS_RESULT_RECOVERED;
+err:
+	return PCI_ERS_RESULT_DISCONNECT;
 }
 
 /**
@@ -2483,13 +2493,6 @@ static void t3_io_resume(struct pci_dev *pdev)
 			netif_device_attach(netdev);
 		}
 	}
-
-	if (is_offload(adapter)) {
-		__set_bit(OFFLOAD_DEVMAP_BIT, &adapter->registered_device_map);
-		if (offload_open(adapter->port[0]))
-			printk(KERN_WARNING
-			       "Could not bring back offload capabilities\n");
-	}
 }
 
 static struct pci_error_handlers t3_err_handler = {
@@ -2608,6 +2611,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	}
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 02dbbb3..5671788 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -444,6 +444,14 @@
 
 #define A_PCIE_CFG 0x88
 
+#define S_ENABLELINKDWNDRST    21
+#define V_ENABLELINKDWNDRST(x) ((x) << S_ENABLELINKDWNDRST)
+#define F_ENABLELINKDWNDRST    V_ENABLELINKDWNDRST(1U)
+
+#define S_ENABLELINKDOWNRST    20
+#define V_ENABLELINKDOWNRST(x) ((x) << S_ENABLELINKDOWNRST)
+#define F_ENABLELINKDOWNRST    V_ENABLELINKDOWNRST(1U)
+
 #define S_PCIE_CLIDECEN    16
 #define V_PCIE_CLIDECEN(x) ((x) << S_PCIE_CLIDECEN)
 #define F_PCIE_CLIDECEN    V_PCIE_CLIDECEN(1U)
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 98a6bbd..796eb30 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -539,6 +539,31 @@ static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
 }
 
 /**
+ *	t3_reset_qset - reset a sge qset
+ *	@q: the queue set
+ *
+ *	Reset the qset structure.
+ *	the NAPI structure is preserved in the event of
+ *	the qset's reincarnation, for example during EEH recovery.
+ */
+static void t3_reset_qset(struct sge_qset *q)
+{
+	if (q->adap &&
+	    !(q->adap->flags & NAPI_INIT)) {
+		memset(q, 0, sizeof(*q));
+		return;
+	}
+
+	q->adap = NULL;
+	memset(&q->rspq, 0, sizeof(q->rspq));
+	memset(q->fl, 0, sizeof(struct sge_fl) * SGE_RXQ_PER_SET);
+	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
+	q->txq_stopped = 0;
+	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));
+}
+
+
+/**
  *	free_qset - free the resources of an SGE queue set
  *	@adapter: the adapter owning the queue set
  *	@q: the queue set
@@ -594,7 +619,7 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 				  q->rspq.desc, q->rspq.phys_addr);
 	}
 
-	memset(q, 0, sizeof(*q));
+	t3_reset_qset(q);
 }
 
 /**
@@ -1365,7 +1390,7 @@ static void restart_ctrlq(unsigned long data)
  */
 int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb)
 {
-	int ret; 
+	int ret;
 	local_bh_disable();
 	ret = ctrl_xmit(adap, &adap->sge.qs[0].txq[TXQ_CTRL], skb);
 	local_bh_enable();
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index a99496a..d405a93 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3264,6 +3264,7 @@ static void config_pcie(struct adapter *adap)
 
 	t3_write_reg(adap, A_PCIE_PEX_ERR, 0xffffffff);
 	t3_set_reg_field(adap, A_PCIE_CFG, 0,
+			 F_ENABLELINKDWNDRST | F_ENABLELINKDOWNRST |
 			 F_PCIE_DMASTOPEN | F_PCIE_CLIDECEN);
 }
 
@@ -3655,3 +3656,30 @@ void t3_led_ready(struct adapter *adapter)
 	t3_set_reg_field(adapter, A_T3DBG_GPIO_EN, F_GPIO0_OUT_VAL,
 			 F_GPIO0_OUT_VAL);
 }
+
+int t3_replay_prep_adapter(struct adapter *adapter)
+{
+	const struct adapter_info *ai = adapter->params.info;
+	unsigned int i, j = 0;
+	int ret;
+
+	early_hw_init(adapter, ai);
+	ret = init_parity(adapter);
+	if (ret)
+		return ret;
+
+	for_each_port(adapter, i) {
+		struct port_info *p = adap2pinfo(adapter, i);
+		while (!adapter->params.vpd.port_type[j])
+			++j;
+
+		p->port_type->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
+					ai->mdio_ops);
+
+		p->phy.ops->power_down(&p->phy, 1);
+		++j;
+	}
+
+return 0;
+}
+
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index e6fe261..d45bcd2 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -117,6 +117,9 @@ typedef struct board_info {
 
 	struct mutex	 addr_lock;	/* phy and eeprom access lock */
 
+	struct delayed_work phy_poll;
+	struct net_device  *ndev;
+
 	spinlock_t lock;
 
 	struct mii_if_info mii;
@@ -297,6 +300,10 @@ static void dm9000_set_io(struct board_info *db, int byte_width)
 	}
 }
 
+static void dm9000_schedule_poll(board_info_t *db)
+{
+	schedule_delayed_work(&db->phy_poll, HZ * 2);
+}
 
 /* Our watchdog timed out. Called by the networking layer */
 static void dm9000_timeout(struct net_device *dev)
@@ -465,6 +472,17 @@ static const struct ethtool_ops dm9000_ethtool_ops = {
  	.set_eeprom		= dm9000_set_eeprom,
 };
 
+static void
+dm9000_poll_work(struct work_struct *w)
+{
+	struct delayed_work *dw = container_of(w, struct delayed_work, work);
+	board_info_t *db = container_of(dw, board_info_t, phy_poll);
+
+	mii_check_media(&db->mii, netif_msg_link(db), 0);
+	
+	if (netif_running(db->ndev))
+		dm9000_schedule_poll(db);
+}
 
 /* dm9000_release_board
  *
@@ -503,7 +521,7 @@ dm9000_release_board(struct platform_device *pdev, struct board_info *db)
 /*
  * Search DM9000 board, allocate space and register it
  */
-static int
+static int __devinit
 dm9000_probe(struct platform_device *pdev)
 {
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
@@ -525,17 +543,21 @@ dm9000_probe(struct platform_device *pdev)
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	dev_dbg(&pdev->dev, "dm9000_probe()");
+	dev_dbg(&pdev->dev, "dm9000_probe()\n");
 
 	/* setup board info structure */
 	db = (struct board_info *) ndev->priv;
 	memset(db, 0, sizeof (*db));
 
 	db->dev = &pdev->dev;
+	db->ndev = ndev;
 
 	spin_lock_init(&db->lock);
 	mutex_init(&db->addr_lock);
 
+	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
+
+
 	if (pdev->num_resources < 2) {
 		ret = -ENODEV;
 		goto out;
@@ -761,6 +783,8 @@ dm9000_open(struct net_device *dev)
 
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
+	
+	dm9000_schedule_poll(db);
 
 	return 0;
 }
@@ -879,6 +903,8 @@ dm9000_stop(struct net_device *ndev)
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
+	cancel_delayed_work(&db->phy_poll);
+
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 
@@ -1288,6 +1314,8 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 	spin_unlock_irqrestore(&db->lock,flags);
 
 	mutex_unlock(&db->addr_lock);
+
+	dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
 	return ret;
 }
 
@@ -1301,6 +1329,7 @@ dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
 	unsigned long flags;
 	unsigned long reg_save;
 
+	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
 	mutex_lock(&db->addr_lock);
 
 	spin_lock_irqsave(&db->lock,flags);
@@ -1372,7 +1401,7 @@ dm9000_drv_resume(struct platform_device *dev)
 	return 0;
 }
 
-static int
+static int __devexit
 dm9000_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
@@ -1393,7 +1422,7 @@ static struct platform_driver dm9000_driver = {
 		.owner	 = THIS_MODULE,
 	},
 	.probe   = dm9000_probe,
-	.remove  = dm9000_drv_remove,
+	.remove  = __devexit_p(dm9000_drv_remove),
 	.suspend = dm9000_drv_suspend,
 	.resume  = dm9000_drv_resume,
 };
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f5dacce..fe872fb 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0090"
+#define DRV_VERSION	"EHEA_0091"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -118,6 +118,13 @@
 #define EHEA_MR_ACC_CTRL       0x00800000
 
 #define EHEA_BUSMAP_START      0x8000000000000000ULL
+#define EHEA_INVAL_ADDR        0xFFFFFFFFFFFFFFFFULL
+#define EHEA_DIR_INDEX_SHIFT 13                   /* 8k Entries in 64k block */
+#define EHEA_TOP_INDEX_SHIFT (EHEA_DIR_INDEX_SHIFT * 2)
+#define EHEA_MAP_ENTRIES (1 << EHEA_DIR_INDEX_SHIFT)
+#define EHEA_MAP_SIZE (0x10000)                   /* currently fixed map size */
+#define EHEA_INDEX_MASK (EHEA_MAP_ENTRIES - 1)
+
 
 #define EHEA_WATCH_DOG_TIMEOUT 10*HZ
 
@@ -192,10 +199,20 @@ struct h_epas {
 				   set to 0 if unused */
 };
 
-struct ehea_busmap {
-	unsigned int entries;		/* total number of entries */
-	unsigned int valid_sections;	/* number of valid sections */
-	u64 *vaddr;
+/*
+ * Memory map data structures
+ */
+struct ehea_dir_bmap
+{
+	u64 ent[EHEA_MAP_ENTRIES];
+};
+struct ehea_top_bmap
+{
+	struct ehea_dir_bmap *dir[EHEA_MAP_ENTRIES];
+};
+struct ehea_bmap
+{
+	struct ehea_top_bmap *top[EHEA_MAP_ENTRIES];
 };
 
 struct ehea_qp;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f9bc21c..d1b6d4e 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -35,6 +35,7 @@
 #include <linux/if_ether.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <linux/memory.h>
 #include <asm/kexec.h>
 #include <linux/mutex.h>
 
@@ -3503,6 +3504,24 @@ void ehea_crash_handler(void)
 					      0, H_DEREG_BCMC);
 }
 
+static int ehea_mem_notifier(struct notifier_block *nb,
+                             unsigned long action, void *data)
+{
+	switch (action) {
+	case MEM_OFFLINE:
+		ehea_info("memory has been removed");
+		ehea_rereg_mrs(NULL);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ehea_mem_nb = {
+	.notifier_call = ehea_mem_notifier,
+};
+
 static int ehea_reboot_notifier(struct notifier_block *nb,
 				unsigned long action, void *unused)
 {
@@ -3581,6 +3600,10 @@ int __init ehea_module_init(void)
 	if (ret)
 		ehea_info("failed registering reboot notifier");
 
+	ret = register_memory_notifier(&ehea_mem_nb);
+	if (ret)
+		ehea_info("failed registering memory remove notifier");
+
 	ret = crash_shutdown_register(&ehea_crash_handler);
 	if (ret)
 		ehea_info("failed registering crash handler");
@@ -3604,6 +3627,7 @@ int __init ehea_module_init(void)
 out3:
 	ibmebus_unregister_driver(&ehea_driver);
 out2:
+	unregister_memory_notifier(&ehea_mem_nb);
 	unregister_reboot_notifier(&ehea_reboot_nb);
 	crash_shutdown_unregister(&ehea_crash_handler);
 out:
@@ -3621,6 +3645,7 @@ static void __exit ehea_module_exit(void)
 	ret = crash_shutdown_unregister(&ehea_crash_handler);
 	if (ret)
 		ehea_info("failed unregistering crash handler");
+	unregister_memory_notifier(&ehea_mem_nb);
 	kfree(ehea_fw_handles.arr);
 	kfree(ehea_bcmc_regs.arr);
 	ehea_destroy_busmap();
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index d522e90..140f05b 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -31,8 +31,8 @@
 #include "ehea_phyp.h"
 #include "ehea_qmr.h"
 
+struct ehea_bmap *ehea_bmap = NULL;
 
-struct ehea_busmap ehea_bmap = { 0, 0, NULL };
 
 
 static void *hw_qpageit_get_inc(struct hw_queue *queue)
@@ -559,125 +559,253 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	return 0;
 }
 
-int ehea_create_busmap(void)
+static inline int ehea_calc_index(unsigned long i, unsigned long s)
 {
-	u64 vaddr = EHEA_BUSMAP_START;
-	unsigned long high_section_index = 0;
-	int i;
+	return (i >> s) & EHEA_INDEX_MASK;
+}
 
-	/*
-	 * Sections are not in ascending order -> Loop over all sections and
-	 * find the highest PFN to compute the required map size.
-	*/
-	ehea_bmap.valid_sections = 0;
+static inline int ehea_init_top_bmap(struct ehea_top_bmap *ehea_top_bmap,
+				     int dir)
+{
+	if(!ehea_top_bmap->dir[dir]) {
+		ehea_top_bmap->dir[dir] =
+			kzalloc(sizeof(struct ehea_dir_bmap), GFP_KERNEL);
+		if (!ehea_top_bmap->dir[dir])
+			return -ENOMEM;
+	}
+	return 0;
+}
 
-	for (i = 0; i < NR_MEM_SECTIONS; i++)
-		if (valid_section_nr(i))
-			high_section_index = i;
+static inline int ehea_init_bmap(struct ehea_bmap *ehea_bmap, int top, int dir)
+{
+	if(!ehea_bmap->top[top]) {
+		ehea_bmap->top[top] =
+			kzalloc(sizeof(struct ehea_top_bmap), GFP_KERNEL);
+		if (!ehea_bmap->top[top])
+			return -ENOMEM;
+	}
+	return ehea_init_top_bmap(ehea_bmap->top[top], dir);
+}
 
-	ehea_bmap.entries = high_section_index + 1;
-	ehea_bmap.vaddr = vmalloc(ehea_bmap.entries * sizeof(*ehea_bmap.vaddr));
+static int ehea_create_busmap_callback(unsigned long pfn,
+				       unsigned long nr_pages, void *arg)
+{
+	unsigned long i, mr_len, start_section, end_section;
+	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
+	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
+	mr_len = *(unsigned long *)arg;
 
-	if (!ehea_bmap.vaddr)
+	ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+	if (!ehea_bmap)
 		return -ENOMEM;
 
-	for (i = 0 ; i < ehea_bmap.entries; i++) {
-		unsigned long pfn = section_nr_to_pfn(i);
+	for (i = start_section; i < end_section; i++) {
+		int ret;
+		int top, dir, idx;
+		u64 vaddr;
+
+		top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
+		dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
+
+		ret = ehea_init_bmap(ehea_bmap, top, dir);
+		if(ret)
+			return ret;
 
-		if (pfn_valid(pfn)) {
-			ehea_bmap.vaddr[i] = vaddr;
-			vaddr += EHEA_SECTSIZE;
-			ehea_bmap.valid_sections++;
-		} else
-			ehea_bmap.vaddr[i] = 0;
+		idx = i & EHEA_INDEX_MASK;
+		vaddr = EHEA_BUSMAP_START + mr_len + i * EHEA_SECTSIZE;
+
+		ehea_bmap->top[top]->dir[dir]->ent[idx] = vaddr;
 	}
 
+	mr_len += nr_pages * PAGE_SIZE;
+	*(unsigned long *)arg = mr_len;
+
 	return 0;
 }
 
+static unsigned long ehea_mr_len;
+
+static DEFINE_MUTEX(ehea_busmap_mutex);
+
+int ehea_create_busmap(void)
+{
+	int ret;
+	mutex_lock(&ehea_busmap_mutex);
+	ehea_mr_len = 0;
+	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, &ehea_mr_len,
+				   ehea_create_busmap_callback);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
+
 void ehea_destroy_busmap(void)
 {
-	vfree(ehea_bmap.vaddr);
+	int top, dir;
+	mutex_lock(&ehea_busmap_mutex);
+	if (!ehea_bmap)
+		goto out_destroy;
+
+	for (top = 0; top < EHEA_MAP_ENTRIES; top++) {
+		if (!ehea_bmap->top[top])
+			continue;
+
+		for (dir = 0; dir < EHEA_MAP_ENTRIES; dir++) {
+			if (!ehea_bmap->top[top]->dir[dir])
+				continue;
+
+			kfree(ehea_bmap->top[top]->dir[dir]);
+		}
+
+		kfree(ehea_bmap->top[top]);
+	}
+
+	kfree(ehea_bmap);
+	ehea_bmap = NULL;
+out_destroy:	
+	mutex_unlock(&ehea_busmap_mutex);
 }
 
 u64 ehea_map_vaddr(void *caddr)
 {
-	u64 mapped_addr;
-	unsigned long index = __pa(caddr) >> SECTION_SIZE_BITS;
-
-	if (likely(index < ehea_bmap.entries)) {
-		mapped_addr = ehea_bmap.vaddr[index];
-		if (likely(mapped_addr))
-			mapped_addr |= (((unsigned long)caddr)
-					& (EHEA_SECTSIZE - 1));
-		else
-			mapped_addr = -1;
-	} else
-		mapped_addr = -1;
-
-	if (unlikely(mapped_addr == -1))
-		if (!test_and_set_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-			schedule_work(&ehea_rereg_mr_task);
-
-	return mapped_addr;
+	int top, dir, idx;
+	unsigned long index, offset;
+
+	if (!ehea_bmap)
+		return EHEA_INVAL_ADDR;
+
+	index = virt_to_abs(caddr) >> SECTION_SIZE_BITS;
+	top = (index >> EHEA_TOP_INDEX_SHIFT) & EHEA_INDEX_MASK;
+	if (!ehea_bmap->top[top])
+		return EHEA_INVAL_ADDR;
+
+	dir = (index >> EHEA_DIR_INDEX_SHIFT) & EHEA_INDEX_MASK;
+	if (!ehea_bmap->top[top]->dir[dir])
+		return EHEA_INVAL_ADDR;
+
+	idx = index & EHEA_INDEX_MASK;
+	if (!ehea_bmap->top[top]->dir[dir]->ent[idx])
+		return EHEA_INVAL_ADDR;
+
+	offset = (unsigned long)caddr & (EHEA_SECTSIZE - 1);
+	return ehea_bmap->top[top]->dir[dir]->ent[idx] | offset;
+}
+
+static inline void *ehea_calc_sectbase(int top, int dir, int idx)
+{
+	unsigned long ret = idx;
+	ret |= dir << EHEA_DIR_INDEX_SHIFT;
+	ret |= top << EHEA_TOP_INDEX_SHIFT;
+	return abs_to_virt(ret << SECTION_SIZE_BITS);
+}
+
+static u64 ehea_reg_mr_section(int top, int dir, int idx, u64 *pt,
+			       struct ehea_adapter *adapter,
+			       struct ehea_mr *mr)
+{
+	void *pg;
+	u64 j, m, hret;
+	unsigned long k = 0;
+	u64 pt_abs = virt_to_abs(pt);
+
+	void *sectbase = ehea_calc_sectbase(top, dir, idx);
+
+	for (j = 0; j < (EHEA_PAGES_PER_SECTION / EHEA_MAX_RPAGE); j++) {
+
+		for (m = 0; m < EHEA_MAX_RPAGE; m++) {
+			pg = sectbase + ((k++) * EHEA_PAGESIZE);
+			pt[m] = virt_to_abs(pg);
+		}
+		hret = ehea_h_register_rpage_mr(adapter->handle, mr->handle, 0,
+						0, pt_abs, EHEA_MAX_RPAGE);
+
+		if ((hret != H_SUCCESS)
+		    && (hret != H_PAGE_REGISTERED)) {
+			ehea_h_free_resource(adapter->handle, mr->handle,
+					     FORCE_FREE);
+			ehea_error("register_rpage_mr failed");
+			return hret;
+		}
+	}
+	return hret;
+}
+
+static u64 ehea_reg_mr_sections(int top, int dir, u64 *pt,
+				struct ehea_adapter *adapter,
+				struct ehea_mr *mr)
+{
+	u64 hret = H_SUCCESS;
+	int idx;
+
+	for (idx = 0; idx < EHEA_MAP_ENTRIES; idx++) {
+		if (!ehea_bmap->top[top]->dir[dir]->ent[idx])
+			continue;
+		
+		hret = ehea_reg_mr_section(top, dir, idx, pt, adapter, mr);
+		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
+			    	return hret;
+	}
+	return hret;
+}
+
+static u64 ehea_reg_mr_dir_sections(int top, u64 *pt,
+				    struct ehea_adapter *adapter,
+				    struct ehea_mr *mr)
+{
+	u64 hret = H_SUCCESS;
+	int dir;
+
+	for (dir = 0; dir < EHEA_MAP_ENTRIES; dir++) {
+		if (!ehea_bmap->top[top]->dir[dir])
+			continue;
+
+		hret = ehea_reg_mr_sections(top, dir, pt, adapter, mr);
+		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
+			    	return hret;
+	}
+	return hret;
 }
 
 int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 {
 	int ret;
 	u64 *pt;
-	void *pg;
-	u64 hret, pt_abs, i, j, m, mr_len;
+	u64 hret;
 	u32 acc_ctrl = EHEA_MR_ACC_CTRL;
 
-	mr_len = ehea_bmap.valid_sections * EHEA_SECTSIZE;
+	unsigned long top;
 
-	pt =  kzalloc(PAGE_SIZE, GFP_KERNEL);
+	pt = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!pt) {
 		ehea_error("no mem");
 		ret = -ENOMEM;
 		goto out;
 	}
-	pt_abs = virt_to_abs(pt);
 
-	hret = ehea_h_alloc_resource_mr(adapter->handle,
-					EHEA_BUSMAP_START, mr_len,
-					acc_ctrl, adapter->pd,
+	hret = ehea_h_alloc_resource_mr(adapter->handle, EHEA_BUSMAP_START,
+					ehea_mr_len, acc_ctrl, adapter->pd,
 					&mr->handle, &mr->lkey);
+
 	if (hret != H_SUCCESS) {
 		ehea_error("alloc_resource_mr failed");
 		ret = -EIO;
 		goto out;
 	}
 
-	for (i = 0 ; i < ehea_bmap.entries; i++)
-		if (ehea_bmap.vaddr[i]) {
-			void *sectbase = __va(i << SECTION_SIZE_BITS);
-			unsigned long k = 0;
-
-			for (j = 0; j < (EHEA_PAGES_PER_SECTION /
-					 EHEA_MAX_RPAGE); j++) {
-
-				for (m = 0; m < EHEA_MAX_RPAGE; m++) {
-					pg = sectbase + ((k++) * EHEA_PAGESIZE);
-					pt[m] = virt_to_abs(pg);
-				}
-
-				hret = ehea_h_register_rpage_mr(adapter->handle,
-								mr->handle,
-								0, 0, pt_abs,
-								EHEA_MAX_RPAGE);
-				if ((hret != H_SUCCESS)
-				    && (hret != H_PAGE_REGISTERED)) {
-					ehea_h_free_resource(adapter->handle,
-							     mr->handle,
-							     FORCE_FREE);
-					ehea_error("register_rpage_mr failed");
-					ret = -EIO;
-					goto out;
-				}
-			}
-		}
+	if (!ehea_bmap) {
+		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
+		ehea_error("no busmap available");
+		ret = -EIO;
+		goto out;
+	}
+
+	for (top = 0; top < EHEA_MAP_ENTRIES; top++) {
+		if (!ehea_bmap->top[top])
+			continue;
+
+		hret = ehea_reg_mr_dir_sections(top, pt, adapter, mr);
+		if((hret != H_PAGE_REGISTERED) && (hret != H_SUCCESS))
+			break;
+	}
 
 	if (hret != H_SUCCESS) {
 		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6f22f06..25bdd08 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -635,6 +635,8 @@ static void free_skb_resources(struct gfar_private *priv)
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
 		}
+
+		txbdp++;
 	}
 
 	kfree(priv->tx_skbuff);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index ef63c8d..c91b12e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -144,11 +144,13 @@ struct myri10ge_tx_buf {
 	char *req_bytes;
 	struct myri10ge_tx_buffer_state *info;
 	int mask;		/* number of transmit slots -1  */
-	int boundary;		/* boundary transmits cannot cross */
 	int req ____cacheline_aligned;	/* transmit slots submitted     */
 	int pkt_start;		/* packets started */
+	int stop_queue;
+	int linearized;
 	int done ____cacheline_aligned;	/* transmit slots completed     */
 	int pkt_done;		/* packets completed */
+	int wake_queue;
 };
 
 struct myri10ge_rx_done {
@@ -160,29 +162,50 @@ struct myri10ge_rx_done {
 	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
 };
 
-struct myri10ge_priv {
-	int running;		/* running?             */
-	int csum_flag;		/* rx_csums?            */
+struct myri10ge_slice_netstats {
+	unsigned long rx_packets;
+	unsigned long tx_packets;
+	unsigned long rx_bytes;
+	unsigned long tx_bytes;
+	unsigned long rx_dropped;
+	unsigned long tx_dropped;
+};
+
+struct myri10ge_slice_state {
 	struct myri10ge_tx_buf tx;	/* transmit ring        */
 	struct myri10ge_rx_buf rx_small;
 	struct myri10ge_rx_buf rx_big;
 	struct myri10ge_rx_done rx_done;
+	struct net_device *dev;
+	struct napi_struct napi;
+	struct myri10ge_priv *mgp;
+	struct myri10ge_slice_netstats stats;
+	__be32 __iomem *irq_claim;
+	struct mcp_irq_data *fw_stats;
+	dma_addr_t fw_stats_bus;
+	int watchdog_tx_done;
+	int watchdog_tx_req;
+};
+
+struct myri10ge_priv {
+	struct myri10ge_slice_state ss;
+	int tx_boundary;	/* boundary transmits cannot cross */
+	int running;		/* running?             */
+	int csum_flag;		/* rx_csums?            */
 	int small_bytes;
 	int big_bytes;
+	int max_intr_slots;
 	struct net_device *dev;
-	struct napi_struct napi;
 	struct net_device_stats stats;
+	spinlock_t stats_lock;
 	u8 __iomem *sram;
 	int sram_size;
 	unsigned long board_span;
 	unsigned long iomem_base;
-	__be32 __iomem *irq_claim;
 	__be32 __iomem *irq_deassert;
 	char *mac_addr_string;
 	struct mcp_cmd_response *cmd;
 	dma_addr_t cmd_bus;
-	struct mcp_irq_data *fw_stats;
-	dma_addr_t fw_stats_bus;
 	struct pci_dev *pdev;
 	int msi_enabled;
 	u32 link_state;
@@ -191,20 +214,16 @@ struct myri10ge_priv {
 	__be32 __iomem *intr_coal_delay_ptr;
 	int mtrr;
 	int wc_enabled;
-	int wake_queue;
-	int stop_queue;
 	int down_cnt;
 	wait_queue_head_t down_wq;
 	struct work_struct watchdog_work;
 	struct timer_list watchdog_timer;
-	int watchdog_tx_done;
-	int watchdog_tx_req;
-	int watchdog_pause;
 	int watchdog_resets;
-	int tx_linearized;
+	int watchdog_pause;
 	int pause;
 	char *fw_name;
 	char eeprom_strings[MYRI10GE_EEPROM_STRINGS_SIZE];
+	char *product_code_string;
 	char fw_version[128];
 	int fw_ver_major;
 	int fw_ver_minor;
@@ -228,58 +247,54 @@ static char *myri10ge_fw_aligned = "myri10ge_eth_z8e.dat";
 
 static char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name\n");
+MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name");
 
 static int myri10ge_ecrc_enable = 1;
 module_param(myri10ge_ecrc_enable, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_ecrc_enable, "Enable Extended CRC on PCI-E\n");
-
-static int myri10ge_max_intr_slots = 1024;
-module_param(myri10ge_max_intr_slots, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_max_intr_slots, "Interrupt queue slots\n");
+MODULE_PARM_DESC(myri10ge_ecrc_enable, "Enable Extended CRC on PCI-E");
 
 static int myri10ge_small_bytes = -1;	/* -1 == auto */
 module_param(myri10ge_small_bytes, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_small_bytes, "Threshold of small packets\n");
+MODULE_PARM_DESC(myri10ge_small_bytes, "Threshold of small packets");
 
 static int myri10ge_msi = 1;	/* enable msi by default */
 module_param(myri10ge_msi, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts\n");
+MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts");
 
 static int myri10ge_intr_coal_delay = 75;
 module_param(myri10ge_intr_coal_delay, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay\n");
+MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay");
 
 static int myri10ge_flow_control = 1;
 module_param(myri10ge_flow_control, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_flow_control, "Pause parameter\n");
+MODULE_PARM_DESC(myri10ge_flow_control, "Pause parameter");
 
 static int myri10ge_deassert_wait = 1;
 module_param(myri10ge_deassert_wait, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_deassert_wait,
-		 "Wait when deasserting legacy interrupts\n");
+		 "Wait when deasserting legacy interrupts");
 
 static int myri10ge_force_firmware = 0;
 module_param(myri10ge_force_firmware, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_force_firmware,
-		 "Force firmware to assume aligned completions\n");
+		 "Force firmware to assume aligned completions");
 
 static int myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
 module_param(myri10ge_initial_mtu, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_initial_mtu, "Initial MTU\n");
+MODULE_PARM_DESC(myri10ge_initial_mtu, "Initial MTU");
 
 static int myri10ge_napi_weight = 64;
 module_param(myri10ge_napi_weight, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_napi_weight, "Set NAPI weight\n");
+MODULE_PARM_DESC(myri10ge_napi_weight, "Set NAPI weight");
 
 static int myri10ge_watchdog_timeout = 1;
 module_param(myri10ge_watchdog_timeout, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_watchdog_timeout, "Set watchdog timeout\n");
+MODULE_PARM_DESC(myri10ge_watchdog_timeout, "Set watchdog timeout");
 
 static int myri10ge_max_irq_loops = 1048576;
 module_param(myri10ge_max_irq_loops, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_max_irq_loops,
-		 "Set stuck legacy IRQ detection threshold\n");
+		 "Set stuck legacy IRQ detection threshold");
 
 #define MYRI10GE_MSG_DEFAULT NETIF_MSG_LINK
 
@@ -289,21 +304,22 @@ MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
 static int myri10ge_lro = 1;
 module_param(myri10ge_lro, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_lro, "Enable large receive offload\n");
+MODULE_PARM_DESC(myri10ge_lro, "Enable large receive offload");
 
 static int myri10ge_lro_max_pkts = MYRI10GE_LRO_MAX_PKTS;
 module_param(myri10ge_lro_max_pkts, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_lro, "Number of LRO packets to be aggregated\n");
+MODULE_PARM_DESC(myri10ge_lro_max_pkts,
+		 "Number of LRO packets to be aggregated");
 
 static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
+MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed");
 
 static int myri10ge_reset_recover = 1;
 
 static int myri10ge_wcfifo = 0;
 module_param(myri10ge_wcfifo, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
+MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled");
 
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
@@ -359,8 +375,10 @@ myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 		for (sleep_total = 0;
 		     sleep_total < 1000
 		     && response->result == htonl(MYRI10GE_NO_RESPONSE_RESULT);
-		     sleep_total += 10)
+		     sleep_total += 10) {
 			udelay(10);
+			mb();
+		}
 	} else {
 		/* use msleep for most command */
 		for (sleep_total = 0;
@@ -420,6 +438,10 @@ static int myri10ge_read_mac_addr(struct myri10ge_priv *mgp)
 				ptr += 1;
 			}
 		}
+		if (memcmp(ptr, "PC=", 3) == 0) {
+			ptr += 3;
+			mgp->product_code_string = ptr;
+		}
 		if (memcmp((const void *)ptr, "SN=", 3) == 0) {
 			ptr += 3;
 			mgp->serial_number = simple_strtoul(ptr, &ptr, 10);
@@ -442,7 +464,7 @@ abort:
 static void myri10ge_dummy_rdma(struct myri10ge_priv *mgp, int enable)
 {
 	char __iomem *submit;
-	__be32 buf[16];
+	__be32 buf[16] __attribute__ ((__aligned__(8)));
 	u32 dma_low, dma_high;
 	int i;
 
@@ -609,13 +631,38 @@ static int myri10ge_adopt_running_firmware(struct myri10ge_priv *mgp)
 	return status;
 }
 
+int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int status;
+
+	/* probe for IPv6 TSO support */
+	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+				   &cmd, 0);
+	if (status == 0) {
+		mgp->max_tso6 = cmd.data0;
+		mgp->features |= NETIF_F_TSO6;
+	}
+
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev,
+			"failed MXGEFW_CMD_GET_RX_RING_SIZE\n");
+		return -ENXIO;
+	}
+
+	mgp->max_intr_slots = 2 * (cmd.data0 / sizeof(struct mcp_dma_addr));
+
+	return 0;
+}
+
 static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 {
 	char __iomem *submit;
-	__be32 buf[16];
+	__be32 buf[16] __attribute__ ((__aligned__(8)));
 	u32 dma_low, dma_high, size;
 	int status, i;
-	struct myri10ge_cmd cmd;
 
 	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
@@ -635,7 +682,7 @@ static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 		}
 		dev_info(&mgp->pdev->dev,
 			 "Successfully adopted running firmware\n");
-		if (mgp->tx.boundary == 4096) {
+		if (mgp->tx_boundary == 4096) {
 			dev_warn(&mgp->pdev->dev,
 				 "Using firmware currently running on NIC"
 				 ".  For optimal\n");
@@ -646,7 +693,9 @@ static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 		}
 
 		mgp->fw_name = "adopted";
-		mgp->tx.boundary = 2048;
+		mgp->tx_boundary = 2048;
+		myri10ge_dummy_rdma(mgp, 1);
+		status = myri10ge_get_firmware_capabilities(mgp);
 		return status;
 	}
 
@@ -681,26 +730,18 @@ static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 	msleep(1);
 	mb();
 	i = 0;
-	while (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 20) {
-		msleep(1);
+	while (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 9) {
+		msleep(1 << i);
 		i++;
 	}
 	if (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA) {
 		dev_err(&mgp->pdev->dev, "handoff failed\n");
 		return -ENXIO;
 	}
-	dev_info(&mgp->pdev->dev, "handoff confirmed\n");
 	myri10ge_dummy_rdma(mgp, 1);
+	status = myri10ge_get_firmware_capabilities(mgp);
 
-	/* probe for IPv6 TSO support */
-	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
-				   &cmd, 0);
-	if (status == 0) {
-		mgp->max_tso6 = cmd.data0;
-		mgp->features |= NETIF_F_TSO6;
-	}
-	return 0;
+	return status;
 }
 
 static int myri10ge_update_mac_address(struct myri10ge_priv *mgp, u8 * addr)
@@ -772,7 +813,7 @@ static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
 	 * transfers took to complete.
 	 */
 
-	len = mgp->tx.boundary;
+	len = mgp->tx_boundary;
 
 	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
 	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
@@ -834,17 +875,17 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 
 	/* Now exchange information about interrupts  */
 
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	memset(mgp->rx_done.entry, 0, bytes);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	memset(mgp->ss.rx_done.entry, 0, bytes);
 	cmd.data0 = (u32) bytes;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.rx_done.bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.rx_done.bus);
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA, &cmd, 0);
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_ACK_OFFSET, &cmd, 0);
-	mgp->irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
+	mgp->ss.irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
 				    &cmd, 0);
 	mgp->irq_deassert = (__iomem __be32 *) (mgp->sram + cmd.data0);
@@ -858,17 +899,17 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-	memset(mgp->rx_done.entry, 0, bytes);
+	memset(mgp->ss.rx_done.entry, 0, bytes);
 
 	/* reset mcp/driver shared state back to 0 */
-	mgp->tx.req = 0;
-	mgp->tx.done = 0;
-	mgp->tx.pkt_start = 0;
-	mgp->tx.pkt_done = 0;
-	mgp->rx_big.cnt = 0;
-	mgp->rx_small.cnt = 0;
-	mgp->rx_done.idx = 0;
-	mgp->rx_done.cnt = 0;
+	mgp->ss.tx.req = 0;
+	mgp->ss.tx.done = 0;
+	mgp->ss.tx.pkt_start = 0;
+	mgp->ss.tx.pkt_done = 0;
+	mgp->ss.rx_big.cnt = 0;
+	mgp->ss.rx_small.cnt = 0;
+	mgp->ss.rx_done.idx = 0;
+	mgp->ss.rx_done.cnt = 0;
 	mgp->link_changes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_pause(mgp, mgp->pause);
@@ -1020,9 +1061,10 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
 				 * page into an skb */
 
 static inline int
-myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
+myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 		 int bytes, int len, __wsum csum)
 {
+	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
 	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
 	int i, idx, hlen, remainder;
@@ -1052,11 +1094,10 @@ myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 		rx_frags[0].page_offset += MXGEFW_PAD;
 		rx_frags[0].size -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
-		lro_receive_frags(&mgp->rx_done.lro_mgr, rx_frags,
+		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
 				  len, len,
-				 /* opaque, will come back in get_frag_header */
-				  (void *)(__force unsigned long)csum,
-				  csum);
+				  /* opaque, will come back in get_frag_header */
+				  (void *)(__force unsigned long)csum, csum);
 		return 1;
 	}
 
@@ -1096,10 +1137,11 @@ myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 	return 1;
 }
 
-static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
+static inline void
+myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 {
-	struct pci_dev *pdev = mgp->pdev;
-	struct myri10ge_tx_buf *tx = &mgp->tx;
+	struct pci_dev *pdev = ss->mgp->pdev;
+	struct myri10ge_tx_buf *tx = &ss->tx;
 	struct sk_buff *skb;
 	int idx, len;
 
@@ -1117,8 +1159,8 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 		len = pci_unmap_len(&tx->info[idx], len);
 		pci_unmap_len_set(&tx->info[idx], len, 0);
 		if (skb) {
-			mgp->stats.tx_bytes += skb->len;
-			mgp->stats.tx_packets++;
+			ss->stats.tx_bytes += skb->len;
+			ss->stats.tx_packets++;
 			dev_kfree_skb_irq(skb);
 			if (len)
 				pci_unmap_single(pdev,
@@ -1134,16 +1176,18 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 		}
 	}
 	/* start the queue if we've stopped it */
-	if (netif_queue_stopped(mgp->dev)
+	if (netif_queue_stopped(ss->dev)
 	    && tx->req - tx->done < (tx->mask >> 1)) {
-		mgp->wake_queue++;
-		netif_wake_queue(mgp->dev);
+		tx->wake_queue++;
+		netif_wake_queue(ss->dev);
 	}
 }
 
-static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
+static inline int
+myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 {
-	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
+	struct myri10ge_rx_done *rx_done = &ss->rx_done;
+	struct myri10ge_priv *mgp = ss->mgp;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1159,40 +1203,40 @@ static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
 		if (length <= mgp->small_bytes)
-			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_small,
+			rx_ok = myri10ge_rx_done(ss, &ss->rx_small,
 						 mgp->small_bytes,
 						 length, checksum);
 		else
-			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_big,
+			rx_ok = myri10ge_rx_done(ss, &ss->rx_big,
 						 mgp->big_bytes,
 						 length, checksum);
 		rx_packets += rx_ok;
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
-		idx = cnt & (myri10ge_max_intr_slots - 1);
+		idx = cnt & (mgp->max_intr_slots - 1);
 		work_done++;
 	}
 	rx_done->idx = idx;
 	rx_done->cnt = cnt;
-	mgp->stats.rx_packets += rx_packets;
-	mgp->stats.rx_bytes += rx_bytes;
+	ss->stats.rx_packets += rx_packets;
+	ss->stats.rx_bytes += rx_bytes;
 
 	if (myri10ge_lro)
 		lro_flush_all(&rx_done->lro_mgr);
 
 	/* restock receive rings if needed */
-	if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt < myri10ge_fill_thresh)
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+	if (ss->rx_small.fill_cnt - ss->rx_small.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
 					mgp->small_bytes + MXGEFW_PAD, 0);
-	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
+	if (ss->rx_big.fill_cnt - ss->rx_big.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
 
 	return work_done;
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 {
-	struct mcp_irq_data *stats = mgp->fw_stats;
+	struct mcp_irq_data *stats = mgp->ss.fw_stats;
 
 	if (unlikely(stats->stats_updated)) {
 		unsigned link_up = ntohl(stats->link_up);
@@ -1219,9 +1263,9 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 			}
 		}
 		if (mgp->rdma_tags_available !=
-		    ntohl(mgp->fw_stats->rdma_tags_available)) {
+		    ntohl(stats->rdma_tags_available)) {
 			mgp->rdma_tags_available =
-			    ntohl(mgp->fw_stats->rdma_tags_available);
+			    ntohl(stats->rdma_tags_available);
 			printk(KERN_WARNING "myri10ge: %s: RDMA timed out! "
 			       "%d tags left\n", mgp->dev->name,
 			       mgp->rdma_tags_available);
@@ -1234,26 +1278,27 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 
 static int myri10ge_poll(struct napi_struct *napi, int budget)
 {
-	struct myri10ge_priv *mgp =
-	    container_of(napi, struct myri10ge_priv, napi);
-	struct net_device *netdev = mgp->dev;
+	struct myri10ge_slice_state *ss =
+	    container_of(napi, struct myri10ge_slice_state, napi);
+	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
 	/* process as many rx events as NAPI will allow */
-	work_done = myri10ge_clean_rx_done(mgp, budget);
+	work_done = myri10ge_clean_rx_done(ss, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
-		put_be32(htonl(3), mgp->irq_claim);
+		put_be32(htonl(3), ss->irq_claim);
 	}
 	return work_done;
 }
 
 static irqreturn_t myri10ge_intr(int irq, void *arg)
 {
-	struct myri10ge_priv *mgp = arg;
-	struct mcp_irq_data *stats = mgp->fw_stats;
-	struct myri10ge_tx_buf *tx = &mgp->tx;
+	struct myri10ge_slice_state *ss = arg;
+	struct myri10ge_priv *mgp = ss->mgp;
+	struct mcp_irq_data *stats = ss->fw_stats;
+	struct myri10ge_tx_buf *tx = &ss->tx;
 	u32 send_done_count;
 	int i;
 
@@ -1264,7 +1309,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
 	if (stats->valid & 1)
-		netif_rx_schedule(mgp->dev, &mgp->napi);
+		netif_rx_schedule(ss->dev, &ss->napi);
 
 	if (!mgp->msi_enabled) {
 		put_be32(0, mgp->irq_deassert);
@@ -1281,7 +1326,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 		/* check for transmit completes and receives */
 		send_done_count = ntohl(stats->send_done_count);
 		if (send_done_count != tx->pkt_done)
-			myri10ge_tx_done(mgp, (int)send_done_count);
+			myri10ge_tx_done(ss, (int)send_done_count);
 		if (unlikely(i > myri10ge_max_irq_loops)) {
 			printk(KERN_WARNING "myri10ge: %s: irq stuck?\n",
 			       mgp->dev->name);
@@ -1296,16 +1341,46 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 
 	myri10ge_check_statblock(mgp);
 
-	put_be32(htonl(3), mgp->irq_claim + 1);
+	put_be32(htonl(3), ss->irq_claim + 1);
 	return (IRQ_HANDLED);
 }
 
 static int
 myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	char *ptr;
+	int i;
+
 	cmd->autoneg = AUTONEG_DISABLE;
 	cmd->speed = SPEED_10000;
 	cmd->duplex = DUPLEX_FULL;
+
+	/*
+	 * parse the product code to deterimine the interface type
+	 * (CX4, XFP, Quad Ribbon Fiber) by looking at the character
+	 * after the 3rd dash in the driver's cached copy of the
+	 * EEPROM's product code string.
+	 */
+	ptr = mgp->product_code_string;
+	if (ptr == NULL) {
+		printk(KERN_ERR "myri10ge: %s: Missing product code\n",
+		       netdev->name);
+		return 0;
+	}
+	for (i = 0; i < 3; i++, ptr++) {
+		ptr = strchr(ptr, '-');
+		if (ptr == NULL) {
+			printk(KERN_ERR "myri10ge: %s: Invalid product "
+			       "code %s\n", netdev->name,
+			       mgp->product_code_string);
+			return 0;
+		}
+	}
+	if (*ptr == 'R' || *ptr == 'Q') {
+		/* We've found either an XFP or quad ribbon fiber */
+		cmd->port = PORT_FIBRE;
+	}
 	return 0;
 }
 
@@ -1324,6 +1399,7 @@ static int
 myri10ge_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	coal->rx_coalesce_usecs = mgp->intr_coal_delay;
 	return 0;
 }
@@ -1370,10 +1446,10 @@ myri10ge_get_ringparam(struct net_device *netdev,
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 
-	ring->rx_mini_max_pending = mgp->rx_small.mask + 1;
-	ring->rx_max_pending = mgp->rx_big.mask + 1;
+	ring->rx_mini_max_pending = mgp->ss.rx_small.mask + 1;
+	ring->rx_max_pending = mgp->ss.rx_big.mask + 1;
 	ring->rx_jumbo_max_pending = 0;
-	ring->tx_max_pending = mgp->rx_small.mask + 1;
+	ring->tx_max_pending = mgp->ss.rx_small.mask + 1;
 	ring->rx_mini_pending = ring->rx_mini_max_pending;
 	ring->rx_pending = ring->rx_max_pending;
 	ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;
@@ -1383,6 +1459,7 @@ myri10ge_get_ringparam(struct net_device *netdev,
 static u32 myri10ge_get_rx_csum(struct net_device *netdev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	if (mgp->csum_flag)
 		return 1;
 	else
@@ -1392,6 +1469,7 @@ static u32 myri10ge_get_rx_csum(struct net_device *netdev)
 static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	if (csum_enabled)
 		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	else
@@ -1411,7 +1489,7 @@ static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
 	return 0;
 }
 
-static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
+static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
 	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
@@ -1421,28 +1499,39 @@ static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
 	/* device-specific stats */
 	"tx_boundary", "WC", "irq", "MSI",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
-	"serial_number", "tx_pkt_start", "tx_pkt_done",
-	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
-	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
+	"serial_number", "watchdog_resets",
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered",
 	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
 	"dropped_unicast_filtered", "dropped_multicast_filtered",
 	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
-	"dropped_no_big_buffer", "LRO aggregated", "LRO flushed",
+	"dropped_no_big_buffer"
+};
+
+static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
+	"----------- slice ---------",
+	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
+	"rx_small_cnt", "rx_big_cnt",
+	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
+	    "LRO flushed",
 	"LRO avg aggr", "LRO no_desc"
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
-#define MYRI10GE_STATS_LEN	ARRAY_SIZE(myri10ge_gstrings_stats)
+#define MYRI10GE_MAIN_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_main_stats)
+#define MYRI10GE_SLICE_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_slice_stats)
 
 static void
 myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
 {
 	switch (stringset) {
 	case ETH_SS_STATS:
-		memcpy(data, *myri10ge_gstrings_stats,
-		       sizeof(myri10ge_gstrings_stats));
+		memcpy(data, *myri10ge_gstrings_main_stats,
+		       sizeof(myri10ge_gstrings_main_stats));
+		data += sizeof(myri10ge_gstrings_main_stats);
+		memcpy(data, *myri10ge_gstrings_slice_stats,
+		       sizeof(myri10ge_gstrings_slice_stats));
+		data += sizeof(myri10ge_gstrings_slice_stats);
 		break;
 	}
 }
@@ -1451,7 +1540,7 @@ static int myri10ge_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MYRI10GE_STATS_LEN;
+		return MYRI10GE_MAIN_STATS_LEN + MYRI10GE_SLICE_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1462,12 +1551,13 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 			   struct ethtool_stats *stats, u64 * data)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	struct myri10ge_slice_state *ss;
 	int i;
 
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
 		data[i] = ((unsigned long *)&mgp->stats)[i];
 
-	data[i++] = (unsigned int)mgp->tx.boundary;
+	data[i++] = (unsigned int)mgp->tx_boundary;
 	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
@@ -1475,40 +1565,44 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)mgp->write_dma;
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
-	data[i++] = (unsigned int)mgp->tx.pkt_start;
-	data[i++] = (unsigned int)mgp->tx.pkt_done;
-	data[i++] = (unsigned int)mgp->tx.req;
-	data[i++] = (unsigned int)mgp->tx.done;
-	data[i++] = (unsigned int)mgp->rx_small.cnt;
-	data[i++] = (unsigned int)mgp->rx_big.cnt;
-	data[i++] = (unsigned int)mgp->wake_queue;
-	data[i++] = (unsigned int)mgp->stop_queue;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
-	data[i++] = (unsigned int)mgp->tx_linearized;
 	data[i++] = (unsigned int)mgp->link_changes;
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->link_up);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
-	data[i++] =
-	    (unsigned int)ntohl(mgp->fw_stats->dropped_link_error_or_filtered);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_pause);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_phy);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_crc32);
+
+	/* firmware stats are useful only in the first slice */
+	ss = &mgp->ss;
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->link_up);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_link_overflow);
 	data[i++] =
-	    (unsigned int)ntohl(mgp->fw_stats->dropped_unicast_filtered);
+	    (unsigned int)ntohl(ss->fw_stats->dropped_link_error_or_filtered);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_pause);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_phy);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_crc32);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_unicast_filtered);
 	data[i++] =
-	    (unsigned int)ntohl(mgp->fw_stats->dropped_multicast_filtered);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_runt);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_overrun);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_small_buffer);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_big_buffer);
-	data[i++] = mgp->rx_done.lro_mgr.stats.aggregated;
-	data[i++] = mgp->rx_done.lro_mgr.stats.flushed;
-	if (mgp->rx_done.lro_mgr.stats.flushed)
-		data[i++] = mgp->rx_done.lro_mgr.stats.aggregated /
-		    mgp->rx_done.lro_mgr.stats.flushed;
+	    (unsigned int)ntohl(ss->fw_stats->dropped_multicast_filtered);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_runt);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_overrun);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_small_buffer);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_big_buffer);
+
+	data[i++] = 0;
+	data[i++] = (unsigned int)ss->tx.pkt_start;
+	data[i++] = (unsigned int)ss->tx.pkt_done;
+	data[i++] = (unsigned int)ss->tx.req;
+	data[i++] = (unsigned int)ss->tx.done;
+	data[i++] = (unsigned int)ss->rx_small.cnt;
+	data[i++] = (unsigned int)ss->rx_big.cnt;
+	data[i++] = (unsigned int)ss->tx.wake_queue;
+	data[i++] = (unsigned int)ss->tx.stop_queue;
+	data[i++] = (unsigned int)ss->tx.linearized;
+	data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
+	data[i++] = ss->rx_done.lro_mgr.stats.flushed;
+	if (ss->rx_done.lro_mgr.stats.flushed)
+		data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
+		    ss->rx_done.lro_mgr.stats.flushed;
 	else
 		data[i++] = 0;
-	data[i++] = mgp->rx_done.lro_mgr.stats.no_desc;
+	data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
 }
 
 static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
@@ -1544,19 +1638,17 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.get_msglevel = myri10ge_get_msglevel
 };
 
-static int myri10ge_allocate_rings(struct net_device *dev)
+static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = ss->mgp;
 	struct myri10ge_cmd cmd;
+	struct net_device *dev = mgp->dev;
 	int tx_ring_size, rx_ring_size;
 	int tx_ring_entries, rx_ring_entries;
 	int i, status;
 	size_t bytes;
 
-	mgp = netdev_priv(dev);
-
 	/* get ring sizes */
-
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_RING_SIZE, &cmd, 0);
 	tx_ring_size = cmd.data0;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
@@ -1566,144 +1658,142 @@ static int myri10ge_allocate_rings(struct net_device *dev)
 
 	tx_ring_entries = tx_ring_size / sizeof(struct mcp_kreq_ether_send);
 	rx_ring_entries = rx_ring_size / sizeof(struct mcp_dma_addr);
-	mgp->tx.mask = tx_ring_entries - 1;
-	mgp->rx_small.mask = mgp->rx_big.mask = rx_ring_entries - 1;
+	ss->tx.mask = tx_ring_entries - 1;
+	ss->rx_small.mask = ss->rx_big.mask = rx_ring_entries - 1;
 
 	status = -ENOMEM;
 
 	/* allocate the host shadow rings */
 
 	bytes = 8 + (MYRI10GE_MAX_SEND_DESC_TSO + 4)
-	    * sizeof(*mgp->tx.req_list);
-	mgp->tx.req_bytes = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->tx.req_bytes == NULL)
+	    * sizeof(*ss->tx.req_list);
+	ss->tx.req_bytes = kzalloc(bytes, GFP_KERNEL);
+	if (ss->tx.req_bytes == NULL)
 		goto abort_with_nothing;
 
 	/* ensure req_list entries are aligned to 8 bytes */
-	mgp->tx.req_list = (struct mcp_kreq_ether_send *)
-	    ALIGN((unsigned long)mgp->tx.req_bytes, 8);
+	ss->tx.req_list = (struct mcp_kreq_ether_send *)
+	    ALIGN((unsigned long)ss->tx.req_bytes, 8);
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_small.shadow);
-	mgp->rx_small.shadow = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_small.shadow == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_small.shadow);
+	ss->rx_small.shadow = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_small.shadow == NULL)
 		goto abort_with_tx_req_bytes;
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_big.shadow);
-	mgp->rx_big.shadow = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_big.shadow == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_big.shadow);
+	ss->rx_big.shadow = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_big.shadow == NULL)
 		goto abort_with_rx_small_shadow;
 
 	/* allocate the host info rings */
 
-	bytes = tx_ring_entries * sizeof(*mgp->tx.info);
-	mgp->tx.info = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->tx.info == NULL)
+	bytes = tx_ring_entries * sizeof(*ss->tx.info);
+	ss->tx.info = kzalloc(bytes, GFP_KERNEL);
+	if (ss->tx.info == NULL)
 		goto abort_with_rx_big_shadow;
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_small.info);
-	mgp->rx_small.info = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_small.info == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_small.info);
+	ss->rx_small.info = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_small.info == NULL)
 		goto abort_with_tx_info;
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_big.info);
-	mgp->rx_big.info = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_big.info == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_big.info);
+	ss->rx_big.info = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_big.info == NULL)
 		goto abort_with_rx_small_info;
 
 	/* Fill the receive rings */
-	mgp->rx_big.cnt = 0;
-	mgp->rx_small.cnt = 0;
-	mgp->rx_big.fill_cnt = 0;
-	mgp->rx_small.fill_cnt = 0;
-	mgp->rx_small.page_offset = MYRI10GE_ALLOC_SIZE;
-	mgp->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
-	mgp->rx_small.watchdog_needed = 0;
-	mgp->rx_big.watchdog_needed = 0;
-	myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+	ss->rx_big.cnt = 0;
+	ss->rx_small.cnt = 0;
+	ss->rx_big.fill_cnt = 0;
+	ss->rx_small.fill_cnt = 0;
+	ss->rx_small.page_offset = MYRI10GE_ALLOC_SIZE;
+	ss->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
+	ss->rx_small.watchdog_needed = 0;
+	ss->rx_big.watchdog_needed = 0;
+	myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
 				mgp->small_bytes + MXGEFW_PAD, 0);
 
-	if (mgp->rx_small.fill_cnt < mgp->rx_small.mask + 1) {
+	if (ss->rx_small.fill_cnt < ss->rx_small.mask + 1) {
 		printk(KERN_ERR "myri10ge: %s: alloced only %d small bufs\n",
-		       dev->name, mgp->rx_small.fill_cnt);
+		       dev->name, ss->rx_small.fill_cnt);
 		goto abort_with_rx_small_ring;
 	}
 
-	myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
-	if (mgp->rx_big.fill_cnt < mgp->rx_big.mask + 1) {
+	myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
+	if (ss->rx_big.fill_cnt < ss->rx_big.mask + 1) {
 		printk(KERN_ERR "myri10ge: %s: alloced only %d big bufs\n",
-		       dev->name, mgp->rx_big.fill_cnt);
+		       dev->name, ss->rx_big.fill_cnt);
 		goto abort_with_rx_big_ring;
 	}
 
 	return 0;
 
 abort_with_rx_big_ring:
-	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
-		int idx = i & mgp->rx_big.mask;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+	for (i = ss->rx_big.cnt; i < ss->rx_big.fill_cnt; i++) {
+		int idx = i & ss->rx_big.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_big.info[idx],
 				       mgp->big_bytes);
-		put_page(mgp->rx_big.info[idx].page);
+		put_page(ss->rx_big.info[idx].page);
 	}
 
 abort_with_rx_small_ring:
-	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
-		int idx = i & mgp->rx_small.mask;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+	for (i = ss->rx_small.cnt; i < ss->rx_small.fill_cnt; i++) {
+		int idx = i & ss->rx_small.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_small.info[idx],
 				       mgp->small_bytes + MXGEFW_PAD);
-		put_page(mgp->rx_small.info[idx].page);
+		put_page(ss->rx_small.info[idx].page);
 	}
 
-	kfree(mgp->rx_big.info);
+	kfree(ss->rx_big.info);
 
 abort_with_rx_small_info:
-	kfree(mgp->rx_small.info);
+	kfree(ss->rx_small.info);
 
 abort_with_tx_info:
-	kfree(mgp->tx.info);
+	kfree(ss->tx.info);
 
 abort_with_rx_big_shadow:
-	kfree(mgp->rx_big.shadow);
+	kfree(ss->rx_big.shadow);
 
 abort_with_rx_small_shadow:
-	kfree(mgp->rx_small.shadow);
+	kfree(ss->rx_small.shadow);
 
 abort_with_tx_req_bytes:
-	kfree(mgp->tx.req_bytes);
-	mgp->tx.req_bytes = NULL;
-	mgp->tx.req_list = NULL;
+	kfree(ss->tx.req_bytes);
+	ss->tx.req_bytes = NULL;
+	ss->tx.req_list = NULL;
 
 abort_with_nothing:
 	return status;
 }
 
-static void myri10ge_free_rings(struct net_device *dev)
+static void myri10ge_free_rings(struct myri10ge_slice_state *ss)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
 	struct myri10ge_tx_buf *tx;
 	int i, len, idx;
 
-	mgp = netdev_priv(dev);
-
-	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
-		idx = i & mgp->rx_big.mask;
-		if (i == mgp->rx_big.fill_cnt - 1)
-			mgp->rx_big.info[idx].page_offset = MYRI10GE_ALLOC_SIZE;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+	for (i = ss->rx_big.cnt; i < ss->rx_big.fill_cnt; i++) {
+		idx = i & ss->rx_big.mask;
+		if (i == ss->rx_big.fill_cnt - 1)
+			ss->rx_big.info[idx].page_offset = MYRI10GE_ALLOC_SIZE;
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_big.info[idx],
 				       mgp->big_bytes);
-		put_page(mgp->rx_big.info[idx].page);
+		put_page(ss->rx_big.info[idx].page);
 	}
 
-	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
-		idx = i & mgp->rx_small.mask;
-		if (i == mgp->rx_small.fill_cnt - 1)
-			mgp->rx_small.info[idx].page_offset =
+	for (i = ss->rx_small.cnt; i < ss->rx_small.fill_cnt; i++) {
+		idx = i & ss->rx_small.mask;
+		if (i == ss->rx_small.fill_cnt - 1)
+			ss->rx_small.info[idx].page_offset =
 			    MYRI10GE_ALLOC_SIZE;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_small.info[idx],
 				       mgp->small_bytes + MXGEFW_PAD);
-		put_page(mgp->rx_small.info[idx].page);
+		put_page(ss->rx_small.info[idx].page);
 	}
-	tx = &mgp->tx;
+	tx = &ss->tx;
 	while (tx->done != tx->req) {
 		idx = tx->done & tx->mask;
 		skb = tx->info[idx].skb;
@@ -1714,7 +1804,7 @@ static void myri10ge_free_rings(struct net_device *dev)
 		len = pci_unmap_len(&tx->info[idx], len);
 		pci_unmap_len_set(&tx->info[idx], len, 0);
 		if (skb) {
-			mgp->stats.tx_dropped++;
+			ss->stats.tx_dropped++;
 			dev_kfree_skb_any(skb);
 			if (len)
 				pci_unmap_single(mgp->pdev,
@@ -1729,19 +1819,19 @@ static void myri10ge_free_rings(struct net_device *dev)
 					       PCI_DMA_TODEVICE);
 		}
 	}
-	kfree(mgp->rx_big.info);
+	kfree(ss->rx_big.info);
 
-	kfree(mgp->rx_small.info);
+	kfree(ss->rx_small.info);
 
-	kfree(mgp->tx.info);
+	kfree(ss->tx.info);
 
-	kfree(mgp->rx_big.shadow);
+	kfree(ss->rx_big.shadow);
 
-	kfree(mgp->rx_small.shadow);
+	kfree(ss->rx_small.shadow);
 
-	kfree(mgp->tx.req_bytes);
-	mgp->tx.req_bytes = NULL;
-	mgp->tx.req_list = NULL;
+	kfree(ss->tx.req_bytes);
+	ss->tx.req_bytes = NULL;
+	ss->tx.req_list = NULL;
 }
 
 static int myri10ge_request_irq(struct myri10ge_priv *mgp)
@@ -1840,13 +1930,11 @@ myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
 
 static int myri10ge_open(struct net_device *dev)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	struct net_lro_mgr *lro_mgr;
 	int status, big_pow2;
 
-	mgp = netdev_priv(dev);
-
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
 
@@ -1883,16 +1971,16 @@ static int myri10ge_open(struct net_device *dev)
 	/* get the lanai pointers to the send and receive rings */
 
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
-	mgp->tx.lanai =
+	mgp->ss.tx.lanai =
 	    (struct mcp_kreq_ether_send __iomem *)(mgp->sram + cmd.data0);
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET, &cmd, 0);
-	mgp->rx_small.lanai =
+	mgp->ss.rx_small.lanai =
 	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
 
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_BIG_RX_OFFSET, &cmd, 0);
-	mgp->rx_big.lanai =
+	mgp->ss.rx_big.lanai =
 	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
 
 	if (status != 0) {
@@ -1904,15 +1992,15 @@ static int myri10ge_open(struct net_device *dev)
 	}
 
 	if (myri10ge_wcfifo && mgp->wc_enabled) {
-		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
-		mgp->rx_small.wc_fifo =
+		mgp->ss.tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
+		mgp->ss.rx_small.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
-		mgp->rx_big.wc_fifo =
+		mgp->ss.rx_big.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_BIG;
 	} else {
-		mgp->tx.wc_fifo = NULL;
-		mgp->rx_small.wc_fifo = NULL;
-		mgp->rx_big.wc_fifo = NULL;
+		mgp->ss.tx.wc_fifo = NULL;
+		mgp->ss.rx_small.wc_fifo = NULL;
+		mgp->ss.rx_big.wc_fifo = NULL;
 	}
 
 	/* Firmware needs the big buff size as a power of 2.  Lie and
@@ -1929,7 +2017,7 @@ static int myri10ge_open(struct net_device *dev)
 		mgp->big_bytes = big_pow2;
 	}
 
-	status = myri10ge_allocate_rings(dev);
+	status = myri10ge_allocate_rings(&mgp->ss);
 	if (status != 0)
 		goto abort_with_irq;
 
@@ -1948,12 +2036,12 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_rings;
 	}
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->fw_stats_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->fw_stats_bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.fw_stats_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.fw_stats_bus);
 	cmd.data2 = sizeof(struct mcp_irq_data);
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
 	if (status == -ENOSYS) {
-		dma_addr_t bus = mgp->fw_stats_bus;
+		dma_addr_t bus = mgp->ss.fw_stats_bus;
 		bus += offsetof(struct mcp_irq_data, send_done_count);
 		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
 		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
@@ -1974,20 +2062,20 @@ static int myri10ge_open(struct net_device *dev)
 	mgp->link_state = ~0U;
 	mgp->rdma_tags_available = 15;
 
-	lro_mgr = &mgp->rx_done.lro_mgr;
+	lro_mgr = &mgp->ss.rx_done.lro_mgr;
 	lro_mgr->dev = dev;
 	lro_mgr->features = LRO_F_NAPI;
 	lro_mgr->ip_summed = CHECKSUM_COMPLETE;
 	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
 	lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
-	lro_mgr->lro_arr = mgp->rx_done.lro_desc;
+	lro_mgr->lro_arr = mgp->ss.rx_done.lro_desc;
 	lro_mgr->get_frag_header = myri10ge_get_frag_header;
 	lro_mgr->max_aggr = myri10ge_lro_max_pkts;
 	lro_mgr->frag_align_pad = 2;
 	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
 		lro_mgr->max_aggr = MAX_SKB_FRAGS;
 
-	napi_enable(&mgp->napi);	/* must happen prior to any irq */
+	napi_enable(&mgp->ss.napi);	/* must happen prior to any irq */
 
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);
 	if (status) {
@@ -1996,8 +2084,8 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_rings;
 	}
 
-	mgp->wake_queue = 0;
-	mgp->stop_queue = 0;
+	mgp->ss.tx.wake_queue = 0;
+	mgp->ss.tx.stop_queue = 0;
 	mgp->running = MYRI10GE_ETH_RUNNING;
 	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
 	add_timer(&mgp->watchdog_timer);
@@ -2005,7 +2093,7 @@ static int myri10ge_open(struct net_device *dev)
 	return 0;
 
 abort_with_rings:
-	myri10ge_free_rings(dev);
+	myri10ge_free_rings(&mgp->ss);
 
 abort_with_irq:
 	myri10ge_free_irq(mgp);
@@ -2017,21 +2105,19 @@ abort_with_nothing:
 
 static int myri10ge_close(struct net_device *dev)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	int status, old_down_cnt;
 
-	mgp = netdev_priv(dev);
-
 	if (mgp->running != MYRI10GE_ETH_RUNNING)
 		return 0;
 
-	if (mgp->tx.req_bytes == NULL)
+	if (mgp->ss.tx.req_bytes == NULL)
 		return 0;
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
-	napi_disable(&mgp->napi);
+	napi_disable(&mgp->ss.napi);
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 	old_down_cnt = mgp->down_cnt;
@@ -2047,7 +2133,7 @@ static int myri10ge_close(struct net_device *dev)
 
 	netif_tx_disable(dev);
 	myri10ge_free_irq(mgp);
-	myri10ge_free_rings(dev);
+	myri10ge_free_rings(&mgp->ss);
 
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return 0;
@@ -2143,7 +2229,7 @@ myri10ge_submit_req_wc(struct myri10ge_tx_buf *tx,
 
 /*
  * Transmit a packet.  We need to split the packet so that a single
- * segment does not cross myri10ge->tx.boundary, so this makes segment
+ * segment does not cross myri10ge->tx_boundary, so this makes segment
  * counting tricky.  So rather than try to count segments up front, we
  * just give up if there are too few segments to hold a reasonably
  * fragmented packet currently available.  If we run
@@ -2154,8 +2240,9 @@ myri10ge_submit_req_wc(struct myri10ge_tx_buf *tx,
 static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
+	struct myri10ge_slice_state *ss;
 	struct mcp_kreq_ether_send *req;
-	struct myri10ge_tx_buf *tx = &mgp->tx;
+	struct myri10ge_tx_buf *tx;
 	struct skb_frag_struct *frag;
 	dma_addr_t bus;
 	u32 low;
@@ -2166,6 +2253,9 @@ static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 	int cum_len, seglen, boundary, rdma_count;
 	u8 flags, odd_flag;
 
+	/* always transmit through slot 0 */
+	ss = &mgp->ss;
+	tx = &ss->tx;
 again:
 	req = tx->req_list;
 	avail = tx->mask - 1 - (tx->req - tx->done);
@@ -2180,7 +2270,7 @@ again:
 
 	if ((unlikely(avail < max_segments))) {
 		/* we are out of transmit resources */
-		mgp->stop_queue++;
+		tx->stop_queue++;
 		netif_stop_queue(dev);
 		return 1;
 	}
@@ -2242,7 +2332,7 @@ again:
 			if (skb_padto(skb, ETH_ZLEN)) {
 				/* The packet is gone, so we must
 				 * return 0 */
-				mgp->stats.tx_dropped += 1;
+				ss->stats.tx_dropped += 1;
 				return 0;
 			}
 			/* adjust the len to account for the zero pad
@@ -2284,7 +2374,7 @@ again:
 
 	while (1) {
 		/* Break the SKB or Fragment up into pieces which
-		 * do not cross mgp->tx.boundary */
+		 * do not cross mgp->tx_boundary */
 		low = MYRI10GE_LOWPART_TO_U32(bus);
 		high_swapped = htonl(MYRI10GE_HIGHPART_TO_U32(bus));
 		while (len) {
@@ -2294,7 +2384,8 @@ again:
 			if (unlikely(count == max_segments))
 				goto abort_linearize;
 
-			boundary = (low + tx->boundary) & ~(tx->boundary - 1);
+			boundary =
+			    (low + mgp->tx_boundary) & ~(mgp->tx_boundary - 1);
 			seglen = boundary - low;
 			if (seglen > len)
 				seglen = len;
@@ -2378,7 +2469,7 @@ again:
 		myri10ge_submit_req_wc(tx, tx->req_list, count);
 	tx->pkt_start++;
 	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
-		mgp->stop_queue++;
+		tx->stop_queue++;
 		netif_stop_queue(dev);
 	}
 	dev->trans_start = jiffies;
@@ -2420,12 +2511,12 @@ abort_linearize:
 	if (skb_linearize(skb))
 		goto drop;
 
-	mgp->tx_linearized++;
+	tx->linearized++;
 	goto again;
 
 drop:
 	dev_kfree_skb_any(skb);
-	mgp->stats.tx_dropped += 1;
+	ss->stats.tx_dropped += 1;
 	return 0;
 
 }
@@ -2433,7 +2524,7 @@ drop:
 static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *segs, *curr;
-	struct myri10ge_priv *mgp = dev->priv;
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	int status;
 
 	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO6);
@@ -2473,14 +2564,13 @@ static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
 
 static void myri10ge_set_multicast_list(struct net_device *dev)
 {
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
-	struct myri10ge_priv *mgp;
 	struct dev_mc_list *mc_list;
 	__be32 data[2] = { 0, 0 };
 	int err;
 	DECLARE_MAC_BUF(mac);
 
-	mgp = netdev_priv(dev);
 	/* can be called from atomic contexts,
 	 * pass 1 to force atomicity in myri10ge_send_cmd() */
 	myri10ge_change_promisc(mgp, dev->flags & IFF_PROMISC, 1);
@@ -2616,13 +2706,14 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 	ext_type = (val & PCI_EXP_FLAGS_TYPE) >> 4;
 	if (ext_type != PCI_EXP_TYPE_ROOT_PORT) {
 		if (myri10ge_ecrc_enable > 1) {
-			struct pci_dev *old_bridge = bridge;
+			struct pci_dev *prev_bridge, *old_bridge = bridge;
 
 			/* Walk the hierarchy up to the root port
 			 * where ECRC has to be enabled */
 			do {
+				prev_bridge = bridge;
 				bridge = bridge->bus->self;
-				if (!bridge) {
+				if (!bridge || prev_bridge == bridge) {
 					dev_err(dev,
 						"Failed to find root port"
 						" to force ECRC\n");
@@ -2681,9 +2772,9 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
  * already been enabled, then it must use a firmware image which works
  * around unaligned completion packets (myri10ge_ethp_z8e.dat), and it
  * should also ensure that it never gives the device a Read-DMA which is
- * larger than 2KB by setting the tx.boundary to 2KB.  If ECRC is
+ * larger than 2KB by setting the tx_boundary to 2KB.  If ECRC is
  * enabled, then the driver should use the aligned (myri10ge_eth_z8e.dat)
- * firmware image, and set tx.boundary to 4KB.
+ * firmware image, and set tx_boundary to 4KB.
  */
 
 static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
@@ -2692,7 +2783,7 @@ static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 	struct device *dev = &pdev->dev;
 	int status;
 
-	mgp->tx.boundary = 4096;
+	mgp->tx_boundary = 4096;
 	/*
 	 * Verify the max read request size was set to 4KB
 	 * before trying the test with 4KB.
@@ -2704,7 +2795,7 @@ static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 	}
 	if (status != 4096) {
 		dev_warn(dev, "Max Read Request size != 4096 (%d)\n", status);
-		mgp->tx.boundary = 2048;
+		mgp->tx_boundary = 2048;
 	}
 	/*
 	 * load the optimized firmware (which assumes aligned PCIe
@@ -2737,7 +2828,7 @@ static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 			 "Please install up to date fw\n");
 abort:
 	/* fall back to using the unaligned firmware */
-	mgp->tx.boundary = 2048;
+	mgp->tx_boundary = 2048;
 	mgp->fw_name = myri10ge_fw_unaligned;
 
 }
@@ -2758,7 +2849,7 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 		if (link_width < 8) {
 			dev_info(&mgp->pdev->dev, "PCIE x%d Link\n",
 				 link_width);
-			mgp->tx.boundary = 4096;
+			mgp->tx_boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
 		} else {
 			myri10ge_firmware_probe(mgp);
@@ -2767,12 +2858,12 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 		if (myri10ge_force_firmware == 1) {
 			dev_info(&mgp->pdev->dev,
 				 "Assuming aligned completions (forced)\n");
-			mgp->tx.boundary = 4096;
+			mgp->tx_boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
 		} else {
 			dev_info(&mgp->pdev->dev,
 				 "Assuming unaligned completions (forced)\n");
-			mgp->tx.boundary = 2048;
+			mgp->tx_boundary = 2048;
 			mgp->fw_name = myri10ge_fw_unaligned;
 		}
 	}
@@ -2889,6 +2980,7 @@ static void myri10ge_watchdog(struct work_struct *work)
 {
 	struct myri10ge_priv *mgp =
 	    container_of(work, struct myri10ge_priv, watchdog_work);
+	struct myri10ge_tx_buf *tx;
 	u32 reboot;
 	int status;
 	u16 cmd, vendor;
@@ -2938,15 +3030,16 @@ static void myri10ge_watchdog(struct work_struct *work)
 
 		printk(KERN_ERR "myri10ge: %s: device timeout, resetting\n",
 		       mgp->dev->name);
+		tx = &mgp->ss.tx;
 		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, mgp->tx.req, mgp->tx.done,
-		       mgp->tx.pkt_start, mgp->tx.pkt_done,
-		       (int)ntohl(mgp->fw_stats->send_done_count));
+		       mgp->dev->name, tx->req, tx->done,
+		       tx->pkt_start, tx->pkt_done,
+		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
 		msleep(2000);
 		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, mgp->tx.req, mgp->tx.done,
-		       mgp->tx.pkt_start, mgp->tx.pkt_done,
-		       (int)ntohl(mgp->fw_stats->send_done_count));
+		       mgp->dev->name, tx->req, tx->done,
+		       tx->pkt_start, tx->pkt_done,
+		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
 	}
 	rtnl_lock();
 	myri10ge_close(mgp->dev);
@@ -2969,28 +3062,31 @@ static void myri10ge_watchdog(struct work_struct *work)
 static void myri10ge_watchdog_timer(unsigned long arg)
 {
 	struct myri10ge_priv *mgp;
+	struct myri10ge_slice_state *ss;
 	u32 rx_pause_cnt;
 
 	mgp = (struct myri10ge_priv *)arg;
 
-	if (mgp->rx_small.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+	rx_pause_cnt = ntohl(mgp->ss.fw_stats->dropped_pause);
+
+	ss = &mgp->ss;
+	if (ss->rx_small.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
 					mgp->small_bytes + MXGEFW_PAD, 1);
-		if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt >=
+		if (ss->rx_small.fill_cnt - ss->rx_small.cnt >=
 		    myri10ge_fill_thresh)
-			mgp->rx_small.watchdog_needed = 0;
+			ss->rx_small.watchdog_needed = 0;
 	}
-	if (mgp->rx_big.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 1);
-		if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt >=
+	if (ss->rx_big.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 1);
+		if (ss->rx_big.fill_cnt - ss->rx_big.cnt >=
 		    myri10ge_fill_thresh)
-			mgp->rx_big.watchdog_needed = 0;
+			ss->rx_big.watchdog_needed = 0;
 	}
-	rx_pause_cnt = ntohl(mgp->fw_stats->dropped_pause);
 
-	if (mgp->tx.req != mgp->tx.done &&
-	    mgp->tx.done == mgp->watchdog_tx_done &&
-	    mgp->watchdog_tx_req != mgp->watchdog_tx_done) {
+	if (ss->tx.req != ss->tx.done &&
+	    ss->tx.done == ss->watchdog_tx_done &&
+	    ss->watchdog_tx_req != ss->watchdog_tx_done) {
 		/* nic seems like it might be stuck.. */
 		if (rx_pause_cnt != mgp->watchdog_pause) {
 			if (net_ratelimit())
@@ -3005,8 +3101,8 @@ static void myri10ge_watchdog_timer(unsigned long arg)
 	/* rearm timer */
 	mod_timer(&mgp->watchdog_timer,
 		  jiffies + myri10ge_watchdog_timeout * HZ);
-	mgp->watchdog_tx_done = mgp->tx.done;
-	mgp->watchdog_tx_req = mgp->tx.req;
+	ss->watchdog_tx_done = ss->tx.done;
+	ss->watchdog_tx_req = ss->tx.req;
 	mgp->watchdog_pause = rx_pause_cnt;
 }
 
@@ -3030,7 +3126,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	mgp = netdev_priv(netdev);
 	mgp->dev = netdev;
-	netif_napi_add(netdev, &mgp->napi, myri10ge_poll, myri10ge_napi_weight);
+	netif_napi_add(netdev, &mgp->ss.napi, myri10ge_poll, myri10ge_napi_weight);
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
@@ -3076,9 +3172,9 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (mgp->cmd == NULL)
 		goto abort_with_netdev;
 
-	mgp->fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
-					   &mgp->fw_stats_bus, GFP_KERNEL);
-	if (mgp->fw_stats == NULL)
+	mgp->ss.fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
+					   &mgp->ss.fw_stats_bus, GFP_KERNEL);
+	if (mgp->ss.fw_stats == NULL)
 		goto abort_with_cmd;
 
 	mgp->board_span = pci_resource_len(pdev, 0);
@@ -3118,12 +3214,12 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->dev_addr[i] = mgp->mac_addr[i];
 
 	/* allocate rx done ring */
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	mgp->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
-						&mgp->rx_done.bus, GFP_KERNEL);
-	if (mgp->rx_done.entry == NULL)
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	mgp->ss.rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
+						&mgp->ss.rx_done.bus, GFP_KERNEL);
+	if (mgp->ss.rx_done.entry == NULL)
 		goto abort_with_ioremap;
-	memset(mgp->rx_done.entry, 0, bytes);
+	memset(mgp->ss.rx_done.entry, 0, bytes);
 
 	myri10ge_select_firmware(mgp);
 
@@ -3183,7 +3279,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
 		 (mgp->msi_enabled ? "MSI" : "xPIC"),
-		 netdev->irq, mgp->tx.boundary, mgp->fw_name,
+		 netdev->irq, mgp->tx_boundary, mgp->fw_name,
 		 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	return 0;
@@ -3195,9 +3291,9 @@ abort_with_firmware:
 	myri10ge_dummy_rdma(mgp, 0);
 
 abort_with_rx_done:
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->rx_done.entry, mgp->rx_done.bus);
+			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
 
 abort_with_ioremap:
 	iounmap(mgp->sram);
@@ -3207,8 +3303,8 @@ abort_with_wc:
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
-			  mgp->fw_stats, mgp->fw_stats_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
+			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
 
 abort_with_cmd:
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
@@ -3246,9 +3342,9 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	/* avoid a memory leak */
 	pci_restore_state(pdev);
 
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->rx_done.entry, mgp->rx_done.bus);
+			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
 
 	iounmap(mgp->sram);
 
@@ -3256,8 +3352,8 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
-			  mgp->fw_stats, mgp->fw_stats_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
+			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
 
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
diff --git a/drivers/net/myri10ge/myri10ge_mcp.h b/drivers/net/myri10ge/myri10ge_mcp.h
index 58e5717..fdbeeee 100644
--- a/drivers/net/myri10ge/myri10ge_mcp.h
+++ b/drivers/net/myri10ge/myri10ge_mcp.h
@@ -10,7 +10,7 @@ struct mcp_dma_addr {
 	__be32 low;
 };
 
-/* 4 Bytes.  8 Bytes for NDIS drivers. */
+/* 4 Bytes */
 struct mcp_slot {
 	__sum16 checksum;
 	__be16 length;
@@ -144,6 +144,7 @@ enum myri10ge_mcp_cmd_type {
 	 * a power of 2 number of entries.  */
 
 	MXGEFW_CMD_SET_INTRQ_SIZE,	/* in bytes */
+#define MXGEFW_CMD_SET_INTRQ_SIZE_FLAG_NO_STRICT_SIZE_CHECK  (1 << 31)
 
 	/* command to bring ethernet interface up.  Above parameters
 	 * (plus mtu & mac address) must have been exchanged prior
@@ -221,10 +222,14 @@ enum myri10ge_mcp_cmd_type {
 	MXGEFW_CMD_GET_MAX_RSS_QUEUES,
 	MXGEFW_CMD_ENABLE_RSS_QUEUES,
 	/* data0 = number of slices n (0, 1, ..., n-1) to enable
-	 * data1 = interrupt mode. 0=share one INTx/MSI, 1=use one MSI-X per queue.
+	 * data1 = interrupt mode.
+	 * 0=share one INTx/MSI, 1=use one MSI-X per queue.
 	 * If all queues share one interrupt, the driver must have set
 	 * RSS_SHARED_INTERRUPT_DMA before enabling queues.
 	 */
+#define MXGEFW_SLICE_INTR_MODE_SHARED 0
+#define MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE 1
+
 	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET,
 	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA,
 	/* data0, data1 = bus address lsw, msw */
@@ -241,10 +246,14 @@ enum myri10ge_mcp_cmd_type {
 	 * 0: disable rss.  nic does not distribute receive packets.
 	 * 1: enable rss.  nic distributes receive packets among queues.
 	 * data1 = hash type
-	 * 1: IPV4
-	 * 2: TCP_IPV4
-	 * 3: IPV4 | TCP_IPV4
+	 * 1: IPV4            (required by RSS)
+	 * 2: TCP_IPV4        (required by RSS)
+	 * 3: IPV4 | TCP_IPV4 (required by RSS)
+	 * 4: source port
 	 */
+#define MXGEFW_RSS_HASH_TYPE_IPV4      0x1
+#define MXGEFW_RSS_HASH_TYPE_TCP_IPV4  0x2
+#define MXGEFW_RSS_HASH_TYPE_SRC_PORT  0x4
 
 	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
 	/* Return data = the max. size of the entire headers of a IPv6 TSO packet.
@@ -260,6 +269,8 @@ enum myri10ge_mcp_cmd_type {
 	 * 0: Linux/FreeBSD style (NIC default)
 	 * 1: NDIS/NetBSD style
 	 */
+#define MXGEFW_TSO_MODE_LINUX  0
+#define MXGEFW_TSO_MODE_NDIS   1
 
 	MXGEFW_CMD_MDIO_READ,
 	/* data0 = dev_addr (PMA/PMD or PCS ...), data1 = register/addr */
@@ -286,6 +297,38 @@ enum myri10ge_mcp_cmd_type {
 	/* Return data = NIC memory offset of mcp_vpump_public_global */
 	MXGEFW_CMD_RESET_VPUMP,
 	/* Resets the VPUMP state */
+
+	MXGEFW_CMD_SET_RSS_MCP_SLOT_TYPE,
+	/* data0 = mcp_slot type to use.
+	 * 0 = the default 4B mcp_slot
+	 * 1 = 8B mcp_slot_8
+	 */
+#define MXGEFW_RSS_MCP_SLOT_TYPE_MIN        0
+#define MXGEFW_RSS_MCP_SLOT_TYPE_WITH_HASH  1
+
+	MXGEFW_CMD_SET_THROTTLE_FACTOR,
+	/* set the throttle factor for ethp_z8e
+	 * data0 = throttle_factor
+	 * throttle_factor = 256 * pcie-raw-speed / tx_speed
+	 * tx_speed = 256 * pcie-raw-speed / throttle_factor
+	 *
+	 * For PCI-E x8: pcie-raw-speed == 16Gb/s
+	 * For PCI-E x4: pcie-raw-speed == 8Gb/s
+	 *
+	 * ex1: throttle_factor == 0x1a0 (416), tx_speed == 1.23GB/s == 9.846 Gb/s
+	 * ex2: throttle_factor == 0x200 (512), tx_speed == 1.0GB/s == 8 Gb/s
+	 *
+	 * with tx_boundary == 2048, max-throttle-factor == 8191 => min-speed == 500Mb/s
+	 * with tx_boundary == 4096, max-throttle-factor == 4095 => min-speed == 1Gb/s
+	 */
+
+	MXGEFW_CMD_VPUMP_UP,
+	/* Allocates VPump Connection, Send Request and Zero copy buffer address tables */
+	MXGEFW_CMD_GET_VPUMP_CLK,
+	/* Get the lanai clock */
+
+	MXGEFW_CMD_GET_DCA_OFFSET,
+	/* offset of dca control for WDMAs */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -302,7 +345,8 @@ enum myri10ge_mcp_cmd_status {
 	MXGEFW_CMD_ERROR_UNALIGNED,
 	MXGEFW_CMD_ERROR_NO_MDIO,
 	MXGEFW_CMD_ERROR_XFP_FAILURE,
-	MXGEFW_CMD_ERROR_XFP_ABSENT
+	MXGEFW_CMD_ERROR_XFP_ABSENT,
+	MXGEFW_CMD_ERROR_BAD_PCIE_LINK
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40
diff --git a/drivers/net/myri10ge/myri10ge_mcp_gen_header.h b/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
index 16a810d..07d65c2 100644
--- a/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
+++ b/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
@@ -1,30 +1,6 @@
 #ifndef __MYRI10GE_MCP_GEN_HEADER_H__
 #define __MYRI10GE_MCP_GEN_HEADER_H__
 
-/* this file define a standard header used as a first entry point to
- * exchange information between firmware/driver and driver.  The
- * header structure can be anywhere in the mcp. It will usually be in
- * the .data section, because some fields needs to be initialized at
- * compile time.
- * The 32bit word at offset MX_HEADER_PTR_OFFSET in the mcp must
- * contains the location of the header.
- *
- * Typically a MCP will start with the following:
- * .text
- * .space 52    ! to help catch MEMORY_INT errors
- * bt start     ! jump to real code
- * nop
- * .long _gen_mcp_header
- *
- * The source will have a definition like:
- *
- * mcp_gen_header_t gen_mcp_header = {
- * .header_length = sizeof(mcp_gen_header_t),
- * .mcp_type = MCP_TYPE_XXX,
- * .version = "something $Id: mcp_gen_header.h,v 1.2 2006/05/13 10:04:35 bgoglin Exp $",
- * .mcp_globals = (unsigned)&Globals
- * };
- */
 
 #define MCP_HEADER_PTR_OFFSET  0x3c
 
@@ -32,13 +8,14 @@
 #define MCP_TYPE_PCIE 0x70636965	/* "PCIE" pcie-only MCP */
 #define MCP_TYPE_ETH 0x45544820	/* "ETH " */
 #define MCP_TYPE_MCP0 0x4d435030	/* "MCP0" */
+#define MCP_TYPE_DFLT 0x20202020	/* "    " */
 
 struct mcp_gen_header {
 	/* the first 4 fields are filled at compile time */
 	unsigned header_length;
 	__be32 mcp_type;
 	char version[128];
-	unsigned mcp_globals;	/* pointer to mcp-type specific structure */
+	unsigned mcp_private;	/* pointer to mcp-type specific structure */
 
 	/* filled by the MCP at run-time */
 	unsigned sram_size;
@@ -53,6 +30,18 @@ struct mcp_gen_header {
 	 *
 	 * Never remove any field.  Keep everything naturally align.
 	 */
+
+	/* Specifies if the running mcp is mcp0, 1, or 2. */
+	unsigned char mcp_index;
+	unsigned char disable_rabbit;
+	unsigned char unaligned_tlp;
+	unsigned char pad1;
+	unsigned counters_addr;
+	unsigned copy_block_info;	/* for small mcps loaded with "lload -d" */
+	unsigned short handoff_id_major;	/* must be equal */
+	unsigned short handoff_id_caps;	/* bitfield: new mcp must have superset */
+	unsigned msix_table_addr;	/* start address of msix table in firmware */
+	/* 8 */
 };
 
 #endif				/* __MYRI10GE_MCP_GEN_HEADER_H__ */
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 0f02344..1d2daee 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
-			   i2c-direct.o ethtool.o xfp_phy.o mdio_10g.o \
-			   tenxpress.o boards.o sfe4001.o
+			   i2c-direct.o selftest.o ethtool.o xfp_phy.o \
+			   mdio_10g.o tenxpress.o boards.o sfe4001.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index f56341d..695764d 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -22,5 +22,7 @@ enum efx_board_type {
 extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
 extern int sfe4001_poweron(struct efx_nic *efx);
 extern void sfe4001_poweroff(struct efx_nic *efx);
+/* Are we putting the PHY into flash config mode */
+extern unsigned int sfe4001_phy_flash_cfg;
 
 #endif
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 59edcf7..418f2e5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1873,6 +1873,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		tx_queue->queue = i;
 		tx_queue->buffer = NULL;
 		tx_queue->channel = &efx->channel[0]; /* for safety */
+		tx_queue->tso_headers_free = NULL;
 	}
 	for (i = 0; i < EFX_MAX_RX_QUEUES; i++) {
 		rx_queue = &efx->rx_queue[i];
@@ -2071,7 +2072,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev = alloc_etherdev(sizeof(*efx));
 	if (!net_dev)
 		return -ENOMEM;
-	net_dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HIGHDMA;
+	net_dev->features |= (NETIF_F_IP_CSUM | NETIF_F_SG |
+			      NETIF_F_HIGHDMA | NETIF_F_TSO);
 	if (lro)
 		net_dev->features |= NETIF_F_LRO;
 	efx = net_dev->priv;
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 43663a4..c53290d 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -10,6 +10,55 @@
 #ifndef EFX_ENUM_H
 #define EFX_ENUM_H
 
+/**
+ * enum efx_loopback_mode - loopback modes
+ * @LOOPBACK_NONE: no loopback
+ * @LOOPBACK_XGMII: loopback within MAC at XGMII level
+ * @LOOPBACK_XGXS: loopback within MAC at XGXS level
+ * @LOOPBACK_XAUI: loopback within MAC at XAUI level
+ * @LOOPBACK_PHYXS: loopback within PHY at PHYXS level
+ * @LOOPBACK_PCS: loopback within PHY at PCS level
+ * @LOOPBACK_PMAPMD: loopback within PHY at PMAPMD level
+ * @LOOPBACK_NETWORK: reflecting loopback (even further than furthest!)
+ */
+/* Please keep in order and up-to-date w.r.t the following two #defines */
+enum efx_loopback_mode {
+	LOOPBACK_NONE = 0,
+	LOOPBACK_MAC = 1,
+	LOOPBACK_XGMII = 2,
+	LOOPBACK_XGXS = 3,
+	LOOPBACK_XAUI = 4,
+	LOOPBACK_PHY = 5,
+	LOOPBACK_PHYXS = 6,
+	LOOPBACK_PCS = 7,
+	LOOPBACK_PMAPMD = 8,
+	LOOPBACK_NETWORK = 9,
+	LOOPBACK_MAX
+};
+
+#define LOOPBACK_TEST_MAX LOOPBACK_PMAPMD
+
+extern const char *efx_loopback_mode_names[];
+#define LOOPBACK_MODE_NAME(mode)			\
+	STRING_TABLE_LOOKUP(mode, efx_loopback_mode)
+#define LOOPBACK_MODE(efx)				\
+	LOOPBACK_MODE_NAME(efx->loopback_mode)
+
+/* These loopbacks occur within the controller */
+#define LOOPBACKS_10G_INTERNAL ((1 << LOOPBACK_XGMII)| \
+				(1 << LOOPBACK_XGXS) | \
+				(1 << LOOPBACK_XAUI))
+
+#define LOOPBACK_MASK(_efx)			\
+	(1 << (_efx)->loopback_mode)
+
+#define LOOPBACK_INTERNAL(_efx)						\
+	((LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)) ? 1 : 0)
+
+#define LOOPBACK_OUT_OF(_from, _to, _mask)		\
+	(((LOOPBACK_MASK(_from) & (_mask)) &&		\
+	  ((LOOPBACK_MASK(_to) & (_mask)) == 0)) ? 1 : 0)
+
 /*****************************************************************************/
 
 /**
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index ad541ba..e2c75d1 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -12,12 +12,26 @@
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include "net_driver.h"
+#include "selftest.h"
 #include "efx.h"
 #include "ethtool.h"
 #include "falcon.h"
 #include "gmii.h"
 #include "mac.h"
 
+const char *efx_loopback_mode_names[] = {
+	[LOOPBACK_NONE]		= "NONE",
+	[LOOPBACK_MAC]		= "MAC",
+	[LOOPBACK_XGMII]	= "XGMII",
+	[LOOPBACK_XGXS]		= "XGXS",
+	[LOOPBACK_XAUI] 	= "XAUI",
+	[LOOPBACK_PHY]		= "PHY",
+	[LOOPBACK_PHYXS]	= "PHY(XS)",
+	[LOOPBACK_PCS]	 	= "PHY(PCS)",
+	[LOOPBACK_PMAPMD]	= "PHY(PMAPMD)",
+	[LOOPBACK_NETWORK]	= "NETWORK",
+};
+
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable);
 
 struct ethtool_string {
@@ -217,23 +231,179 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
 }
 
+/**
+ * efx_fill_test - fill in an individual self-test entry
+ * @test_index:		Index of the test
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ * @test:		Pointer to test result (used only if data != %NULL)
+ * @unit_format:	Unit name format (e.g. "channel\%d")
+ * @unit_id:		Unit id (e.g. 0 for "channel0")
+ * @test_format:	Test name format (e.g. "loopback.\%s.tx.sent")
+ * @test_id:		Test id (e.g. "PHY" for "loopback.PHY.tx_sent")
+ *
+ * Fill in an individual self-test entry.
+ */
+static void efx_fill_test(unsigned int test_index,
+			  struct ethtool_string *strings, u64 *data,
+			  int *test, const char *unit_format, int unit_id,
+			  const char *test_format, const char *test_id)
+{
+	struct ethtool_string unit_str, test_str;
+
+	/* Fill data value, if applicable */
+	if (data)
+		data[test_index] = *test;
+
+	/* Fill string, if applicable */
+	if (strings) {
+		snprintf(unit_str.name, sizeof(unit_str.name),
+			 unit_format, unit_id);
+		snprintf(test_str.name, sizeof(test_str.name),
+			 test_format, test_id);
+		snprintf(strings[test_index].name,
+			 sizeof(strings[test_index].name),
+			 "%-9s%-17s", unit_str.name, test_str.name);
+	}
+}
+
+#define EFX_PORT_NAME "port%d", 0
+#define EFX_CHANNEL_NAME(_channel) "channel%d", _channel->channel
+#define EFX_TX_QUEUE_NAME(_tx_queue) "txq%d", _tx_queue->queue
+#define EFX_RX_QUEUE_NAME(_rx_queue) "rxq%d", _rx_queue->queue
+#define EFX_LOOPBACK_NAME(_mode, _counter)			\
+	"loopback.%s." _counter, LOOPBACK_MODE_NAME(mode)
+
+/**
+ * efx_fill_loopback_test - fill in a block of loopback self-test entries
+ * @efx:		Efx NIC
+ * @lb_tests:		Efx loopback self-test results structure
+ * @mode:		Loopback test mode
+ * @test_index:		Starting index of the test
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ */
+static int efx_fill_loopback_test(struct efx_nic *efx,
+				  struct efx_loopback_self_tests *lb_tests,
+				  enum efx_loopback_mode mode,
+				  unsigned int test_index,
+				  struct ethtool_string *strings, u64 *data)
+{
+	struct efx_tx_queue *tx_queue;
+
+	efx_for_each_tx_queue(tx_queue, efx) {
+		efx_fill_test(test_index++, strings, data,
+			      &lb_tests->tx_sent[tx_queue->queue],
+			      EFX_TX_QUEUE_NAME(tx_queue),
+			      EFX_LOOPBACK_NAME(mode, "tx_sent"));
+		efx_fill_test(test_index++, strings, data,
+			      &lb_tests->tx_done[tx_queue->queue],
+			      EFX_TX_QUEUE_NAME(tx_queue),
+			      EFX_LOOPBACK_NAME(mode, "tx_done"));
+	}
+	efx_fill_test(test_index++, strings, data,
+		      &lb_tests->rx_good,
+		      EFX_PORT_NAME,
+		      EFX_LOOPBACK_NAME(mode, "rx_good"));
+	efx_fill_test(test_index++, strings, data,
+		      &lb_tests->rx_bad,
+		      EFX_PORT_NAME,
+		      EFX_LOOPBACK_NAME(mode, "rx_bad"));
+
+	return test_index;
+}
+
+/**
+ * efx_ethtool_fill_self_tests - get self-test details
+ * @efx:		Efx NIC
+ * @tests:		Efx self-test results structure, or %NULL
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ */
+static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
+				       struct efx_self_tests *tests,
+				       struct ethtool_string *strings,
+				       u64 *data)
+{
+	struct efx_channel *channel;
+	unsigned int n = 0;
+	enum efx_loopback_mode mode;
+
+	/* Interrupt */
+	efx_fill_test(n++, strings, data, &tests->interrupt,
+		      "core", 0, "interrupt", NULL);
+
+	/* Event queues */
+	efx_for_each_channel(channel, efx) {
+		efx_fill_test(n++, strings, data,
+			      &tests->eventq_dma[channel->channel],
+			      EFX_CHANNEL_NAME(channel),
+			      "eventq.dma", NULL);
+		efx_fill_test(n++, strings, data,
+			      &tests->eventq_int[channel->channel],
+			      EFX_CHANNEL_NAME(channel),
+			      "eventq.int", NULL);
+		efx_fill_test(n++, strings, data,
+			      &tests->eventq_poll[channel->channel],
+			      EFX_CHANNEL_NAME(channel),
+			      "eventq.poll", NULL);
+	}
+
+	/* PHY presence */
+	efx_fill_test(n++, strings, data, &tests->phy_ok,
+		      EFX_PORT_NAME, "phy_ok", NULL);
+
+	/* Loopback tests */
+	efx_fill_test(n++, strings, data, &tests->loopback_speed,
+		      EFX_PORT_NAME, "loopback.speed", NULL);
+	efx_fill_test(n++, strings, data, &tests->loopback_full_duplex,
+		      EFX_PORT_NAME, "loopback.full_duplex", NULL);
+	for (mode = LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+		if (!(efx->loopback_modes & (1 << mode)))
+			continue;
+		n = efx_fill_loopback_test(efx,
+					   &tests->loopback[mode], mode, n,
+					   strings, data);
+	}
+
+	return n;
+}
+
 static int efx_ethtool_get_stats_count(struct net_device *net_dev)
 {
 	return EFX_ETHTOOL_NUM_STATS;
 }
 
+static int efx_ethtool_self_test_count(struct net_device *net_dev)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
+}
+
 static void efx_ethtool_get_strings(struct net_device *net_dev,
 				    u32 string_set, u8 *strings)
 {
+	struct efx_nic *efx = net_dev->priv;
 	struct ethtool_string *ethtool_strings =
 		(struct ethtool_string *)strings;
 	int i;
 
-	if (string_set == ETH_SS_STATS)
+	switch (string_set) {
+	case ETH_SS_STATS:
 		for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++)
 			strncpy(ethtool_strings[i].name,
 				efx_ethtool_stats[i].name,
 				sizeof(ethtool_strings[i].name));
+		break;
+	case ETH_SS_TEST:
+		efx_ethtool_fill_self_tests(efx, NULL,
+					    ethtool_strings, NULL);
+		break;
+	default:
+		/* No other string sets */
+		break;
+	}
 }
 
 static void efx_ethtool_get_stats(struct net_device *net_dev,
@@ -272,6 +442,22 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	}
 }
 
+static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
+{
+	int rc;
+
+	/* Our TSO requires TX checksumming, so force TX checksumming
+	 * on when TSO is enabled.
+	 */
+	if (enable) {
+		rc = efx_ethtool_set_tx_csum(net_dev, 1);
+		if (rc)
+			return rc;
+	}
+
+	return ethtool_op_set_tso(net_dev, enable);
+}
+
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
 {
 	struct efx_nic *efx = net_dev->priv;
@@ -283,6 +469,15 @@ static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
 
 	efx_flush_queues(efx);
 
+	/* Our TSO requires TX checksumming, so disable TSO when
+	 * checksumming is disabled
+	 */
+	if (!enable) {
+		rc = efx_ethtool_set_tso(net_dev, 0);
+		if (rc)
+			return rc;
+	}
+
 	return 0;
 }
 
@@ -305,6 +500,64 @@ static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
 	return efx->rx_checksum_enabled;
 }
 
+static void efx_ethtool_self_test(struct net_device *net_dev,
+				  struct ethtool_test *test, u64 *data)
+{
+	struct efx_nic *efx = net_dev->priv;
+	struct efx_self_tests efx_tests;
+	int offline, already_up;
+	int rc;
+
+	ASSERT_RTNL();
+	if (efx->state != STATE_RUNNING) {
+		rc = -EIO;
+		goto fail1;
+	}
+
+	/* We need rx buffers and interrupts. */
+	already_up = (efx->net_dev->flags & IFF_UP);
+	if (!already_up) {
+		rc = dev_open(efx->net_dev);
+		if (rc) {
+			EFX_ERR(efx, "failed opening device.\n");
+			goto fail2;
+		}
+	}
+
+	memset(&efx_tests, 0, sizeof(efx_tests));
+	offline = (test->flags & ETH_TEST_FL_OFFLINE);
+
+	/* Perform online self tests first */
+	rc = efx_online_test(efx, &efx_tests);
+	if (rc)
+		goto out;
+
+	/* Perform offline tests only if online tests passed */
+	if (offline) {
+		/* Stop the kernel from sending packets during the test. */
+		efx_stop_queue(efx);
+		rc = efx_flush_queues(efx);
+		if (!rc)
+			rc = efx_offline_test(efx, &efx_tests,
+					      efx->loopback_modes);
+		efx_wake_queue(efx);
+	}
+
+ out:
+	if (!already_up)
+		dev_close(efx->net_dev);
+
+	EFX_LOG(efx, "%s all %sline self-tests\n",
+		rc == 0 ? "passed" : "failed", offline ? "off" : "on");
+
+ fail2:
+ fail1:
+	/* Fill ethtool results structures */
+	efx_ethtool_fill_self_tests(efx, &efx_tests, NULL, data);
+	if (rc)
+		test->flags |= ETH_TEST_FL_FAILED;
+}
+
 /* Restart autonegotiation */
 static int efx_ethtool_nway_reset(struct net_device *net_dev)
 {
@@ -451,8 +704,12 @@ struct ethtool_ops efx_ethtool_ops = {
 	.set_tx_csum		= efx_ethtool_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= efx_ethtool_set_tso,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
+	.self_test_count	= efx_ethtool_self_test_count,
+	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
 	.phys_id		= efx_ethtool_phys_id,
 	.get_stats_count	= efx_ethtool_get_stats_count,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 46db549..b57cc68 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1129,6 +1129,7 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 	case RX_RECOVERY_EV_DECODE:
 		EFX_ERR(efx, "channel %d seen DRIVER RX_RESET event. "
 			"Resetting.\n", channel->channel);
+		atomic_inc(&efx->rx_reset);
 		efx_schedule_reset(efx,
 				   EFX_WORKAROUND_6555(efx) ?
 				   RESET_TYPE_RX_RECOVERY :
@@ -1731,7 +1732,8 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	efx_oword_t temp;
 	int count;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if ((FALCON_REV(efx) < FALCON_REV_B0) ||
+	    (efx->loopback_mode != LOOPBACK_NONE))
 		return;
 
 	falcon_read(efx, &temp, MAC0_CTRL_REG_KER);
@@ -2091,6 +2093,8 @@ static int falcon_probe_phy(struct efx_nic *efx)
 			efx->phy_type);
 		return -1;
 	}
+
+	efx->loopback_modes = LOOPBACKS_10G_INTERNAL | efx->phy_op->loopbacks;
 	return 0;
 }
 
@@ -2468,14 +2472,12 @@ int falcon_probe_nic(struct efx_nic *efx)
  fail5:
 	falcon_free_buffer(efx, &efx->irq_status);
  fail4:
-	/* fall-thru */
  fail3:
 	if (nic_data->pci_dev2) {
 		pci_dev_put(nic_data->pci_dev2);
 		nic_data->pci_dev2 = NULL;
 	}
  fail2:
-	/* fall-thru */
  fail1:
 	kfree(efx->nic_data);
 	return rc;
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 0485a63..06e2d68 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -636,6 +636,14 @@
 #define XX_HIDRVA_WIDTH 1
 #define XX_LODRVA_LBN 8
 #define XX_LODRVA_WIDTH 1
+#define XX_LPBKD_LBN 3
+#define XX_LPBKD_WIDTH 1
+#define XX_LPBKC_LBN 2
+#define XX_LPBKC_WIDTH 1
+#define XX_LPBKB_LBN 1
+#define XX_LPBKB_WIDTH 1
+#define XX_LPBKA_LBN 0
+#define XX_LPBKA_WIDTH 1
 
 #define XX_TXDRV_CTL_REG_MAC 0x12
 #define XX_DEQD_LBN 28
@@ -656,8 +664,14 @@
 #define XX_DTXA_WIDTH 4
 
 /* XAUI XGXS core status register */
-#define XX_FORCE_SIG_DECODE_FORCED 0xff
 #define XX_CORE_STAT_REG_MAC 0x16
+#define XX_FORCE_SIG_LBN 24
+#define XX_FORCE_SIG_WIDTH 8
+#define XX_FORCE_SIG_DECODE_FORCED 0xff
+#define XX_XGXS_LB_EN_LBN 23
+#define XX_XGXS_LB_EN_WIDTH 1
+#define XX_XGMII_LB_EN_LBN 22
+#define XX_XGMII_LB_EN_WIDTH 1
 #define XX_ALIGN_DONE_LBN 20
 #define XX_ALIGN_DONE_WIDTH 1
 #define XX_SYNC_STAT_LBN 16
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index aa7521b..a74b793 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -32,7 +32,7 @@
 	(FALCON_XMAC_REGBANK + ((mac_reg) * FALCON_XMAC_REG_SIZE))
 
 void falcon_xmac_writel(struct efx_nic *efx,
-			efx_dword_t *value, unsigned int mac_reg)
+			 efx_dword_t *value, unsigned int mac_reg)
 {
 	efx_oword_t temp;
 
@@ -69,6 +69,10 @@ static int falcon_reset_xmac(struct efx_nic *efx)
 		udelay(10);
 	}
 
+	/* This often fails when DSP is disabled, ignore it */
+	if (sfe4001_phy_flash_cfg != 0)
+		return 0;
+
 	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
 	return -ETIMEDOUT;
 }
@@ -223,7 +227,7 @@ static int falcon_xgmii_status(struct efx_nic *efx)
 	/* The ISR latches, so clear it and re-read */
 	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
 	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
-	
+
 	if (EFX_DWORD_FIELD(reg, XM_LCLFLT) ||
 	    EFX_DWORD_FIELD(reg, XM_RMTFLT)) {
 		EFX_INFO(efx, "MGT_INT: "EFX_DWORD_FMT"\n", EFX_DWORD_VAL(reg));
@@ -237,7 +241,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, int enable)
 {
 	efx_dword_t reg;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if ((FALCON_REV(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
 		return;
 
 	/* Flush the ISR */
@@ -284,6 +288,9 @@ int falcon_xaui_link_ok(struct efx_nic *efx)
 	efx_dword_t reg;
 	int align_done, sync_status, link_ok = 0;
 
+	if (LOOPBACK_INTERNAL(efx))
+		return 1;
+
 	/* Read link status */
 	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
 
@@ -374,6 +381,61 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 	falcon_xmac_writel(efx, &reg, XM_ADR_HI_REG_MAC);
 }
 
+static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+	int xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS) ? 1 : 0;
+	int xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI) ? 1 : 0;
+	int xgmii_loopback =
+		(efx->loopback_mode == LOOPBACK_XGMII) ? 1 : 0;
+
+	/* XGXS block is flaky and will need to be reset if moving
+	 * into our out of XGMII, XGXS or XAUI loopbacks. */
+	if (EFX_WORKAROUND_5147(efx)) {
+		int old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
+		int reset_xgxs;
+
+		falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+		old_xgxs_loopback = EFX_DWORD_FIELD(reg, XX_XGXS_LB_EN);
+		old_xgmii_loopback = EFX_DWORD_FIELD(reg, XX_XGMII_LB_EN);
+
+		falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
+		old_xaui_loopback = EFX_DWORD_FIELD(reg, XX_LPBKA);
+
+		/* The PHY driver may have turned XAUI off */
+		reset_xgxs = ((xgxs_loopback != old_xgxs_loopback) ||
+			      (xaui_loopback != old_xaui_loopback) ||
+			      (xgmii_loopback != old_xgmii_loopback));
+		if (reset_xgxs) {
+			falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
+			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+			udelay(1);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 0);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 0);
+			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+			udelay(1);
+		}
+	}
+
+	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+	EFX_SET_DWORD_FIELD(reg, XX_FORCE_SIG,
+			    (xgxs_loopback || xaui_loopback) ?
+			    XX_FORCE_SIG_DECODE_FORCED : 0);
+	EFX_SET_DWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
+	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
+
+	falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
+	falcon_xmac_writel(efx, &reg, XX_SD_CTL_REG_MAC);
+}
+
+
 /* Try and bring the Falcon side of the Falcon-Phy XAUI link fails
  * to come back up. Bash it until it comes back up */
 static int falcon_check_xaui_link_up(struct efx_nic *efx)
@@ -382,7 +444,8 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 	tries = EFX_WORKAROUND_5147(efx) ? 5 : 1;
 	max_tries = tries;
 
-	if (efx->phy_type == PHY_TYPE_NONE)
+	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
+	    (efx->phy_type == PHY_TYPE_NONE))
 		return 0;
 
 	while (tries) {
@@ -408,8 +471,13 @@ void falcon_reconfigure_xmac(struct efx_nic *efx)
 	falcon_mask_status_intr(efx, 0);
 
 	falcon_deconfigure_mac_wrapper(efx);
+
+	efx->tx_disabled = LOOPBACK_INTERNAL(efx);
 	efx->phy_op->reconfigure(efx);
+
+	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
+
 	falcon_reconfigure_mac_wrapper(efx);
 
 	/* Ensure XAUI link is up */
@@ -491,13 +559,15 @@ void falcon_update_stats_xmac(struct efx_nic *efx)
 		(mac_stats->rx_bytes - mac_stats->rx_good_bytes);
 }
 
-#define EFX_XAUI_RETRAIN_MAX 8
-
 int falcon_check_xmac(struct efx_nic *efx)
 {
 	unsigned xaui_link_ok;
 	int rc;
 
+	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
+	    (efx->phy_type == PHY_TYPE_NONE))
+		return 0;
+
 	falcon_mask_status_intr(efx, 0);
 	xaui_link_ok = falcon_xaui_link_ok(efx);
 
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index dc06bb0..c4f540e 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -44,6 +44,9 @@ static int mdio_clause45_check_mmd(struct efx_nic *efx, int mmd,
 	int status;
 	int phy_id = efx->mii.phy_id;
 
+	if (LOOPBACK_INTERNAL(efx))
+		return 0;
+
 	/* Read MMD STATUS2 to check it is responding. */
 	status = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_STAT2);
 	if (((status >> MDIO_MMDREG_STAT2_PRESENT_LBN) &
@@ -164,6 +167,22 @@ int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	int mmd = 0;
 	int good;
 
+	/* If the port is in loopback, then we should only consider a subset
+	 * of mmd's */
+	if (LOOPBACK_INTERNAL(efx))
+		return 1;
+	else if (efx->loopback_mode == LOOPBACK_NETWORK)
+		return 0;
+	else if (efx->loopback_mode == LOOPBACK_PHYXS)
+		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PHYXS |
+			      MDIO_MMDREG_DEVS0_PCS |
+			      MDIO_MMDREG_DEVS0_PMAPMD);
+	else if (efx->loopback_mode == LOOPBACK_PCS)
+		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PCS |
+			      MDIO_MMDREG_DEVS0_PMAPMD);
+	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
+		mmd_mask &= ~MDIO_MMDREG_DEVS0_PMAPMD;
+
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
 			/* Double reads because link state is latched, and a
@@ -182,6 +201,65 @@ int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	return ok;
 }
 
+void mdio_clause45_transmit_disable(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int ctrl1, ctrl2;
+
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					   MDIO_MMDREG_TXDIS);
+	if (efx->tx_disabled)
+		ctrl2 |= (1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
+	else
+		ctrl1 &= ~(1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    MDIO_MMDREG_TXDIS, ctrl2);
+}
+
+void mdio_clause45_phy_reconfigure(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int ctrl1, ctrl2;
+
+	/* Handle (with debouncing) PMA/PMD loopback */
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					   MDIO_MMDREG_CTRL1);
+
+	if (efx->loopback_mode == LOOPBACK_PMAPMD)
+		ctrl2 |= (1 << MDIO_PMAPMD_CTRL1_LBACK_LBN);
+	else
+		ctrl2 &= ~(1 << MDIO_PMAPMD_CTRL1_LBACK_LBN);
+
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    MDIO_MMDREG_CTRL1, ctrl2);
+
+	/* Handle (with debouncing) PCS loopback */
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
+					   MDIO_MMDREG_CTRL1);
+	if (efx->loopback_mode == LOOPBACK_PCS)
+		ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+	else
+		ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PCS,
+				    MDIO_MMDREG_CTRL1, ctrl2);
+
+	/* Handle (with debouncing) PHYXS network loopback */
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+					   MDIO_MMDREG_CTRL1);
+	if (efx->loopback_mode == LOOPBACK_NETWORK)
+		ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+	else
+		ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PHYXS,
+				    MDIO_MMDREG_CTRL1, ctrl2);
+}
+
 /**
  * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 2214b6d..cb99f3f 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -44,11 +44,16 @@
 #define MDIO_MMDREG_DEVS1	(6)
 #define MDIO_MMDREG_CTRL2	(7)
 #define MDIO_MMDREG_STAT2	(8)
+#define MDIO_MMDREG_TXDIS	(9)
 
 /* Bits in MMDREG_CTRL1 */
 /* Reset */
 #define MDIO_MMDREG_CTRL1_RESET_LBN	(15)
 #define MDIO_MMDREG_CTRL1_RESET_WIDTH	(1)
+/* Loopback */
+/* Loopback bit for WIS, PCS, PHYSX and DTEXS */
+#define MDIO_MMDREG_CTRL1_LBACK_LBN	(14)
+#define MDIO_MMDREG_CTRL1_LBACK_WIDTH	(1)
 
 /* Bits in MMDREG_STAT1 */
 #define MDIO_MMDREG_STAT1_FAULT_LBN	(7)
@@ -56,6 +61,9 @@
 /* Link state */
 #define MDIO_MMDREG_STAT1_LINK_LBN	(2)
 #define MDIO_MMDREG_STAT1_LINK_WIDTH	(1)
+/* Low power ability */
+#define MDIO_MMDREG_STAT1_LPABLE_LBN	(1)
+#define MDIO_MMDREG_STAT1_LPABLE_WIDTH	(1)
 
 /* Bits in ID reg */
 #define MDIO_ID_REV(_id32)	(_id32 & 0xf)
@@ -76,6 +84,14 @@
 #define MDIO_MMDREG_STAT2_PRESENT_LBN	(14)
 #define MDIO_MMDREG_STAT2_PRESENT_WIDTH (2)
 
+/* Bits in MMDREG_TXDIS */
+#define MDIO_MMDREG_TXDIS_GLOBAL_LBN    (0)
+#define MDIO_MMDREG_TXDIS_GLOBAL_WIDTH  (1)
+
+/* MMD-specific bits, ordered by MMD, then register */
+#define MDIO_PMAPMD_CTRL1_LBACK_LBN	(0)
+#define MDIO_PMAPMD_CTRL1_LBACK_WIDTH	(1)
+
 /* PMA type (4 bits) */
 #define MDIO_PMAPMD_CTRL2_10G_CX4	(0x0)
 #define MDIO_PMAPMD_CTRL2_10G_EW	(0x1)
@@ -95,7 +111,7 @@
 #define MDIO_PMAPMD_CTRL2_10_BT		(0xf)
 #define MDIO_PMAPMD_CTRL2_TYPE_MASK	(0xf)
 
-/* /\* PHY XGXS lane state *\/ */
+/* PHY XGXS lane state */
 #define MDIO_PHYXS_LANE_STATE		(0x18)
 #define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
 
@@ -217,6 +233,12 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 extern int mdio_clause45_links_ok(struct efx_nic *efx,
 				  unsigned int mmd_mask);
 
+/* Generic transmit disable support though PMAPMD */
+extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
+
+/* Generic part of reconfigure: set/clear loopback bits */
+extern void mdio_clause45_phy_reconfigure(struct efx_nic *efx);
+
 /* Read (some of) the PHY settings over MDIO */
 extern void mdio_clause45_get_settings(struct efx_nic *efx,
 				       struct ethtool_cmd *ecmd);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index c505482..59f261b 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -134,6 +134,8 @@ struct efx_special_buffer {
  *	Set only on the final fragment of a packet; %NULL for all other
  *	fragments.  When this fragment completes, then we can free this
  *	skb.
+ * @tsoh: The associated TSO header structure, or %NULL if this
+ *	buffer is not a TSO header.
  * @dma_addr: DMA address of the fragment.
  * @len: Length of this fragment.
  *	This field is zero when the queue slot is empty.
@@ -144,6 +146,7 @@ struct efx_special_buffer {
  */
 struct efx_tx_buffer {
 	const struct sk_buff *skb;
+	struct efx_tso_header *tsoh;
 	dma_addr_t dma_addr;
 	unsigned short len;
 	unsigned char continuation;
@@ -187,6 +190,13 @@ struct efx_tx_buffer {
  *	variable indicates that the queue is full.  This is to
  *	avoid cache-line ping-pong between the xmit path and the
  *	completion path.
+ * @tso_headers_free: A list of TSO headers allocated for this TX queue
+ *	that are not in use, and so available for new TSO sends. The list
+ *	is protected by the TX queue lock.
+ * @tso_bursts: Number of times TSO xmit invoked by kernel
+ * @tso_long_headers: Number of packets with headers too long for standard
+ *	blocks
+ * @tso_packets: Number of packets via the TSO xmit path
  */
 struct efx_tx_queue {
 	/* Members which don't change on the fast path */
@@ -206,6 +216,10 @@ struct efx_tx_queue {
 	unsigned int insert_count ____cacheline_aligned_in_smp;
 	unsigned int write_count;
 	unsigned int old_read_count;
+	struct efx_tso_header *tso_headers_free;
+	unsigned int tso_bursts;
+	unsigned int tso_long_headers;
+	unsigned int tso_packets;
 };
 
 /**
@@ -434,6 +448,9 @@ struct efx_board {
 	struct efx_blinker blinker;
 };
 
+#define STRING_TABLE_LOOKUP(val, member)	\
+	member ## _names[val]
+
 enum efx_int_mode {
 	/* Be careful if altering to correct macro below */
 	EFX_INT_MODE_MSIX = 0,
@@ -506,6 +523,7 @@ enum efx_fc_type {
  * @check_hw: Check hardware
  * @reset_xaui: Reset XAUI side of PHY for (software sequenced reset)
  * @mmds: MMD presence mask
+ * @loopbacks: Supported loopback modes mask
  */
 struct efx_phy_operations {
 	int (*init) (struct efx_nic *efx);
@@ -515,6 +533,7 @@ struct efx_phy_operations {
 	int (*check_hw) (struct efx_nic *efx);
 	void (*reset_xaui) (struct efx_nic *efx);
 	int mmds;
+	unsigned loopbacks;
 };
 
 /*
@@ -653,7 +672,6 @@ union efx_multicast_hash {
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
- * @phy_powered: PHY power state
  * @tx_disabled: PHY transmitter turned off
  * @link_up: Link status
  * @link_options: Link options (MII/GMII format)
@@ -662,6 +680,9 @@ union efx_multicast_hash {
  * @multicast_hash: Multicast hash table
  * @flow_control: Flow control flags - separate RX/TX so can't use link_options
  * @reconfigure_work: work item for dealing with PHY events
+ * @loopback_mode: Loopback status
+ * @loopback_modes: Supported loopback mode bitmask
+ * @loopback_selftest: Offline self-test private state
  *
  * The @priv field of the corresponding &struct net_device points to
  * this.
@@ -721,6 +742,7 @@ struct efx_nic {
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mii_if_info mii;
+	unsigned tx_disabled;
 
 	int link_up;
 	unsigned int link_options;
@@ -732,6 +754,10 @@ struct efx_nic {
 	struct work_struct reconfigure_work;
 
 	atomic_t rx_reset;
+	enum efx_loopback_mode loopback_mode;
+	unsigned int loopback_modes;
+
+	void *loopback_selftest;
 };
 
 /**
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 551299b..6706223 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -19,6 +19,7 @@
 #include "rx.h"
 #include "efx.h"
 #include "falcon.h"
+#include "selftest.h"
 #include "workarounds.h"
 
 /* Number of RX descriptors pushed at once. */
@@ -683,6 +684,15 @@ void __efx_rx_packet(struct efx_channel *channel,
 	struct sk_buff *skb;
 	int lro = efx->net_dev->features & NETIF_F_LRO;
 
+	/* If we're in loopback test, then pass the packet directly to the
+	 * loopback layer, and free the rx_buf here
+	 */
+	if (unlikely(efx->loopback_selftest)) {
+		efx_loopback_rx_packet(efx, rx_buf->data, rx_buf->len);
+		efx_free_rx_buffer(efx, rx_buf);
+		goto done;
+	}
+
 	if (rx_buf->skb) {
 		prefetch(skb_shinfo(rx_buf->skb));
 
@@ -736,7 +746,6 @@ void __efx_rx_packet(struct efx_channel *channel,
 	/* Update allocation strategy method */
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
 
-	/* fall-thru */
 done:
 	efx->net_dev->last_rx = jiffies;
 }
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
new file mode 100644
index 0000000..cbda159
--- /dev/null
+++ b/drivers/net/sfc/selftest.c
@@ -0,0 +1,717 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/kernel_stat.h>
+#include <linux/pci.h>
+#include <linux/ethtool.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/udp.h>
+#include <linux/rtnetlink.h>
+#include <asm/io.h>
+#include "net_driver.h"
+#include "ethtool.h"
+#include "efx.h"
+#include "falcon.h"
+#include "selftest.h"
+#include "boards.h"
+#include "workarounds.h"
+#include "mac.h"
+
+/*
+ * Loopback test packet structure
+ *
+ * The self-test should stress every RSS vector, and unfortunately
+ * Falcon only performs RSS on TCP/UDP packets.
+ */
+struct efx_loopback_payload {
+	struct ethhdr header;
+	struct iphdr ip;
+	struct udphdr udp;
+	__be16 iteration;
+	const char msg[64];
+} __attribute__ ((packed));
+
+/* Loopback test source MAC address */
+static const unsigned char payload_source[ETH_ALEN] = {
+	0x00, 0x0f, 0x53, 0x1b, 0x1b, 0x1b,
+};
+
+static const char *payload_msg =
+	"Hello world! This is an Efx loopback test in progress!";
+
+/**
+ * efx_selftest_state - persistent state during a selftest
+ * @flush:		Drop all packets in efx_loopback_rx_packet
+ * @packet_count:	Number of packets being used in this test
+ * @skbs:		An array of skbs transmitted
+ * @rx_good:		RX good packet count
+ * @rx_bad:		RX bad packet count
+ * @payload:		Payload used in tests
+ */
+struct efx_selftest_state {
+	int flush;
+	int packet_count;
+	struct sk_buff **skbs;
+	atomic_t rx_good;
+	atomic_t rx_bad;
+	struct efx_loopback_payload payload;
+};
+
+/**************************************************************************
+ *
+ * Configurable values
+ *
+ **************************************************************************/
+
+/* Level of loopback testing
+ *
+ * The maximum packet burst length is 16**(n-1), i.e.
+ *
+ * - Level 0 : no packets
+ * - Level 1 : 1 packet
+ * - Level 2 : 17 packets (1 * 1 packet, 1 * 16 packets)
+ * - Level 3 : 273 packets (1 * 1 packet, 1 * 16 packet, 1 * 256 packets)
+ *
+ */
+static unsigned int loopback_test_level = 3;
+
+/**************************************************************************
+ *
+ * Interrupt and event queue testing
+ *
+ **************************************************************************/
+
+/* Test generation and receipt of interrupts */
+static int efx_test_interrupts(struct efx_nic *efx,
+			       struct efx_self_tests *tests)
+{
+	struct efx_channel *channel;
+
+	EFX_LOG(efx, "testing interrupts\n");
+	tests->interrupt = -1;
+
+	/* Reset interrupt flag */
+	efx->last_irq_cpu = -1;
+	smp_wmb();
+
+	/* ACK each interrupting event queue. Receiving an interrupt due to
+	 * traffic before a test event is raised is considered a pass */
+	efx_for_each_channel_with_interrupt(channel, efx) {
+		if (channel->work_pending)
+			efx_process_channel_now(channel);
+		if (efx->last_irq_cpu >= 0)
+			goto success;
+	}
+
+	falcon_generate_interrupt(efx);
+
+	/* Wait for arrival of test interrupt. */
+	EFX_LOG(efx, "waiting for test interrupt\n");
+	schedule_timeout_uninterruptible(HZ / 10);
+	if (efx->last_irq_cpu >= 0)
+		goto success;
+
+	EFX_ERR(efx, "timed out waiting for interrupt\n");
+	return -ETIMEDOUT;
+
+ success:
+	EFX_LOG(efx, "test interrupt (mode %d) seen on CPU%d\n",
+		efx->interrupt_mode, efx->last_irq_cpu);
+	tests->interrupt = 1;
+	return 0;
+}
+
+/* Test generation and receipt of non-interrupting events */
+static int efx_test_eventq(struct efx_channel *channel,
+			   struct efx_self_tests *tests)
+{
+	unsigned int magic;
+
+	/* Channel specific code, limited to 20 bits */
+	magic = (0x00010150 + channel->channel);
+	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n",
+		channel->channel, magic);
+
+	tests->eventq_dma[channel->channel] = -1;
+	tests->eventq_int[channel->channel] = 1;	/* fake pass */
+	tests->eventq_poll[channel->channel] = 1;	/* fake pass */
+
+	/* Reset flag and zero magic word */
+	channel->efx->last_irq_cpu = -1;
+	channel->eventq_magic = 0;
+	smp_wmb();
+
+	falcon_generate_test_event(channel, magic);
+	udelay(1);
+
+	efx_process_channel_now(channel);
+	if (channel->eventq_magic != magic) {
+		EFX_ERR(channel->efx, "channel %d  failed to see test event\n",
+			channel->channel);
+		return -ETIMEDOUT;
+	} else {
+		tests->eventq_dma[channel->channel] = 1;
+	}
+
+	return 0;
+}
+
+/* Test generation and receipt of interrupting events */
+static int efx_test_eventq_irq(struct efx_channel *channel,
+			       struct efx_self_tests *tests)
+{
+	unsigned int magic, count;
+
+	/* Channel specific code, limited to 20 bits */
+	magic = (0x00010150 + channel->channel);
+	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n",
+		channel->channel, magic);
+
+	tests->eventq_dma[channel->channel] = -1;
+	tests->eventq_int[channel->channel] = -1;
+	tests->eventq_poll[channel->channel] = -1;
+
+	/* Reset flag and zero magic word */
+	channel->efx->last_irq_cpu = -1;
+	channel->eventq_magic = 0;
+	smp_wmb();
+
+	falcon_generate_test_event(channel, magic);
+
+	/* Wait for arrival of interrupt */
+	count = 0;
+	do {
+		schedule_timeout_uninterruptible(HZ / 100);
+
+		if (channel->work_pending)
+			efx_process_channel_now(channel);
+
+		if (channel->eventq_magic == magic)
+			goto eventq_ok;
+	} while (++count < 2);
+
+	EFX_ERR(channel->efx, "channel %d timed out waiting for event queue\n",
+		channel->channel);
+
+	/* See if interrupt arrived */
+	if (channel->efx->last_irq_cpu >= 0) {
+		EFX_ERR(channel->efx, "channel %d saw interrupt on CPU%d "
+			"during event queue test\n", channel->channel,
+			raw_smp_processor_id());
+		tests->eventq_int[channel->channel] = 1;
+	}
+
+	/* Check to see if event was received even if interrupt wasn't */
+	efx_process_channel_now(channel);
+	if (channel->eventq_magic == magic) {
+		EFX_ERR(channel->efx, "channel %d event was generated, but "
+			"failed to trigger an interrupt\n", channel->channel);
+		tests->eventq_dma[channel->channel] = 1;
+	}
+
+	return -ETIMEDOUT;
+ eventq_ok:
+	EFX_LOG(channel->efx, "channel %d event queue passed\n",
+		channel->channel);
+	tests->eventq_dma[channel->channel] = 1;
+	tests->eventq_int[channel->channel] = 1;
+	tests->eventq_poll[channel->channel] = 1;
+	return 0;
+}
+
+/**************************************************************************
+ *
+ * PHY testing
+ *
+ **************************************************************************/
+
+/* Check PHY presence by reading the PHY ID registers */
+static int efx_test_phy(struct efx_nic *efx,
+			struct efx_self_tests *tests)
+{
+	u16 physid1, physid2;
+	struct mii_if_info *mii = &efx->mii;
+	struct net_device *net_dev = efx->net_dev;
+
+	if (efx->phy_type == PHY_TYPE_NONE)
+		return 0;
+
+	EFX_LOG(efx, "testing PHY presence\n");
+	tests->phy_ok = -1;
+
+	physid1 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
+	physid2 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
+
+	if ((physid1 != 0x0000) && (physid1 != 0xffff) &&
+	    (physid2 != 0x0000) && (physid2 != 0xffff)) {
+		EFX_LOG(efx, "found MII PHY %d ID 0x%x:%x\n",
+			mii->phy_id, physid1, physid2);
+		tests->phy_ok = 1;
+		return 0;
+	}
+
+	EFX_ERR(efx, "no MII PHY present with ID %d\n", mii->phy_id);
+	return -ENODEV;
+}
+
+/**************************************************************************
+ *
+ * Loopback testing
+ * NB Only one loopback test can be executing concurrently.
+ *
+ **************************************************************************/
+
+/* Loopback test RX callback
+ * This is called for each received packet during loopback testing.
+ */
+void efx_loopback_rx_packet(struct efx_nic *efx,
+			    const char *buf_ptr, int pkt_len)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_payload *received;
+	struct efx_loopback_payload *payload;
+
+	BUG_ON(!buf_ptr);
+
+	/* If we are just flushing, then drop the packet */
+	if ((state == NULL) || state->flush)
+		return;
+
+	payload = &state->payload;
+	
+	received = (struct efx_loopback_payload *)(char *) buf_ptr;
+	received->ip.saddr = payload->ip.saddr;
+	received->ip.check = payload->ip.check;
+	
+	/* Check that header exists */
+	if (pkt_len < sizeof(received->header)) {
+		EFX_ERR(efx, "saw runt RX packet (length %d) in %s loopback "
+			"test\n", pkt_len, LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that the ethernet header exists */
+	if (memcmp(&received->header, &payload->header, ETH_HLEN) != 0) {
+		EFX_ERR(efx, "saw non-loopback RX packet in %s loopback test\n",
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check packet length */
+	if (pkt_len != sizeof(*payload)) {
+		EFX_ERR(efx, "saw incorrect RX packet length %d (wanted %d) in "
+			"%s loopback test\n", pkt_len, (int)sizeof(*payload),
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that IP header matches */
+	if (memcmp(&received->ip, &payload->ip, sizeof(payload->ip)) != 0) {
+		EFX_ERR(efx, "saw corrupted IP header in %s loopback test\n",
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that msg and padding matches */
+	if (memcmp(&received->msg, &payload->msg, sizeof(received->msg)) != 0) {
+		EFX_ERR(efx, "saw corrupted RX packet in %s loopback test\n",
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that iteration matches */
+	if (received->iteration != payload->iteration) {
+		EFX_ERR(efx, "saw RX packet from iteration %d (wanted %d) in "
+			"%s loopback test\n", ntohs(received->iteration),
+			ntohs(payload->iteration), LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Increase correct RX count */
+	EFX_TRACE(efx, "got loopback RX in %s loopback test\n",
+		  LOOPBACK_MODE(efx));
+
+	atomic_inc(&state->rx_good);
+	return;
+
+ err:
+#ifdef EFX_ENABLE_DEBUG
+	if (atomic_read(&state->rx_bad) == 0) {
+		EFX_ERR(efx, "received packet:\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
+			       buf_ptr, pkt_len, 0);
+		EFX_ERR(efx, "expected packet:\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
+			       &state->payload, sizeof(state->payload), 0);
+	}
+#endif
+	atomic_inc(&state->rx_bad);
+}
+
+/* Initialise an efx_selftest_state for a new iteration */
+static void efx_iterate_state(struct efx_nic *efx)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct net_device *net_dev = efx->net_dev;
+	struct efx_loopback_payload *payload = &state->payload;
+
+	/* Initialise the layerII header */
+	memcpy(&payload->header.h_dest, net_dev->dev_addr, ETH_ALEN);
+	memcpy(&payload->header.h_source, &payload_source, ETH_ALEN);
+	payload->header.h_proto = htons(ETH_P_IP);
+
+	/* saddr set later and used as incrementing count */
+	payload->ip.daddr = htonl(INADDR_LOOPBACK);
+	payload->ip.ihl = 5;
+	payload->ip.check = htons(0xdead);
+	payload->ip.tot_len = htons(sizeof(*payload) - sizeof(struct ethhdr));
+	payload->ip.version = IPVERSION;
+	payload->ip.protocol = IPPROTO_UDP;
+
+	/* Initialise udp header */
+	payload->udp.source = 0;
+	payload->udp.len = htons(sizeof(*payload) - sizeof(struct ethhdr) -
+				 sizeof(struct iphdr));
+	payload->udp.check = 0;	/* checksum ignored */
+
+	/* Fill out payload */
+	payload->iteration = htons(ntohs(payload->iteration) + 1);
+	memcpy(&payload->msg, payload_msg, sizeof(payload_msg));
+
+	/* Fill out remaining state members */
+	atomic_set(&state->rx_good, 0);
+	atomic_set(&state->rx_bad, 0);
+	smp_wmb();
+}
+
+static int efx_tx_loopback(struct efx_tx_queue *tx_queue)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_payload *payload;
+	struct sk_buff *skb;
+	int i, rc;
+
+	/* Transmit N copies of buffer */
+	for (i = 0; i < state->packet_count; i++) {
+		/* Allocate an skb, holding an extra reference for 
+		 * transmit completion counting */
+		skb = alloc_skb(sizeof(state->payload), GFP_KERNEL);
+		if (!skb)
+			return -ENOMEM;
+		state->skbs[i] = skb;
+		skb_get(skb);
+
+		/* Copy the payload in, incrementing the source address to
+		 * exercise the rss vectors */
+		payload = ((struct efx_loopback_payload *)
+			   skb_put(skb, sizeof(state->payload)));
+		memcpy(payload, &state->payload, sizeof(state->payload));
+		payload->ip.saddr = htonl(INADDR_LOOPBACK | (i << 2));
+
+		/* Ensure everything we've written is visible to the
+		 * interrupt handler. */
+		smp_wmb();
+
+		if (NET_DEV_REGISTERED(efx))
+			netif_tx_lock_bh(efx->net_dev);
+		rc = efx_xmit(efx, tx_queue, skb);
+		if (NET_DEV_REGISTERED(efx))
+			netif_tx_unlock_bh(efx->net_dev);
+
+		if (rc != NETDEV_TX_OK) {
+			EFX_ERR(efx, "TX queue %d could not transmit packet %d "
+				"of %d in %s loopback test\n", tx_queue->queue,
+				i + 1, state->packet_count, LOOPBACK_MODE(efx));
+
+			/* Defer cleaning up the other skbs for the caller */
+			kfree_skb(skb);
+			return -EPIPE;
+		}
+	}
+
+	return 0;
+}
+
+static int efx_rx_loopback(struct efx_tx_queue *tx_queue,
+			   struct efx_loopback_self_tests *lb_tests)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct sk_buff *skb;
+	int tx_done = 0, rx_good, rx_bad;
+	int i, rc = 0;
+
+	if (NET_DEV_REGISTERED(efx))
+		netif_tx_lock_bh(efx->net_dev);
+
+	/* Count the number of tx completions, and decrement the refcnt. Any
+	 * skbs not already completed will be free'd when the queue is flushed */
+	for (i=0; i < state->packet_count; i++) {
+		skb = state->skbs[i];
+		if (skb && !skb_shared(skb))
+			++tx_done;
+		dev_kfree_skb_any(skb);
+	}
+
+	if (NET_DEV_REGISTERED(efx))
+		netif_tx_unlock_bh(efx->net_dev);
+
+	/* Check TX completion and received packet counts */
+	rx_good = atomic_read(&state->rx_good);
+	rx_bad = atomic_read(&state->rx_bad);
+	if (tx_done != state->packet_count) {
+		/* Don't free the skbs; they will be picked up on TX
+		 * overflow or channel teardown.
+		 */
+		EFX_ERR(efx, "TX queue %d saw only %d out of an expected %d "
+			"TX completion events in %s loopback test\n",
+			tx_queue->queue, tx_done, state->packet_count,
+			LOOPBACK_MODE(efx));
+		rc = -ETIMEDOUT;
+		/* Allow to fall through so we see the RX errors as well */
+	}
+
+	/* We may always be up to a flush away from our desired packet total */
+	if (rx_good != state->packet_count) {
+		EFX_LOG(efx, "TX queue %d saw only %d out of an expected %d "
+			"received packets in %s loopback test\n",
+			tx_queue->queue, rx_good, state->packet_count,
+			LOOPBACK_MODE(efx));
+		rc = -ETIMEDOUT;
+		/* Fall through */
+	}
+
+	/* Update loopback test structure */
+	lb_tests->tx_sent[tx_queue->queue] += state->packet_count;
+	lb_tests->tx_done[tx_queue->queue] += tx_done;
+	lb_tests->rx_good += rx_good;
+	lb_tests->rx_bad += rx_bad;
+
+	return rc;
+}
+
+static int
+efx_test_loopback(struct efx_tx_queue *tx_queue,
+		  struct efx_loopback_self_tests *lb_tests)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_channel *channel;
+	int i, rc = 0;
+
+	for (i = 0; i < loopback_test_level; i++) {
+		/* Determine how many packets to send */
+		state->packet_count = (efx->type->txd_ring_mask + 1) / 3;
+		state->packet_count = min(1 << (i << 2), state->packet_count);
+		state->skbs = kzalloc(sizeof(state->skbs[0]) *
+				      state->packet_count, GFP_KERNEL);
+		state->flush = 0;
+
+		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
+			"packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
+			state->packet_count);
+
+		efx_iterate_state(efx);
+		rc = efx_tx_loopback(tx_queue);
+		
+		/* NAPI polling is not enabled, so process channels synchronously */
+		schedule_timeout_uninterruptible(HZ / 50);
+		efx_for_each_channel_with_interrupt(channel, efx) {
+			if (channel->work_pending)
+				efx_process_channel_now(channel);
+		}
+
+		rc |= efx_rx_loopback(tx_queue, lb_tests);
+		kfree(state->skbs);
+
+		if (rc) {
+			/* Wait a while to ensure there are no packets
+			 * floating around after a failure. */
+			schedule_timeout_uninterruptible(HZ / 10);
+			return rc;
+		}
+	}
+
+	EFX_LOG(efx, "TX queue %d passed %s loopback test with a burst length "
+		"of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
+		state->packet_count);
+
+	return rc;
+}
+
+static int efx_test_loopbacks(struct efx_nic *efx,
+			      struct efx_self_tests *tests,
+			      unsigned int loopback_modes)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct ethtool_cmd ecmd, ecmd_loopback;
+	struct efx_tx_queue *tx_queue;
+	enum efx_loopback_mode old_mode, mode;
+	int count, rc = 0, link_up;
+	
+	rc = efx_ethtool_get_settings(efx->net_dev, &ecmd);
+	if (rc) {
+		EFX_ERR(efx, "could not get GMII settings\n");
+		return rc;
+	}
+	old_mode = efx->loopback_mode;
+
+	/* Disable autonegotiation for the purposes of loopback */
+	memcpy(&ecmd_loopback, &ecmd, sizeof(ecmd_loopback));
+	if (ecmd_loopback.autoneg == AUTONEG_ENABLE) {
+		ecmd_loopback.autoneg = AUTONEG_DISABLE;
+		ecmd_loopback.duplex = DUPLEX_FULL;
+		ecmd_loopback.speed = SPEED_10000;
+	}
+
+	rc = efx_ethtool_set_settings(efx->net_dev, &ecmd_loopback);
+	if (rc) {
+		EFX_ERR(efx, "could not disable autonegotiation\n");
+		goto out;
+	}
+	tests->loopback_speed = ecmd_loopback.speed;
+	tests->loopback_full_duplex = ecmd_loopback.duplex;
+
+	/* Test all supported loopback modes */
+	for (mode = LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+		if (!(loopback_modes & (1 << mode)))
+			continue;
+
+		/* Move the port into the specified loopback mode. */
+		state->flush = 1;
+		efx->loopback_mode = mode;
+		efx_reconfigure_port(efx);
+
+		/* Wait for the PHY to signal the link is up */
+		count = 0;
+		do {
+			struct efx_channel *channel = &efx->channel[0];
+
+			falcon_check_xmac(efx);
+			schedule_timeout_uninterruptible(HZ / 10);
+			if (channel->work_pending)
+				efx_process_channel_now(channel);
+			/* Wait for PHY events to be processed */
+			flush_workqueue(efx->workqueue);
+			rmb();
+
+			/* efx->link_up can be 1 even if the XAUI link is down,
+			 * (bug5762). Usually, it's not worth bothering with the
+			 * difference, but for selftests, we need that extra
+			 * guarantee that the link is really, really, up.
+			 */
+			link_up = efx->link_up;
+			if (!falcon_xaui_link_ok(efx))
+				link_up = 0;
+
+		} while ((++count < 20) && !link_up);
+
+		/* The link should now be up. If it isn't, there is no point
+		 * in attempting a loopback test */
+		if (!link_up) {
+			EFX_ERR(efx, "loopback %s never came up\n",
+				LOOPBACK_MODE(efx));
+			rc = -EIO;
+			goto out;
+		}
+
+		EFX_LOG(efx, "link came up in %s loopback in %d iterations\n",
+			LOOPBACK_MODE(efx), count);
+
+		/* Test every TX queue */
+		efx_for_each_tx_queue(tx_queue, efx) {
+			rc |= efx_test_loopback(tx_queue,
+						&tests->loopback[mode]);
+			if (rc)
+				goto out;
+		}
+	}
+
+ out:
+	/* Take out of loopback and restore PHY settings */
+	state->flush = 1;
+	efx->loopback_mode = old_mode;
+	efx_ethtool_set_settings(efx->net_dev, &ecmd);
+
+	return rc;
+}
+
+/**************************************************************************
+ *
+ * Entry points
+ *
+ *************************************************************************/
+
+/* Online (i.e. non-disruptive) testing
+ * This checks interrupt generation, event delivery and PHY presence. */
+int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
+{
+	struct efx_channel *channel;
+	int rc = 0;
+
+	EFX_LOG(efx, "performing online self-tests\n");
+
+	rc |= efx_test_interrupts(efx, tests);
+	efx_for_each_channel(channel, efx) {
+		if (channel->has_interrupt)
+			rc |= efx_test_eventq_irq(channel, tests);
+		else
+			rc |= efx_test_eventq(channel, tests);
+	}
+	rc |= efx_test_phy(efx, tests);
+
+	if (rc)
+		EFX_ERR(efx, "failed online self-tests\n");
+
+	return rc;
+}
+
+/* Offline (i.e. disruptive) testing
+ * This checks MAC and PHY loopback on the specified port. */
+int efx_offline_test(struct efx_nic *efx,
+		     struct efx_self_tests *tests, unsigned int loopback_modes)
+{
+	struct efx_selftest_state *state;
+	int rc = 0;
+
+	EFX_LOG(efx, "performing offline self-tests\n");
+
+	/* Create a selftest_state structure to hold state for the test */
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
+	if (state == NULL) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	/* Set the port loopback_selftest member. From this point on
+	 * all received packets will be dropped. Mark the state as
+	 * "flushing" so all inflight packets are dropped */
+	BUG_ON(efx->loopback_selftest);
+	state->flush = 1;
+	efx->loopback_selftest = (void *)state;
+
+	rc = efx_test_loopbacks(efx, tests, loopback_modes);
+
+	efx->loopback_selftest = NULL;
+	wmb();
+	kfree(state);
+
+ out:
+	if (rc)
+		EFX_ERR(efx, "failed offline self-tests\n");
+
+	return rc;
+}
+
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
new file mode 100644
index 0000000..f6999c2
--- /dev/null
+++ b/drivers/net/sfc/selftest.h
@@ -0,0 +1,50 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_SELFTEST_H
+#define EFX_SELFTEST_H
+
+#include "net_driver.h"
+
+/*
+ * Self tests
+ */
+
+struct efx_loopback_self_tests {
+	int tx_sent[EFX_MAX_TX_QUEUES];
+	int tx_done[EFX_MAX_TX_QUEUES];
+	int rx_good;
+	int rx_bad;
+};
+
+/* Efx self test results
+ * For fields which are not counters, 1 indicates success and -1
+ * indicates failure.
+ */
+struct efx_self_tests {
+	int interrupt;
+	int eventq_dma[EFX_MAX_CHANNELS];
+	int eventq_int[EFX_MAX_CHANNELS];
+	int eventq_poll[EFX_MAX_CHANNELS];
+	int phy_ok;
+	int loopback_speed;
+	int loopback_full_duplex;
+	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX];
+};
+
+extern void efx_loopback_rx_packet(struct efx_nic *efx,
+				   const char *buf_ptr, int pkt_len);
+extern int efx_online_test(struct efx_nic *efx,
+			   struct efx_self_tests *tests);
+extern int efx_offline_test(struct efx_nic *efx,
+			    struct efx_self_tests *tests,
+			    unsigned int loopback_modes);
+
+#endif /* EFX_SELFTEST_H */
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 11fa9fb..725d1a5 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -130,6 +130,15 @@ void sfe4001_poweroff(struct efx_nic *efx)
 	(void) efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
 }
 
+/* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
+ * to the FLASH_CFG_1 input on the DSP.  We must keep it high at power-
+ * up to allow writing the flash (done through MDIO from userland).
+ */
+unsigned int sfe4001_phy_flash_cfg;
+module_param_named(phy_flash_cfg, sfe4001_phy_flash_cfg, uint, 0444);
+MODULE_PARM_DESC(phy_flash_cfg,
+		 "Force PHY to enter flash configuration mode");
+
 /* This board uses an I2C expander to provider power to the PHY, which needs to
  * be turned on before the PHY can be used.
  * Context: Process context, rtnl lock held
@@ -203,6 +212,8 @@ int sfe4001_poweron(struct efx_nic *efx)
 		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
 			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
 			       (1 << P0_X_TRST_LBN));
+		if (sfe4001_phy_flash_cfg)
+			out |= 1 << P0_EN_3V3X_LBN;
 
 		rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
 		if (rc)
@@ -226,6 +237,9 @@ int sfe4001_poweron(struct efx_nic *efx)
 		if (in & (1 << P1_AFE_PWD_LBN))
 			goto done;
 
+		/* DSP doesn't look powered in flash config mode */
+		if (sfe4001_phy_flash_cfg)
+			goto done;
 	} while (++count < 20);
 
 	EFX_INFO(efx, "timed out waiting for power\n");
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index a2e9f79..b1cd6de 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -24,6 +24,11 @@
 				 MDIO_MMDREG_DEVS0_PCS    | \
 				 MDIO_MMDREG_DEVS0_PHYXS)
 
+#define TENXPRESS_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
+			     (1 << LOOPBACK_PCS) |	\
+			     (1 << LOOPBACK_PMAPMD) |	\
+			     (1 << LOOPBACK_NETWORK))
+
 /* We complain if we fail to see the link partner as 10G capable this many
  * times in a row (must be > 1 as sampling the autoneg. registers is racy)
  */
@@ -72,6 +77,10 @@
 #define PMA_PMD_BIST_RXD_LBN	(1)
 #define PMA_PMD_BIST_AFE_LBN	(0)
 
+/* Special Software reset register */
+#define PMA_PMD_EXT_CTRL_REG 49152
+#define PMA_PMD_EXT_SSR_LBN 15
+
 #define BIST_MAX_DELAY	(1000)
 #define BIST_POLL_DELAY	(10)
 
@@ -86,6 +95,11 @@
 #define	PCS_TEST_SELECT_REG 0xd807	/* PRM 10.5.8 */
 #define	CLK312_EN_LBN 3
 
+/* PHYXS registers */
+#define PHYXS_TEST1         (49162)
+#define LOOPBACK_NEAR_LBN   (8)
+#define LOOPBACK_NEAR_WIDTH (1)
+
 /* Boot status register */
 #define PCS_BOOT_STATUS_REG	(0xd000)
 #define PCS_BOOT_FATAL_ERR_LBN	(0)
@@ -106,7 +120,9 @@ MODULE_PARM_DESC(crc_error_reset_threshold,
 
 struct tenxpress_phy_data {
 	enum tenxpress_state state;
+	enum efx_loopback_mode loopback_mode;
 	atomic_t bad_crc_count;
+	int tx_disabled;
 	int bad_lp_tries;
 };
 
@@ -199,10 +215,12 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 
 	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
 
-	rc = mdio_clause45_wait_reset_mmds(efx,
-					   TENXPRESS_REQUIRED_DEVS);
-	if (rc < 0)
-		goto fail;
+	if (!sfe4001_phy_flash_cfg) {
+		rc = mdio_clause45_wait_reset_mmds(efx,
+						   TENXPRESS_REQUIRED_DEVS);
+		if (rc < 0)
+			goto fail;
+	}
 
 	rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
 	if (rc < 0)
@@ -225,6 +243,35 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	return rc;
 }
 
+static int tenxpress_special_reset(struct efx_nic *efx)
+{
+	int rc, reg;
+
+	EFX_TRACE(efx, "%s\n", __func__);
+
+	/* Initiate reset */
+	reg = mdio_clause45_read(efx, efx->mii.phy_id,
+				 MDIO_MMD_PMAPMD, PMA_PMD_EXT_CTRL_REG);
+	reg |= (1 << PMA_PMD_EXT_SSR_LBN);
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_EXT_CTRL_REG, reg);
+
+	msleep(200);
+
+	/* Wait for the blocks to come out of reset */
+	rc = mdio_clause45_wait_reset_mmds(efx,
+					   TENXPRESS_REQUIRED_DEVS);
+	if (rc < 0)
+		return rc;
+
+	/* Try and reconfigure the device */
+	rc = tenxpress_init(efx);
+	if (rc < 0)
+		return rc;
+
+	return 0;
+}
+
 static void tenxpress_set_bad_lp(struct efx_nic *efx, int bad_lp)
 {
 	struct tenxpress_phy_data *pd = efx->phy_data;
@@ -299,11 +346,46 @@ static int tenxpress_link_ok(struct efx_nic *efx, int check_lp)
 	return ok;
 }
 
+static void tenxpress_phyxs_loopback(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int ctrl1, ctrl2;
+
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+					   PHYXS_TEST1);
+	if (efx->loopback_mode == LOOPBACK_PHYXS)
+		ctrl2 |= (1 << LOOPBACK_NEAR_LBN);
+	else
+		ctrl2 &= ~(1 << LOOPBACK_NEAR_LBN);
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PHYXS,
+				    PHYXS_TEST1, ctrl2);
+}
+
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	int loop_change = LOOPBACK_OUT_OF(phy_data, efx,
+					  TENXPRESS_LOOPBACKS);
+
 	if (!tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL))
 		return;
 
+	/* When coming out of transmit disable, coming out of low power
+	 * mode, or moving out of any PHY internal loopback mode,
+	 * perform a special software reset */
+	if ((phy_data->tx_disabled && !efx->tx_disabled) ||
+	    loop_change) {
+		(void) tenxpress_special_reset(efx);
+		falcon_reset_xaui(efx);
+	}
+
+	mdio_clause45_transmit_disable(efx);
+	mdio_clause45_phy_reconfigure(efx);
+	tenxpress_phyxs_loopback(efx);
+
+	phy_data->tx_disabled = efx->tx_disabled;
+	phy_data->loopback_mode = efx->loopback_mode;
 	efx->link_up = tenxpress_link_ok(efx, 0);
 	efx->link_options = GM_LPA_10000FULL;
 }
@@ -431,4 +513,5 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
 	.reset_xaui       = tenxpress_reset_xaui,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
+	.loopbacks        = TENXPRESS_LOOPBACKS,
 };
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index fbb866b..9b436f5 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -82,6 +82,46 @@ static inline void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 	}
 }
 
+/**
+ * struct efx_tso_header - a DMA mapped buffer for packet headers
+ * @next: Linked list of free ones.
+ *	The list is protected by the TX queue lock.
+ * @dma_unmap_len: Length to unmap for an oversize buffer, or 0.
+ * @dma_addr: The DMA address of the header below.
+ *
+ * This controls the memory used for a TSO header.  Use TSOH_DATA()
+ * to find the packet header data.  Use TSOH_SIZE() to calculate the
+ * total size required for a given packet header length.  TSO headers
+ * in the free list are exactly %TSOH_STD_SIZE bytes in size.
+ */
+struct efx_tso_header {
+	union {
+		struct efx_tso_header *next;
+		size_t unmap_len;
+	};
+	dma_addr_t dma_addr;
+};
+
+static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
+			       const struct sk_buff *skb);
+static void efx_fini_tso(struct efx_tx_queue *tx_queue);
+static void efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,
+			       struct efx_tso_header *tsoh);
+
+static inline void efx_tsoh_free(struct efx_tx_queue *tx_queue,
+				 struct efx_tx_buffer *buffer)
+{
+	if (buffer->tsoh) {
+		if (likely(!buffer->tsoh->unmap_len)) {
+			buffer->tsoh->next = tx_queue->tso_headers_free;
+			tx_queue->tso_headers_free = buffer->tsoh;
+		} else {
+			efx_tsoh_heap_free(tx_queue, buffer->tsoh);
+		}
+		buffer->tsoh = NULL;
+	}
+}
+
 
 /*
  * Add a socket buffer to a TX queue
@@ -114,6 +154,9 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 
 	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 
+	if (skb_shinfo((struct sk_buff *)skb)->gso_size)
+		return efx_enqueue_skb_tso(tx_queue, skb);
+
 	/* Get size of the initial fragment */
 	len = skb_headlen(skb);
 
@@ -166,6 +209,8 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 			insert_ptr = (tx_queue->insert_count &
 				      efx->type->txd_ring_mask);
 			buffer = &tx_queue->buffer[insert_ptr];
+			efx_tsoh_free(tx_queue, buffer);
+			EFX_BUG_ON_PARANOID(buffer->tsoh);
 			EFX_BUG_ON_PARANOID(buffer->skb);
 			EFX_BUG_ON_PARANOID(buffer->len);
 			EFX_BUG_ON_PARANOID(buffer->continuation != 1);
@@ -432,6 +477,9 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 
 	efx_release_tx_buffers(tx_queue);
 
+	/* Free up TSO header cache */
+	efx_fini_tso(tx_queue);
+
 	/* Release queue's stop on port, if any */
 	if (tx_queue->stopped) {
 		tx_queue->stopped = 0;
@@ -450,3 +498,619 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 }
 
 
+/* Efx TCP segmentation acceleration.
+ *
+ * Why?  Because by doing it here in the driver we can go significantly
+ * faster than the GSO.
+ *
+ * Requires TX checksum offload support.
+ */
+
+/* Number of bytes inserted at the start of a TSO header buffer,
+ * similar to NET_IP_ALIGN.
+ */
+#if defined(__i386__) || defined(__x86_64__)
+#define TSOH_OFFSET	0
+#else
+#define TSOH_OFFSET	NET_IP_ALIGN
+#endif
+
+#define TSOH_BUFFER(tsoh)	((u8 *)(tsoh + 1) + TSOH_OFFSET)
+
+/* Total size of struct efx_tso_header, buffer and padding */
+#define TSOH_SIZE(hdr_len)					\
+	(sizeof(struct efx_tso_header) + TSOH_OFFSET + hdr_len)
+
+/* Size of blocks on free list.  Larger blocks must be allocated from
+ * the heap.
+ */
+#define TSOH_STD_SIZE		128
+
+#define PTR_DIFF(p1, p2)  ((u8 *)(p1) - (u8 *)(p2))
+#define ETH_HDR_LEN(skb)  (skb_network_header(skb) - (skb)->data)
+#define SKB_TCP_OFF(skb)  PTR_DIFF(tcp_hdr(skb), (skb)->data)
+#define SKB_IPV4_OFF(skb) PTR_DIFF(ip_hdr(skb), (skb)->data)
+
+/**
+ * struct tso_state - TSO state for an SKB
+ * @remaining_len: Bytes of data we've yet to segment
+ * @seqnum: Current sequence number
+ * @packet_space: Remaining space in current packet
+ * @ifc: Input fragment cursor.
+ *	Where we are in the current fragment of the incoming SKB.  These
+ *	values get updated in place when we split a fragment over
+ *	multiple packets.
+ * @p: Parameters.
+ *	These values are set once at the start of the TSO send and do
+ *	not get changed as the routine progresses.
+ *
+ * The state used during segmentation.  It is put into this data structure
+ * just to make it easy to pass into inline functions.
+ */
+struct tso_state {
+	unsigned remaining_len;
+	unsigned seqnum;
+	unsigned packet_space;
+
+	struct {
+		/* DMA address of current position */
+		dma_addr_t dma_addr;
+		/* Remaining length */
+		unsigned int len;
+		/* DMA address and length of the whole fragment */
+		unsigned int unmap_len;
+		dma_addr_t unmap_addr;
+		struct page *page;
+		unsigned page_off;
+	} ifc;
+
+	struct {
+		/* The number of bytes of header */
+		unsigned int header_length;
+
+		/* The number of bytes to put in each outgoing segment. */
+		int full_packet_size;
+
+		/* Current IPv4 ID, host endian. */
+		unsigned ipv4_id;
+	} p;
+};
+
+
+/*
+ * Verify that our various assumptions about sk_buffs and the conditions
+ * under which TSO will be attempted hold true.
+ */
+static inline void efx_tso_check_safe(const struct sk_buff *skb)
+{
+	EFX_BUG_ON_PARANOID(skb->protocol != htons(ETH_P_IP));
+	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
+			    skb->protocol);
+	EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
+	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
+			     + (tcp_hdr(skb)->doff << 2u)) >
+			    skb_headlen(skb));
+}
+
+
+/*
+ * Allocate a page worth of efx_tso_header structures, and string them
+ * into the tx_queue->tso_headers_free linked list. Return 0 or -ENOMEM.
+ */
+static int efx_tsoh_block_alloc(struct efx_tx_queue *tx_queue)
+{
+
+	struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
+	struct efx_tso_header *tsoh;
+	dma_addr_t dma_addr;
+	u8 *base_kva, *kva;
+
+	base_kva = pci_alloc_consistent(pci_dev, PAGE_SIZE, &dma_addr);
+	if (base_kva == NULL) {
+		EFX_ERR(tx_queue->efx, "Unable to allocate page for TSO"
+			" headers\n");
+		return -ENOMEM;
+	}
+
+	/* pci_alloc_consistent() allocates pages. */
+	EFX_BUG_ON_PARANOID(dma_addr & (PAGE_SIZE - 1u));
+
+	for (kva = base_kva; kva < base_kva + PAGE_SIZE; kva += TSOH_STD_SIZE) {
+		tsoh = (struct efx_tso_header *)kva;
+		tsoh->dma_addr = dma_addr + (TSOH_BUFFER(tsoh) - base_kva);
+		tsoh->next = tx_queue->tso_headers_free;
+		tx_queue->tso_headers_free = tsoh;
+	}
+
+	return 0;
+}
+
+
+/* Free up a TSO header, and all others in the same page. */
+static void efx_tsoh_block_free(struct efx_tx_queue *tx_queue,
+				struct efx_tso_header *tsoh,
+				struct pci_dev *pci_dev)
+{
+	struct efx_tso_header **p;
+	unsigned long base_kva;
+	dma_addr_t base_dma;
+
+	base_kva = (unsigned long)tsoh & PAGE_MASK;
+	base_dma = tsoh->dma_addr & PAGE_MASK;
+
+	p = &tx_queue->tso_headers_free;
+	while (*p != NULL)
+		if (((unsigned long)*p & PAGE_MASK) == base_kva)
+			*p = (*p)->next;
+		else
+			p = &(*p)->next;
+
+	pci_free_consistent(pci_dev, PAGE_SIZE, (void *)base_kva, base_dma);
+}
+
+static struct efx_tso_header *
+efx_tsoh_heap_alloc(struct efx_tx_queue *tx_queue, size_t header_len)
+{
+	struct efx_tso_header *tsoh;
+
+	tsoh = kmalloc(TSOH_SIZE(header_len), GFP_ATOMIC | GFP_DMA);
+	if (unlikely(!tsoh))
+		return NULL;
+
+	tsoh->dma_addr = pci_map_single(tx_queue->efx->pci_dev,
+					TSOH_BUFFER(tsoh), header_len,
+					PCI_DMA_TODEVICE);
+	if (unlikely(pci_dma_mapping_error(tsoh->dma_addr))) {
+		kfree(tsoh);
+		return NULL;
+	}
+
+	tsoh->unmap_len = header_len;
+	return tsoh;
+}
+
+static void
+efx_tsoh_heap_free(struct efx_tx_queue *tx_queue, struct efx_tso_header *tsoh)
+{
+	pci_unmap_single(tx_queue->efx->pci_dev,
+			 tsoh->dma_addr, tsoh->unmap_len,
+			 PCI_DMA_TODEVICE);
+	kfree(tsoh);
+}
+
+/**
+ * efx_tx_queue_insert - push descriptors onto the TX queue
+ * @tx_queue:		Efx TX queue
+ * @dma_addr:		DMA address of fragment
+ * @len:		Length of fragment
+ * @skb:		Only non-null for end of last segment
+ * @end_of_packet:	True if last fragment in a packet
+ * @unmap_addr:		DMA address of fragment for unmapping
+ * @unmap_len:		Only set this in last segment of a fragment
+ *
+ * Push descriptors onto the TX queue.  Return 0 on success or 1 if
+ * @tx_queue full.
+ */
+static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
+			       dma_addr_t dma_addr, unsigned len,
+			       const struct sk_buff *skb, int end_of_packet,
+			       dma_addr_t unmap_addr, unsigned unmap_len)
+{
+	struct efx_tx_buffer *buffer;
+	struct efx_nic *efx = tx_queue->efx;
+	unsigned dma_len, fill_level, insert_ptr, misalign;
+	int q_space;
+
+	EFX_BUG_ON_PARANOID(len <= 0);
+
+	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
+	/* -1 as there is no way to represent all descriptors used */
+	q_space = efx->type->txd_ring_mask - 1 - fill_level;
+
+	while (1) {
+		if (unlikely(q_space-- <= 0)) {
+			/* It might be that completions have happened
+			 * since the xmit path last checked.  Update
+			 * the xmit path's copy of read_count.
+			 */
+			++tx_queue->stopped;
+			/* This memory barrier protects the change of
+			 * stopped from the access of read_count. */
+			smp_mb();
+			tx_queue->old_read_count =
+				*(volatile unsigned *)&tx_queue->read_count;
+			fill_level = (tx_queue->insert_count
+				      - tx_queue->old_read_count);
+			q_space = efx->type->txd_ring_mask - 1 - fill_level;
+			if (unlikely(q_space-- <= 0))
+				return 1;
+			smp_mb();
+			--tx_queue->stopped;
+		}
+
+		insert_ptr = tx_queue->insert_count & efx->type->txd_ring_mask;
+		buffer = &tx_queue->buffer[insert_ptr];
+		++tx_queue->insert_count;
+
+		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
+				    tx_queue->read_count >
+				    efx->type->txd_ring_mask);
+
+		efx_tsoh_free(tx_queue, buffer);
+		EFX_BUG_ON_PARANOID(buffer->len);
+		EFX_BUG_ON_PARANOID(buffer->unmap_len);
+		EFX_BUG_ON_PARANOID(buffer->skb);
+		EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+		EFX_BUG_ON_PARANOID(buffer->tsoh);
+
+		buffer->dma_addr = dma_addr;
+
+		/* Ensure we do not cross a boundary unsupported by H/W */
+		dma_len = (~dma_addr & efx->type->tx_dma_mask) + 1;
+
+		misalign = (unsigned)dma_addr & efx->type->bug5391_mask;
+		if (misalign && dma_len + misalign > 512)
+			dma_len = 512 - misalign;
+
+		/* If there is enough space to send then do so */
+		if (dma_len >= len)
+			break;
+
+		buffer->len = dma_len; /* Don't set the other members */
+		dma_addr += dma_len;
+		len -= dma_len;
+	}
+
+	EFX_BUG_ON_PARANOID(!len);
+	buffer->len = len;
+	buffer->skb = skb;
+	buffer->continuation = !end_of_packet;
+	buffer->unmap_addr = unmap_addr;
+	buffer->unmap_len = unmap_len;
+	return 0;
+}
+
+
+/*
+ * Put a TSO header into the TX queue.
+ *
+ * This is special-cased because we know that it is small enough to fit in
+ * a single fragment, and we know it doesn't cross a page boundary.  It
+ * also allows us to not worry about end-of-packet etc.
+ */
+static inline void efx_tso_put_header(struct efx_tx_queue *tx_queue,
+				      struct efx_tso_header *tsoh, unsigned len)
+{
+	struct efx_tx_buffer *buffer;
+
+	buffer = &tx_queue->buffer[tx_queue->insert_count &
+				   tx_queue->efx->type->txd_ring_mask];
+	efx_tsoh_free(tx_queue, buffer);
+	EFX_BUG_ON_PARANOID(buffer->len);
+	EFX_BUG_ON_PARANOID(buffer->unmap_len);
+	EFX_BUG_ON_PARANOID(buffer->skb);
+	EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+	EFX_BUG_ON_PARANOID(buffer->tsoh);
+	buffer->len = len;
+	buffer->dma_addr = tsoh->dma_addr;
+	buffer->tsoh = tsoh;
+
+	++tx_queue->insert_count;
+}
+
+
+/* Remove descriptors put into a tx_queue. */
+static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
+{
+	struct efx_tx_buffer *buffer;
+
+	/* Work backwards until we hit the original insert pointer value */
+	while (tx_queue->insert_count != tx_queue->write_count) {
+		--tx_queue->insert_count;
+		buffer = &tx_queue->buffer[tx_queue->insert_count &
+					   tx_queue->efx->type->txd_ring_mask];
+		efx_tsoh_free(tx_queue, buffer);
+		EFX_BUG_ON_PARANOID(buffer->skb);
+		buffer->len = 0;
+		buffer->continuation = 1;
+		if (buffer->unmap_len) {
+			pci_unmap_page(tx_queue->efx->pci_dev,
+				       buffer->unmap_addr,
+				       buffer->unmap_len, PCI_DMA_TODEVICE);
+			buffer->unmap_len = 0;
+		}
+	}
+}
+
+
+/* Parse the SKB header and initialise state. */
+static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
+{
+	/* All ethernet/IP/TCP headers combined size is TCP header size
+	 * plus offset of TCP header relative to start of packet.
+	 */
+	st->p.header_length = ((tcp_hdr(skb)->doff << 2u)
+			       + PTR_DIFF(tcp_hdr(skb), skb->data));
+	st->p.full_packet_size = (st->p.header_length
+				  + skb_shinfo(skb)->gso_size);
+
+	st->p.ipv4_id = ntohs(ip_hdr(skb)->id);
+	st->seqnum = ntohl(tcp_hdr(skb)->seq);
+
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
+
+	st->packet_space = st->p.full_packet_size;
+	st->remaining_len = skb->len - st->p.header_length;
+}
+
+
+/**
+ * tso_get_fragment - record fragment details and map for DMA
+ * @st:			TSO state
+ * @efx:		Efx NIC
+ * @data:		Pointer to fragment data
+ * @len:		Length of fragment
+ *
+ * Record fragment details and map for DMA.  Return 0 on success, or
+ * -%ENOMEM if DMA mapping fails.
+ */
+static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
+				   int len, struct page *page, int page_off)
+{
+
+	st->ifc.unmap_addr = pci_map_page(efx->pci_dev, page, page_off,
+					  len, PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(st->ifc.unmap_addr))) {
+		st->ifc.unmap_len = len;
+		st->ifc.len = len;
+		st->ifc.dma_addr = st->ifc.unmap_addr;
+		st->ifc.page = page;
+		st->ifc.page_off = page_off;
+		return 0;
+	}
+	return -ENOMEM;
+}
+
+
+/**
+ * tso_fill_packet_with_fragment - form descriptors for the current fragment
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @st:			TSO state
+ *
+ * Form descriptors for the current fragment, until we reach the end
+ * of fragment or end-of-packet.  Return 0 on success, 1 if not enough
+ * space in @tx_queue.
+ */
+static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
+						const struct sk_buff *skb,
+						struct tso_state *st)
+{
+
+	int n, end_of_packet, rc;
+
+	if (st->ifc.len == 0)
+		return 0;
+	if (st->packet_space == 0)
+		return 0;
+
+	EFX_BUG_ON_PARANOID(st->ifc.len <= 0);
+	EFX_BUG_ON_PARANOID(st->packet_space <= 0);
+
+	n = min(st->ifc.len, st->packet_space);
+
+	st->packet_space -= n;
+	st->remaining_len -= n;
+	st->ifc.len -= n;
+	st->ifc.page_off += n;
+	end_of_packet = st->remaining_len == 0 || st->packet_space == 0;
+
+	rc = efx_tx_queue_insert(tx_queue, st->ifc.dma_addr, n,
+				 st->remaining_len ? NULL : skb,
+				 end_of_packet, st->ifc.unmap_addr,
+				 st->ifc.len ? 0 : st->ifc.unmap_len);
+
+	st->ifc.dma_addr += n;
+
+	return rc;
+}
+
+
+/**
+ * tso_start_new_packet - generate a new header and prepare for the new packet
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @st:			TSO state
+ *
+ * Generate a new header and prepare for the new packet.  Return 0 on
+ * success, or -1 if failed to alloc header.
+ */
+static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
+				       const struct sk_buff *skb,
+				       struct tso_state *st)
+{
+	struct efx_tso_header *tsoh;
+	struct iphdr *tsoh_iph;
+	struct tcphdr *tsoh_th;
+	unsigned ip_length;
+	u8 *header;
+
+	/* Allocate a DMA-mapped header buffer. */
+	if (likely(TSOH_SIZE(st->p.header_length) <= TSOH_STD_SIZE)) {
+		if (tx_queue->tso_headers_free == NULL)
+			if (efx_tsoh_block_alloc(tx_queue))
+				return -1;
+		EFX_BUG_ON_PARANOID(!tx_queue->tso_headers_free);
+		tsoh = tx_queue->tso_headers_free;
+		tx_queue->tso_headers_free = tsoh->next;
+		tsoh->unmap_len = 0;
+	} else {
+		tx_queue->tso_long_headers++;
+		tsoh = efx_tsoh_heap_alloc(tx_queue, st->p.header_length);
+		if (unlikely(!tsoh))
+			return -1;
+	}
+
+	header = TSOH_BUFFER(tsoh);
+	tsoh_th = (struct tcphdr *)(header + SKB_TCP_OFF(skb));
+	tsoh_iph = (struct iphdr *)(header + SKB_IPV4_OFF(skb));
+
+	/* Copy and update the headers. */
+	memcpy(header, skb->data, st->p.header_length);
+
+	tsoh_th->seq = htonl(st->seqnum);
+	st->seqnum += skb_shinfo(skb)->gso_size;
+	if (st->remaining_len > skb_shinfo(skb)->gso_size) {
+		/* This packet will not finish the TSO burst. */
+		ip_length = st->p.full_packet_size - ETH_HDR_LEN(skb);
+		tsoh_th->fin = 0;
+		tsoh_th->psh = 0;
+	} else {
+		/* This packet will be the last in the TSO burst. */
+		ip_length = (st->p.header_length - ETH_HDR_LEN(skb)
+			     + st->remaining_len);
+		tsoh_th->fin = tcp_hdr(skb)->fin;
+		tsoh_th->psh = tcp_hdr(skb)->psh;
+	}
+	tsoh_iph->tot_len = htons(ip_length);
+
+	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
+	tsoh_iph->id = htons(st->p.ipv4_id);
+	st->p.ipv4_id++;
+
+	st->packet_space = skb_shinfo(skb)->gso_size;
+	++tx_queue->tso_packets;
+
+	/* Form a descriptor for this header. */
+	efx_tso_put_header(tx_queue, tsoh, st->p.header_length);
+
+	return 0;
+}
+
+
+/**
+ * efx_enqueue_skb_tso - segment and transmit a TSO socket buffer
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ *
+ * Context: You must hold netif_tx_lock() to call this function.
+ *
+ * Add socket buffer @skb to @tx_queue, doing TSO or return != 0 if
+ * @skb was not enqueued.  In all cases @skb is consumed.  Return
+ * %NETDEV_TX_OK or %NETDEV_TX_BUSY.
+ */
+static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
+			       const struct sk_buff *skb)
+{
+	int frag_i, rc, rc2 = NETDEV_TX_OK;
+	struct tso_state state;
+	skb_frag_t *f;
+
+	/* Verify TSO is safe - these checks should never fail. */
+	efx_tso_check_safe(skb);
+
+	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
+
+	tso_start(&state, skb);
+
+	/* Assume that skb header area contains exactly the headers, and
+	 * all payload is in the frag list.
+	 */
+	if (skb_headlen(skb) == state.p.header_length) {
+		/* Grab the first payload fragment. */
+		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
+		frag_i = 0;
+		f = &skb_shinfo(skb)->frags[frag_i];
+		rc = tso_get_fragment(&state, tx_queue->efx,
+				      f->size, f->page, f->page_offset);
+		if (rc)
+			goto mem_err;
+	} else {
+		/* It may look like this code fragment assumes that the
+		 * skb->data portion does not cross a page boundary, but
+		 * that is not the case.  It is guaranteed to be direct
+		 * mapped memory, and therefore is physically contiguous,
+		 * and so DMA will work fine.  kmap_atomic() on this region
+		 * will just return the direct mapping, so that will work
+		 * too.
+		 */
+		int page_off = (unsigned long)skb->data & (PAGE_SIZE - 1);
+		int hl = state.p.header_length;
+		rc = tso_get_fragment(&state, tx_queue->efx,
+				      skb_headlen(skb) - hl,
+				      virt_to_page(skb->data), page_off + hl);
+		if (rc)
+			goto mem_err;
+		frag_i = -1;
+	}
+
+	if (tso_start_new_packet(tx_queue, skb, &state) < 0)
+		goto mem_err;
+
+	while (1) {
+		rc = tso_fill_packet_with_fragment(tx_queue, skb, &state);
+		if (unlikely(rc))
+			goto stop;
+
+		/* Move onto the next fragment? */
+		if (state.ifc.len == 0) {
+			if (++frag_i >= skb_shinfo(skb)->nr_frags)
+				/* End of payload reached. */
+				break;
+			f = &skb_shinfo(skb)->frags[frag_i];
+			rc = tso_get_fragment(&state, tx_queue->efx,
+					      f->size, f->page, f->page_offset);
+			if (rc)
+				goto mem_err;
+		}
+
+		/* Start at new packet? */
+		if (state.packet_space == 0 &&
+		    tso_start_new_packet(tx_queue, skb, &state) < 0)
+			goto mem_err;
+	}
+
+	/* Pass off to hardware */
+	falcon_push_buffers(tx_queue);
+
+	tx_queue->tso_bursts++;
+	return NETDEV_TX_OK;
+
+ mem_err:
+	EFX_ERR(tx_queue->efx, "Out of memory for TSO headers, or PCI mapping"
+		" error\n");
+	dev_kfree_skb_any((struct sk_buff *)skb);
+	goto unwind;
+
+ stop:
+	rc2 = NETDEV_TX_BUSY;
+
+	/* Stop the queue if it wasn't stopped before. */
+	if (tx_queue->stopped == 1)
+		efx_stop_queue(tx_queue->efx);
+
+ unwind:
+	efx_enqueue_unwind(tx_queue);
+	return rc2;
+}
+
+
+/*
+ * Free up all TSO datastructures associated with tx_queue. This
+ * routine should be called only once the tx_queue is both empty and
+ * will no longer be used.
+ */
+static void efx_fini_tso(struct efx_tx_queue *tx_queue)
+{
+	unsigned i;
+
+	if (tx_queue->buffer)
+		for (i = 0; i <= tx_queue->efx->type->txd_ring_mask; ++i)
+			efx_tsoh_free(tx_queue, &tx_queue->buffer[i]);
+
+	while (tx_queue->tso_headers_free != NULL)
+		efx_tsoh_block_free(tx_queue, tx_queue->tso_headers_free,
+				    tx_queue->efx->pci_dev);
+}
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 66dd5bf..3b9f9dd 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -24,6 +24,10 @@
 			   MDIO_MMDREG_DEVS0_PMAPMD |	\
 			   MDIO_MMDREG_DEVS0_PHYXS)
 
+#define XFP_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
+		       (1 << LOOPBACK_PMAPMD) |		\
+		       (1 << LOOPBACK_NETWORK))
+
 /****************************************************************************/
 /* Quake-specific MDIO registers */
 #define MDIO_QUAKE_LED0_REG	(0xD006)
@@ -35,6 +39,10 @@ void xfp_set_led(struct efx_nic *p, int led, int mode)
 			    mode);
 }
 
+struct xfp_phy_data {
+	int tx_disabled;
+};
+
 #define XFP_MAX_RESET_TIME 500
 #define XFP_RESET_WAIT 10
 
@@ -72,18 +80,31 @@ static int xfp_reset_phy(struct efx_nic *efx)
 
 static int xfp_phy_init(struct efx_nic *efx)
 {
+	struct xfp_phy_data *phy_data;
 	u32 devid = mdio_clause45_read_id(efx, MDIO_MMD_PHYXS);
 	int rc;
 
+	phy_data = kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
+	efx->phy_data = (void *) phy_data;
+
 	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"
 		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
 		 MDIO_ID_REV(devid));
 
+	phy_data->tx_disabled = efx->tx_disabled;
+
 	rc = xfp_reset_phy(efx);
 
 	EFX_INFO(efx, "XFP: PHY init %s.\n",
 		 rc ? "failed" : "successful");
+	if (rc < 0)
+		goto fail;
 
+	return 0;
+
+ fail:
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
 	return rc;
 }
 
@@ -110,6 +131,16 @@ static int xfp_phy_check_hw(struct efx_nic *efx)
 
 static void xfp_phy_reconfigure(struct efx_nic *efx)
 {
+	struct xfp_phy_data *phy_data = efx->phy_data;
+
+	/* Reset the PHY when moving from tx off to tx on */
+	if (phy_data->tx_disabled && !efx->tx_disabled)
+		xfp_reset_phy(efx);
+
+	mdio_clause45_transmit_disable(efx);
+	mdio_clause45_phy_reconfigure(efx);
+
+	phy_data->tx_disabled = efx->tx_disabled;
 	efx->link_up = xfp_link_ok(efx);
 	efx->link_options = GM_LPA_10000FULL;
 }
@@ -119,6 +150,10 @@ static void xfp_phy_fini(struct efx_nic *efx)
 {
 	/* Clobber the LED if it was blinking */
 	efx->board_info.blink(efx, 0);
+
+	/* Free the context block */
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
 }
 
 struct efx_phy_operations falcon_xfp_phy_ops = {
@@ -129,4 +164,5 @@ struct efx_phy_operations falcon_xfp_phy_ops = {
 	.clear_interrupt = xfp_phy_clear_interrupt,
 	.reset_xaui      = efx_port_dummy_op_void,
 	.mmds            = XFP_REQUIRED_DEVS,
+	.loopbacks       = XFP_LOOPBACKS,
 };
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 7bb3ba9..c0a5eea 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1966,13 +1966,13 @@ struct sky2_status_le {
 struct tx_ring_info {
 	struct sk_buff	*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	DECLARE_PCI_UNMAP_ADDR(maplen);
+	DECLARE_PCI_UNMAP_LEN(maplen);
 };
 
 struct rx_ring_info {
 	struct sk_buff	*skb;
 	dma_addr_t	data_addr;
-	DECLARE_PCI_UNMAP_ADDR(data_size);
+	DECLARE_PCI_UNMAP_LEN(data_size);
 	dma_addr_t	frag_addr[ETH_JUMBO_MTU >> PAGE_SHIFT];
 };
 
