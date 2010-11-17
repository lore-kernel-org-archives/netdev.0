From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next pull-request] Intel Wired LAN Driver Updates
Date: Tue, 16 Nov 2010 20:59:49 -0800
Message-ID: <1289969989.2815.10.camel@jtkirshe-MOBL1>
Reply-To: Jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42218 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759598Ab0KQFAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 00:00:02 -0500
Received: by iwn35 with SMTP id 35so1685314iwn.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 21:00:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a batch of fixes/cleanups intended for 2.6.38.  In the mix is added
support for x540 10GbE MAC.  A large part of the changes are ixgbe cleanup
patches by Alex.

Please let me know if there are problems.

Cheers,
Jeff

The following changes since commit b178bb3dfc30d9555bdd2401e95af98e23e83e10:

 net: reorder struct sock fields

are available in the git repository at:

 master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master

Alexander Duyck (29):
  ixgbe: remove unnecessary re-init of adapter on Rx-csum change
  ixgbe: move GSO segments and byte count processing into ixgbe_tx_map
  ixgbe: cleanup ixgbe_alloc_rx_buffers
  ixgbe: drop ring->head, make ring->tail a pointer instead of offset
  ixgbe: move device pointer into the ring structure
  ixgbe: combine some stats into a union to allow for Tx/Rx stats
    overlap
  ixgbe: add a netdev pointer to the ring structure
  ixgbe: move ixgbe_clear_interrupt_scheme to before pci_save_state
  ixgbe: remove residual code left over from earlier combining of
    TXDCTL
  ixgbe: move adapter into pci_dev driver data instead of netdev
  ixgbe: move CPU variable from ring into q_vector, add ring->q_vector
  ixgbe: add a state flags to ring
  ixgbe: cleanup race conditions in link setup
  ixgbe: Disable RSC when ITR setting is too high to allow RSC
  ixgbe: reorder Tx cleanup so that if adapter will reset we don't
    rearm
  ixgbe: change vector numbering so that queues end up on correct CPUs
  ixgbe: cleanup ixgbe_clean_rx_irq
  ixgbe: cleanup ATR filter setup function
  ixgbe: cleanup use of ixgbe_rsc_count and RSC_CB
  ixgbe: change mac_type if statements to switch statements
  ixgbe: cleanup ixgbe_set_tx_csum ethtool flags configuration
  ixgbe: add WOL support for backplane adapters
  ixgbe: Cleanup DCB logic, whitespace, and comments in ixgbe_ethtool.c
  ixgbe: cleanup unnecessary return value in ixgbe_cache_ring_rss
  ixgbe: cleanup unclear references to reg_idx
  ixgbe: simplify math and improve stack use of ixgbe_set_itr functions
  ixgbe: cleanup ixgbe_map_rings_to_vectors
  ixgbe: populate the ring->q_vector pointer during ring mapping
  ixgbe: Resolve null function pointer accesses on 82598 w/ multi-speed
    fiber

Bruce Allan (2):
  e1000e: 82571 SerDes link handle null code word from partner
  e1000e: 82574 intermittently fails to initialize with manageability
    f/w

Don Skidmore (3):
  ixgbe: make silicon specific functions generic
  ixgbe: add MAC and PHY support for x540
  ixgbe: add support for x540 MAC

Dongdong Deng (1):
  e1000e: add netpoll support for MSI/MSI-X IRQ modes

Eric Dumazet (2):
  ixgbe: delay rx_ring freeing
  ixgbe: refactor ixgbe_alloc_queues()

Greg Rose (4):
  ixgbevf: Update Version String and Copyright Notice
  ixgbevf: Fix Oops
  igbvf: Update version and Copyright
  Remove extra struct page member from the buffer info structure

John Fastabend (3):
  ixgbe: DCB set PFC high and low water marks per data sheet specs
  ixgbe: DCB: credit max only needs to be gt TSO size for 82598
  ixgbe: rework Tx hang detection to fix reoccurring false Tx hangs

Julian Stecklina (1):
  igbvf: Remove some dead code in igbvf

Yi Zou (3):
  ixgbe: avoid doing FCoE DDP when adapter is DOWN or RESETTING
  ixgbe: invalidate FCoE DDP context when no error status is available
  ixgbe: make sure FCoE DDP user buffers are really released by the HW

 drivers/net/e1000e/82571.c          |  143 +++-
 drivers/net/e1000e/defines.h        |    1 +
 drivers/net/e1000e/netdev.c         |   49 +-
 drivers/net/igbvf/Makefile          |    2 +-
 drivers/net/igbvf/defines.h         |    2 +-
 drivers/net/igbvf/ethtool.c         |    2 +-
 drivers/net/igbvf/igbvf.h           |    3 +-
 drivers/net/igbvf/mbx.c             |    2 +-
 drivers/net/igbvf/mbx.h             |    2 +-
 drivers/net/igbvf/netdev.c          |   11 +-
 drivers/net/igbvf/regs.h            |    2 +-
 drivers/net/igbvf/vf.c              |    2 +-
 drivers/net/igbvf/vf.h              |    2 +-
 drivers/net/ixgbe/Makefile          |    2 +-
 drivers/net/ixgbe/ixgbe.h           |  122 ++-
 drivers/net/ixgbe/ixgbe_82598.c     |   58 +-
 drivers/net/ixgbe/ixgbe_82599.c     |   94 +--
 drivers/net/ixgbe/ixgbe_common.c    |   98 ++-
 drivers/net/ixgbe/ixgbe_common.h    |    5 +-
 drivers/net/ixgbe/ixgbe_dcb.c       |   17 +-
 drivers/net/ixgbe/ixgbe_dcb.h       |    3 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   12 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   12 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |   55 +-
 drivers/net/ixgbe/ixgbe_ethtool.c   |  255 +++--
 drivers/net/ixgbe/ixgbe_fcoe.c      |   15 +-
 drivers/net/ixgbe/ixgbe_main.c      | 1991 ++++++++++++++++++++---------------
 drivers/net/ixgbe/ixgbe_mbx.c       |   40 +-
 drivers/net/ixgbe/ixgbe_mbx.h       |    2 +-
 drivers/net/ixgbe/ixgbe_phy.c       |   52 +
 drivers/net/ixgbe/ixgbe_phy.h       |    5 +
 drivers/net/ixgbe/ixgbe_sriov.c     |    3 +-
 drivers/net/ixgbe/ixgbe_type.h      |   20 +
 drivers/net/ixgbe/ixgbe_x540.c      |  722 +++++++++++++
 drivers/net/ixgbevf/Makefile        |    2 +-
 drivers/net/ixgbevf/defines.h       |    2 +-
 drivers/net/ixgbevf/ixgbevf.h       |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c  |   13 +-
 drivers/net/ixgbevf/mbx.c           |    2 +-
 drivers/net/ixgbevf/mbx.h           |    2 +-
 drivers/net/ixgbevf/regs.h          |    2 +-
 drivers/net/ixgbevf/vf.c            |    2 +-
 drivers/net/ixgbevf/vf.h            |    2 +-
 43 files changed, 2571 insertions(+), 1264 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_x540.c


diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 7236f1a..9333921 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -74,6 +74,9 @@ static bool e1000_check_mng_mode_82574(struct e1000_hw *hw);
 static s32 e1000_led_on_82574(struct e1000_hw *hw);
 static void e1000_put_hw_semaphore_82571(struct e1000_hw *hw);
 static void e1000_power_down_phy_copper_82571(struct e1000_hw *hw);
+static void e1000_put_hw_semaphore_82573(struct e1000_hw *hw);
+static s32 e1000_get_hw_semaphore_82574(struct e1000_hw *hw);
+static void e1000_put_hw_semaphore_82574(struct e1000_hw *hw);
 
 /**
  *  e1000_init_phy_params_82571 - Init PHY func ptrs.
@@ -107,6 +110,8 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 	case e1000_82574:
 	case e1000_82583:
 		phy->type		 = e1000_phy_bm;
+		phy->ops.acquire = e1000_get_hw_semaphore_82574;
+		phy->ops.release = e1000_put_hw_semaphore_82574;
 		break;
 	default:
 		return -E1000_ERR_PHY;
@@ -200,6 +205,17 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		break;
 	}
 
+	/* Function Pointers */
+	switch (hw->mac.type) {
+	case e1000_82574:
+	case e1000_82583:
+		nvm->ops.acquire = e1000_get_hw_semaphore_82574;
+		nvm->ops.release = e1000_put_hw_semaphore_82574;
+		break;
+	default:
+		break;
+	}
+
 	return 0;
 }
 
@@ -542,6 +558,94 @@ static void e1000_put_hw_semaphore_82571(struct e1000_hw *hw)
 	swsm &= ~(E1000_SWSM_SMBI | E1000_SWSM_SWESMBI);
 	ew32(SWSM, swsm);
 }
+/**
+ *  e1000_get_hw_semaphore_82573 - Acquire hardware semaphore
+ *  @hw: pointer to the HW structure
+ *
+ *  Acquire the HW semaphore during reset.
+ *
+ **/
+static s32 e1000_get_hw_semaphore_82573(struct e1000_hw *hw)
+{
+	u32 extcnf_ctrl;
+	s32 ret_val = 0;
+	s32 i = 0;
+
+	extcnf_ctrl = er32(EXTCNF_CTRL);
+	extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
+	do {
+		ew32(EXTCNF_CTRL, extcnf_ctrl);
+		extcnf_ctrl = er32(EXTCNF_CTRL);
+
+		if (extcnf_ctrl & E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP)
+			break;
+
+		extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
+
+		msleep(2);
+		i++;
+	} while (i < MDIO_OWNERSHIP_TIMEOUT);
+
+	if (i == MDIO_OWNERSHIP_TIMEOUT) {
+		/* Release semaphores */
+		e1000_put_hw_semaphore_82573(hw);
+		e_dbg("Driver can't access the PHY\n");
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_put_hw_semaphore_82573 - Release hardware semaphore
+ *  @hw: pointer to the HW structure
+ *
+ *  Release hardware semaphore used during reset.
+ *
+ **/
+static void e1000_put_hw_semaphore_82573(struct e1000_hw *hw)
+{
+	u32 extcnf_ctrl;
+
+	extcnf_ctrl = er32(EXTCNF_CTRL);
+	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
+	ew32(EXTCNF_CTRL, extcnf_ctrl);
+}
+
+static DEFINE_MUTEX(swflag_mutex);
+
+/**
+ *  e1000_get_hw_semaphore_82574 - Acquire hardware semaphore
+ *  @hw: pointer to the HW structure
+ *
+ *  Acquire the HW semaphore to access the PHY or NVM.
+ *
+ **/
+static s32 e1000_get_hw_semaphore_82574(struct e1000_hw *hw)
+{
+	s32 ret_val;
+
+	mutex_lock(&swflag_mutex);
+	ret_val = e1000_get_hw_semaphore_82573(hw);
+	if (ret_val)
+		mutex_unlock(&swflag_mutex);
+	return ret_val;
+}
+
+/**
+ *  e1000_put_hw_semaphore_82574 - Release hardware semaphore
+ *  @hw: pointer to the HW structure
+ *
+ *  Release hardware semaphore used to access the PHY or NVM
+ *
+ **/
+static void e1000_put_hw_semaphore_82574(struct e1000_hw *hw)
+{
+	e1000_put_hw_semaphore_82573(hw);
+	mutex_unlock(&swflag_mutex);
+}
 
 /**
  *  e1000_acquire_nvm_82571 - Request for access to the EEPROM
@@ -562,8 +666,6 @@ static s32 e1000_acquire_nvm_82571(struct e1000_hw *hw)
 
 	switch (hw->mac.type) {
 	case e1000_82573:
-	case e1000_82574:
-	case e1000_82583:
 		break;
 	default:
 		ret_val = e1000e_acquire_nvm(hw);
@@ -853,9 +955,8 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
  **/
 static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 {
-	u32 ctrl, extcnf_ctrl, ctrl_ext, icr;
+	u32 ctrl, ctrl_ext, icr;
 	s32 ret_val;
-	u16 i = 0;
 
 	/*
 	 * Prevent the PCI-E bus from sticking if there is no TLP connection
@@ -880,33 +981,33 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	 */
 	switch (hw->mac.type) {
 	case e1000_82573:
+		ret_val = e1000_get_hw_semaphore_82573(hw);
+		break;
 	case e1000_82574:
 	case e1000_82583:
-		extcnf_ctrl = er32(EXTCNF_CTRL);
-		extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
-
-		do {
-			ew32(EXTCNF_CTRL, extcnf_ctrl);
-			extcnf_ctrl = er32(EXTCNF_CTRL);
-
-			if (extcnf_ctrl & E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP)
-				break;
-
-			extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
-
-			msleep(2);
-			i++;
-		} while (i < MDIO_OWNERSHIP_TIMEOUT);
+		ret_val = e1000_get_hw_semaphore_82574(hw);
 		break;
 	default:
 		break;
 	}
+	if (ret_val)
+		e_dbg("Cannot acquire MDIO ownership\n");
 
 	ctrl = er32(CTRL);
 
 	e_dbg("Issuing a global reset to MAC\n");
 	ew32(CTRL, ctrl | E1000_CTRL_RST);
 
+	/* Must release MDIO ownership and mutex after MAC reset. */
+	switch (hw->mac.type) {
+	case e1000_82574:
+	case e1000_82583:
+		e1000_put_hw_semaphore_82574(hw);
+		break;
+	default:
+		break;
+	}
+
 	if (hw->nvm.type == e1000_nvm_flash_hw) {
 		udelay(10);
 		ctrl_ext = er32(CTRL_EXT);
@@ -1431,8 +1532,10 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			 * auto-negotiation in the TXCW register and disable
 			 * forced link in the Device Control register in an
 			 * attempt to auto-negotiate with our link partner.
+			 * If the partner code word is null, stop forcing
+			 * and restart auto negotiation.
 			 */
-			if (rxcw & E1000_RXCW_C) {
+			if ((rxcw & E1000_RXCW_C) || !(rxcw & E1000_RXCW_CW))  {
 				/* Enable autoneg, and unforce link up */
 				ew32(TXCW, mac->txcw);
 				ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index d3f7a9c..016ea38 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -516,6 +516,7 @@
 #define E1000_TXCW_ANE        0x80000000        /* Auto-neg enable */
 
 /* Receive Configuration Word */
+#define E1000_RXCW_CW         0x0000ffff        /* RxConfigWord mask */
 #define E1000_RXCW_IV         0x08000000        /* Receive config invalid */
 #define E1000_RXCW_C          0x20000000        /* Receive config */
 #define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a6d54e4..9b3f0a9 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5465,6 +5465,36 @@ static void e1000_shutdown(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
+
+static irqreturn_t e1000_intr_msix(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int vector, msix_irq;
+
+	if (adapter->msix_entries) {
+		vector = 0;
+		msix_irq = adapter->msix_entries[vector].vector;
+		disable_irq(msix_irq);
+		e1000_intr_msix_rx(msix_irq, netdev);
+		enable_irq(msix_irq);
+
+		vector++;
+		msix_irq = adapter->msix_entries[vector].vector;
+		disable_irq(msix_irq);
+		e1000_intr_msix_tx(msix_irq, netdev);
+		enable_irq(msix_irq);
+
+		vector++;
+		msix_irq = adapter->msix_entries[vector].vector;
+		disable_irq(msix_irq);
+		e1000_msix_other(msix_irq, netdev);
+		enable_irq(msix_irq);
+	}
+
+	return IRQ_HANDLED;
+}
+
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
  * without having to re-enable interrupts. It's not called while
@@ -5474,10 +5504,21 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
-	e1000_intr(adapter->pdev->irq, netdev);
-
-	enable_irq(adapter->pdev->irq);
+	switch (adapter->int_mode) {
+	case E1000E_INT_MODE_MSIX:
+		e1000_intr_msix(adapter->pdev->irq, netdev);
+		break;
+	case E1000E_INT_MODE_MSI:
+		disable_irq(adapter->pdev->irq);
+		e1000_intr_msi(adapter->pdev->irq, netdev);
+		enable_irq(adapter->pdev->irq);
+		break;
+	default: /* E1000E_INT_MODE_LEGACY */
+		disable_irq(adapter->pdev->irq);
+		e1000_intr(adapter->pdev->irq, netdev);
+		enable_irq(adapter->pdev->irq);
+		break;
+	}
 }
 #endif
 
diff --git a/drivers/net/igbvf/Makefile b/drivers/net/igbvf/Makefile
index c2f150d..0fa3db3 100644
--- a/drivers/net/igbvf/Makefile
+++ b/drivers/net/igbvf/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel(R) 82576 Virtual Function Linux driver
-# Copyright(c) 2009 Intel Corporation.
+# Copyright(c) 2009 - 2010 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/defines.h b/drivers/net/igbvf/defines.h
index 88a4753..79f2604 100644
--- a/drivers/net/igbvf/defines.h
+++ b/drivers/net/igbvf/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 33add70..abb3606 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index debeee2..9d4d63e 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -126,7 +126,6 @@ struct igbvf_buffer {
 			unsigned int page_offset;
 		};
 	};
-	struct page *page;
 };
 
 union igbvf_desc {
diff --git a/drivers/net/igbvf/mbx.c b/drivers/net/igbvf/mbx.c
index 819a8ec..3d6f4cc 100644
--- a/drivers/net/igbvf/mbx.c
+++ b/drivers/net/igbvf/mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/mbx.h b/drivers/net/igbvf/mbx.h
index 4938609..c2883c4 100644
--- a/drivers/net/igbvf/mbx.h
+++ b/drivers/net/igbvf/mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 28af019..4c998b7 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -44,12 +44,13 @@
 
 #include "igbvf.h"
 
-#define DRV_VERSION "1.0.0-k0"
+#define DRV_VERSION "1.0.8-k0"
 char igbvf_driver_name[] = "igbvf";
 const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
 				"Intel(R) Virtual Function Network Driver";
-static const char igbvf_copyright[] = "Copyright (c) 2009 Intel Corporation.";
+static const char igbvf_copyright[] =
+				"Copyright (c) 2009 - 2010 Intel Corporation.";
 
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
@@ -1851,8 +1852,6 @@ static void igbvf_watchdog_task(struct work_struct *work)
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
-			bool txb2b = 1;
-
 			mac->ops.get_link_up_info(&adapter->hw,
 			                          &adapter->link_speed,
 			                          &adapter->link_duplex);
@@ -1862,11 +1861,9 @@ static void igbvf_watchdog_task(struct work_struct *work)
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				txb2b = 0;
 				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
-				txb2b = 0;
 				/* maybe add some timeout factor ? */
 				break;
 			}
diff --git a/drivers/net/igbvf/regs.h b/drivers/net/igbvf/regs.h
index b9e24ed..77e18d3 100644
--- a/drivers/net/igbvf/regs.h
+++ b/drivers/net/igbvf/regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/vf.c b/drivers/net/igbvf/vf.c
index a9a61ef..0cc13c6 100644
--- a/drivers/net/igbvf/vf.c
+++ b/drivers/net/igbvf/vf.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/igbvf/vf.h b/drivers/net/igbvf/vf.h
index 1e8ce37..c36ea21 100644
--- a/drivers/net/igbvf/vf.h
+++ b/drivers/net/igbvf/vf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) 82576 Virtual Function Linux driver
-  Copyright(c) 2009 Intel Corporation.
+  Copyright(c) 2009 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index 8f81efb..7d7387f 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o
+              ixgbe_mbx.o ixgbe_x540.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ed8703c..3ae30b8 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -61,10 +61,8 @@
 #define IXGBE_MIN_RXD			     64
 
 /* flow control */
-#define IXGBE_DEFAULT_FCRTL		0x10000
 #define IXGBE_MIN_FCRTL			   0x40
 #define IXGBE_MAX_FCRTL			0x7FF80
-#define IXGBE_DEFAULT_FCRTH		0x20000
 #define IXGBE_MIN_FCRTH			  0x600
 #define IXGBE_MAX_FCRTH			0x7FFF0
 #define IXGBE_DEFAULT_FCPAUSE		 0xFFFF
@@ -130,7 +128,9 @@ struct ixgbe_tx_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
-	u16 mapped_as_page;
+	unsigned int bytecount;
+	u16 gso_segs;
+	u8 mapped_as_page;
 };
 
 struct ixgbe_rx_buffer {
@@ -146,12 +146,56 @@ struct ixgbe_queue_stats {
 	u64 bytes;
 };
 
+struct ixgbe_tx_queue_stats {
+	u64 restart_queue;
+	u64 tx_busy;
+	u64 completed;
+	u64 tx_done_old;
+};
+
+struct ixgbe_rx_queue_stats {
+	u64 rsc_count;
+	u64 rsc_flush;
+	u64 non_eop_descs;
+	u64 alloc_rx_page_failed;
+	u64 alloc_rx_buff_failed;
+};
+
+enum ixbge_ring_state_t {
+	__IXGBE_TX_FDIR_INIT_DONE,
+	__IXGBE_TX_DETECT_HANG,
+	__IXGBE_HANG_CHECK_ARMED,
+	__IXGBE_RX_PS_ENABLED,
+	__IXGBE_RX_RSC_ENABLED,
+};
+
+#define ring_is_ps_enabled(ring) \
+	test_bit(__IXGBE_RX_PS_ENABLED, &(ring)->state)
+#define set_ring_ps_enabled(ring) \
+	set_bit(__IXGBE_RX_PS_ENABLED, &(ring)->state)
+#define clear_ring_ps_enabled(ring) \
+	clear_bit(__IXGBE_RX_PS_ENABLED, &(ring)->state)
+#define check_for_tx_hang(ring) \
+	test_bit(__IXGBE_TX_DETECT_HANG, &(ring)->state)
+#define set_check_for_tx_hang(ring) \
+	set_bit(__IXGBE_TX_DETECT_HANG, &(ring)->state)
+#define clear_check_for_tx_hang(ring) \
+	clear_bit(__IXGBE_TX_DETECT_HANG, &(ring)->state)
+#define ring_is_rsc_enabled(ring) \
+	test_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
+#define set_ring_rsc_enabled(ring) \
+	set_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
+#define clear_ring_rsc_enabled(ring) \
+	clear_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
 struct ixgbe_ring {
 	void *desc;			/* descriptor ring memory */
+	struct device *dev;             /* device for DMA mapping */
+	struct net_device *netdev;      /* netdev ring belongs to */
 	union {
 		struct ixgbe_tx_buffer *tx_buffer_info;
 		struct ixgbe_rx_buffer *rx_buffer_info;
 	};
+	unsigned long state;
 	u8 atr_sample_rate;
 	u8 atr_count;
 	u16 count;			/* amount of descriptors */
@@ -160,38 +204,30 @@ struct ixgbe_ring {
 	u16 next_to_clean;
 
 	u8 queue_index; /* needed for multiqueue queue management */
-
-#define IXGBE_RING_RX_PS_ENABLED                (u8)(1)
-	u8 flags;			/* per ring feature flags */
-	u16 head;
-	u16 tail;
-
-	unsigned int total_bytes;
-	unsigned int total_packets;
-
-#ifdef CONFIG_IXGBE_DCA
-	/* cpu for tx queue */
-	int cpu;
-#endif
-
-	u16 work_limit;			/* max work per interrupt */
-	u16 reg_idx;			/* holds the special value that gets
+	u8 reg_idx;			/* holds the special value that gets
 					 * the hardware register offset
 					 * associated with this ring, which is
 					 * different for DCB and RSS modes
 					 */
 
+	u16 work_limit;			/* max work per interrupt */
+
+	u8 __iomem *tail;
+
+	unsigned int total_bytes;
+	unsigned int total_packets;
+
 	struct ixgbe_queue_stats stats;
 	struct u64_stats_sync syncp;
+	union {
+		struct ixgbe_tx_queue_stats tx_stats;
+		struct ixgbe_rx_queue_stats rx_stats;
+	};
 	int numa_node;
-	unsigned long reinit_state;
-	u64 rsc_count;			/* stat for coalesced packets */
-	u64 rsc_flush;			/* stats for flushed packets */
-	u32 restart_queue;		/* track tx queue restarts */
-	u32 non_eop_descs;		/* track hardware descriptor chaining */
-
 	unsigned int size;		/* length in bytes */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
+	struct rcu_head rcu;
+	struct ixgbe_q_vector *q_vector; /* back-pointer to host q_vector */
 } ____cacheline_internodealigned_in_smp;
 
 enum ixgbe_ring_f_enum {
@@ -237,6 +273,9 @@ struct ixgbe_q_vector {
 	unsigned int v_idx; /* index of q_vector within array, also used for
 	                     * finding the bit in EICR and friends that
 	                     * represents the vector for this ring */
+#ifdef CONFIG_IXGBE_DCA
+	int cpu;	    /* CPU for DCA */
+#endif
 	struct napi_struct napi;
 	DECLARE_BITMAP(rxr_idx, MAX_RX_QUEUES); /* Rx ring indices */
 	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
@@ -246,6 +285,7 @@ struct ixgbe_q_vector {
 	u8 rx_itr;
 	u32 eitr;
 	cpumask_var_t affinity_mask;
+	char name[IFNAMSIZ + 9];
 };
 
 /* Helper macros to switch between ints/sec and what the register uses.
@@ -294,7 +334,6 @@ struct ixgbe_adapter {
 	u16 bd_number;
 	struct work_struct reset_task;
 	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
-	char name[MAX_MSIX_COUNT][IFNAMSIZ + 9];
 	struct ixgbe_dcb_config dcb_cfg;
 	struct ixgbe_dcb_config temp_dcb_cfg;
 	u8 dcb_set_bitmap;
@@ -417,6 +456,7 @@ struct ixgbe_adapter {
 	int node;
 	struct work_struct check_overtemp_task;
 	u32 interrupt_event;
+	char lsc_int_name[IFNAMSIZ + 9];
 
 	/* SR-IOV */
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
@@ -428,17 +468,25 @@ enum ixbge_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
-	__IXGBE_FDIR_INIT_DONE,
 	__IXGBE_SFP_MODULE_NOT_FOUND
 };
 
+struct ixgbe_rsc_cb {
+	dma_addr_t dma;
+	u16 skb_cnt;
+	bool delay_unmap;
+};
+#define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
+
 enum ixgbe_boards {
 	board_82598,
 	board_82599,
+	board_X540,
 };
 
 extern struct ixgbe_info ixgbe_82598_info;
 extern struct ixgbe_info ixgbe_82599_info;
+extern struct ixgbe_info ixgbe_X540_info;
 #ifdef CONFIG_IXGBE_DCB
 extern const struct dcbnl_rtnl_ops dcbnl_ops;
 extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
@@ -454,26 +502,24 @@ extern void ixgbe_down(struct ixgbe_adapter *adapter);
 extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 extern void ixgbe_reset(struct ixgbe_adapter *adapter);
 extern void ixgbe_set_ethtool_ops(struct net_device *netdev);
-extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
-extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
-extern void ixgbe_free_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
-extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern int ixgbe_setup_rx_resources(struct ixgbe_ring *);
+extern int ixgbe_setup_tx_resources(struct ixgbe_ring *);
+extern void ixgbe_free_rx_resources(struct ixgbe_ring *);
+extern void ixgbe_free_tx_resources(struct ixgbe_ring *);
 extern void ixgbe_configure_rx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
 extern void ixgbe_configure_tx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *,
-					 struct net_device *,
 					 struct ixgbe_adapter *,
 					 struct ixgbe_ring *);
-extern void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *,
+extern void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *,
                                              struct ixgbe_tx_buffer *);
-extern void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
-                                   struct ixgbe_ring *rx_ring,
-                                   int cleaned_count);
+extern void ixgbe_alloc_rx_buffers(struct ixgbe_ring *, u16);
 extern void ixgbe_write_eitr(struct ixgbe_q_vector *);
 extern int ethtool_ioctl(struct ifreq *ifr);
+extern u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 index);
 extern s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw);
 extern s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
@@ -498,6 +544,10 @@ extern s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input,
                                          u16 flex_byte);
 extern s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input,
                                       u8 l4type);
+extern void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
+                                   struct ixgbe_ring *ring);
+extern void ixgbe_clear_rscctl(struct ixgbe_adapter *adapter,
+                               struct ixgbe_ring *ring);
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 9c02d60..d0f1d9d 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -38,9 +38,6 @@
 #define IXGBE_82598_MC_TBL_SIZE  128
 #define IXGBE_82598_VFT_TBL_SIZE 128
 
-static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
-                                             ixgbe_link_speed *speed,
-                                             bool *autoneg);
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
                                          ixgbe_link_speed speed,
                                          bool autoneg,
@@ -156,7 +153,7 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
 	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
 		mac->ops.setup_link = &ixgbe_setup_copper_link_82598;
 		mac->ops.get_link_capabilities =
-		                  &ixgbe_get_copper_link_capabilities_82598;
+			&ixgbe_get_copper_link_capabilities_generic;
 	}
 
 	switch (hw->phy.type) {
@@ -274,37 +271,6 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
 }
 
 /**
- *  ixgbe_get_copper_link_capabilities_82598 - Determines link capabilities
- *  @hw: pointer to hardware structure
- *  @speed: pointer to link speed
- *  @autoneg: boolean auto-negotiation value
- *
- *  Determines the link capabilities by reading the AUTOC register.
- **/
-static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
-						    ixgbe_link_speed *speed,
-						    bool *autoneg)
-{
-	s32 status = IXGBE_ERR_LINK_SETUP;
-	u16 speed_ability;
-
-	*speed = 0;
-	*autoneg = true;
-
-	status = hw->phy.ops.read_reg(hw, MDIO_SPEED, MDIO_MMD_PMAPMD,
-	                              &speed_ability);
-
-	if (status == 0) {
-		if (speed_ability & MDIO_SPEED_10G)
-		    *speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (speed_ability & MDIO_PMA_SPEED_1000)
-		    *speed |= IXGBE_LINK_SPEED_1GB_FULL;
-	}
-
-	return status;
-}
-
-/**
  *  ixgbe_get_media_type_82598 - Determines media type
  *  @hw: pointer to hardware structure
  *
@@ -357,6 +323,7 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	u32 fctrl_reg;
 	u32 rmcs_reg;
 	u32 reg;
+	u32 rx_pba_size;
 	u32 link_speed = 0;
 	bool link_up;
 
@@ -459,16 +426,18 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 
 	/* Set up and enable Rx high/low water mark thresholds, enable XON. */
 	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
-		if (hw->fc.send_xon) {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
-			                (hw->fc.low_water | IXGBE_FCRTL_XONE));
-		} else {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
-			                hw->fc.low_water);
-		}
+		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
+		rx_pba_size >>= IXGBE_RXPBSIZE_SHIFT;
+
+		reg = (rx_pba_size - hw->fc.low_water) << 6;
+		if (hw->fc.send_xon)
+			reg |= IXGBE_FCRTL_XONE;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num), reg);
+
+		reg = (rx_pba_size - hw->fc.high_water) << 10;
+		reg |= IXGBE_FCRTH_FCEN;
 
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num),
-		                (hw->fc.high_water | IXGBE_FCRTH_FCEN));
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num), reg);
 	}
 
 	/* Configure pause time (2 TCs per register) */
@@ -1222,6 +1191,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
 	.init_params		= &ixgbe_init_eeprom_params_generic,
 	.read			= &ixgbe_read_eerd_generic,
+	.calc_checksum          = &ixgbe_calc_eeprom_checksum_generic,
 	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
 	.update_checksum	= &ixgbe_update_eeprom_checksum_generic,
 };
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 0bd8fbb..e34643e 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -56,9 +56,6 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
                                ixgbe_link_speed speed,
                                bool autoneg,
                                bool autoneg_wait_to_complete);
-static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
-                                             ixgbe_link_speed *speed,
-                                             bool *autoneg);
 static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
                                          ixgbe_link_speed speed,
                                          bool autoneg,
@@ -174,7 +171,7 @@ static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
 	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
 		mac->ops.setup_link = &ixgbe_setup_copper_link_82599;
 		mac->ops.get_link_capabilities =
-		                  &ixgbe_get_copper_link_capabilities_82599;
+			&ixgbe_get_copper_link_capabilities_generic;
 	}
 
 	/* Set necessary function pointers based on phy type */
@@ -184,6 +181,10 @@ static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
 		phy->ops.get_firmware_version =
 		             &ixgbe_get_phy_firmware_version_tnx;
 		break;
+	case ixgbe_phy_aq:
+		phy->ops.get_firmware_version =
+			&ixgbe_get_phy_firmware_version_generic;
+		break;
 	default:
 		break;
 	}
@@ -290,37 +291,6 @@ out:
 }
 
 /**
- *  ixgbe_get_copper_link_capabilities_82599 - Determines link capabilities
- *  @hw: pointer to hardware structure
- *  @speed: pointer to link speed
- *  @autoneg: boolean auto-negotiation value
- *
- *  Determines the link capabilities by reading the AUTOC register.
- **/
-static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
-                                                    ixgbe_link_speed *speed,
-                                                    bool *autoneg)
-{
-	s32 status = IXGBE_ERR_LINK_SETUP;
-	u16 speed_ability;
-
-	*speed = 0;
-	*autoneg = true;
-
-	status = hw->phy.ops.read_reg(hw, MDIO_SPEED, MDIO_MMD_PMAPMD,
-	                              &speed_ability);
-
-	if (status == 0) {
-		if (speed_ability & MDIO_SPEED_10G)
-		    *speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (speed_ability & MDIO_PMA_SPEED_1000)
-		    *speed |= IXGBE_LINK_SPEED_1GB_FULL;
-	}
-
-	return status;
-}
-
-/**
  *  ixgbe_get_media_type_82599 - Get media type
  *  @hw: pointer to hardware structure
  *
@@ -332,7 +302,8 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 
 	/* Detect if there is a copper PHY attached. */
 	if (hw->phy.type == ixgbe_phy_cu_unknown ||
-	    hw->phy.type == ixgbe_phy_tn) {
+	    hw->phy.type == ixgbe_phy_tn ||
+	    hw->phy.type == ixgbe_phy_aq) {
 		media_type = ixgbe_media_type_copper;
 		goto out;
 	}
@@ -1924,6 +1895,7 @@ static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 	hw->phy.ops.identify(hw);
 
 	if (hw->phy.type == ixgbe_phy_tn ||
+	    hw->phy.type == ixgbe_phy_aq ||
 	    hw->phy.type == ixgbe_phy_cu_unknown) {
 		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
 				     &ext_ability);
@@ -2125,51 +2097,6 @@ fw_version_out:
 	return status;
 }
 
-/**
- *  ixgbe_get_wwn_prefix_82599 - Get alternative WWNN/WWPN prefix from
- *  the EEPROM
- *  @hw: pointer to hardware structure
- *  @wwnn_prefix: the alternative WWNN prefix
- *  @wwpn_prefix: the alternative WWPN prefix
- *
- *  This function will read the EEPROM from the alternative SAN MAC address
- *  block to check the support for the alternative WWNN/WWPN prefix support.
- **/
-static s32 ixgbe_get_wwn_prefix_82599(struct ixgbe_hw *hw, u16 *wwnn_prefix,
-                                      u16 *wwpn_prefix)
-{
-	u16 offset, caps;
-	u16 alt_san_mac_blk_offset;
-
-	/* clear output first */
-	*wwnn_prefix = 0xFFFF;
-	*wwpn_prefix = 0xFFFF;
-
-	/* check if alternative SAN MAC is supported */
-	hw->eeprom.ops.read(hw, IXGBE_ALT_SAN_MAC_ADDR_BLK_PTR,
-	                    &alt_san_mac_blk_offset);
-
-	if ((alt_san_mac_blk_offset == 0) ||
-	    (alt_san_mac_blk_offset == 0xFFFF))
-		goto wwn_prefix_out;
-
-	/* check capability in alternative san mac address block */
-	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_CAPS_OFFSET;
-	hw->eeprom.ops.read(hw, offset, &caps);
-	if (!(caps & IXGBE_ALT_SAN_MAC_ADDR_CAPS_ALTWWN))
-		goto wwn_prefix_out;
-
-	/* get the corresponding prefix for WWNN/WWPN */
-	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_WWNN_OFFSET;
-	hw->eeprom.ops.read(hw, offset, wwnn_prefix);
-
-	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_WWPN_OFFSET;
-	hw->eeprom.ops.read(hw, offset, wwpn_prefix);
-
-wwn_prefix_out:
-	return 0;
-}
-
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
@@ -2181,7 +2108,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
 	.get_san_mac_addr       = &ixgbe_get_san_mac_addr_generic,
 	.get_device_caps        = &ixgbe_get_device_caps_82599,
-	.get_wwn_prefix         = &ixgbe_get_wwn_prefix_82599,
+	.get_wwn_prefix         = &ixgbe_get_wwn_prefix_generic,
 	.stop_adapter           = &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
 	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
@@ -2214,6 +2141,7 @@ static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
 	.init_params            = &ixgbe_init_eeprom_params_generic,
 	.read                   = &ixgbe_read_eerd_generic,
 	.write                  = &ixgbe_write_eeprom_generic,
+	.calc_checksum          = &ixgbe_calc_eeprom_checksum_generic,
 	.validate_checksum      = &ixgbe_validate_eeprom_checksum_generic,
 	.update_checksum        = &ixgbe_update_eeprom_checksum_generic,
 };
@@ -2240,5 +2168,5 @@ struct ixgbe_info ixgbe_82599_info = {
 	.mac_ops                = &mac_ops_82599,
 	.eeprom_ops             = &eeprom_ops_82599,
 	.phy_ops                = &phy_ops_82599,
-	.mbx_ops                = &mbx_ops_82599,
+	.mbx_ops                = &mbx_ops_generic,
 };
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index e3eca13..5605257 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -45,14 +45,12 @@ static u16 ixgbe_shift_in_eeprom_bits(struct ixgbe_hw *hw, u16 count);
 static void ixgbe_raise_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
 static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
 static void ixgbe_release_eeprom(struct ixgbe_hw *hw);
-static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw);
 
 static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index);
 static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
-static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 
 /**
  *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
@@ -638,7 +636,7 @@ out:
  *  Polls the status bit (bit 1) of the EERD or EEWR to determine when the
  *  read or write is done respectively.
  **/
-static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
+s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
 {
 	u32 i;
 	u32 reg;
@@ -1009,7 +1007,7 @@ static void ixgbe_release_eeprom(struct ixgbe_hw *hw)
  *  ixgbe_calc_eeprom_checksum - Calculates and returns the checksum
  *  @hw: pointer to hardware structure
  **/
-static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
+u16 ixgbe_calc_eeprom_checksum_generic(struct ixgbe_hw *hw)
 {
 	u16 i;
 	u16 j;
@@ -1072,7 +1070,7 @@ s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
 	status = hw->eeprom.ops.read(hw, 0, &checksum);
 
 	if (status == 0) {
-		checksum = ixgbe_calc_eeprom_checksum(hw);
+		checksum = hw->eeprom.ops.calc_checksum(hw);
 
 		hw->eeprom.ops.read(hw, IXGBE_EEPROM_CHECKSUM, &read_checksum);
 
@@ -1110,7 +1108,7 @@ s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw)
 	status = hw->eeprom.ops.read(hw, 0, &checksum);
 
 	if (status == 0) {
-		checksum = ixgbe_calc_eeprom_checksum(hw);
+		checksum = hw->eeprom.ops.calc_checksum(hw);
 		status = hw->eeprom.ops.write(hw, IXGBE_EEPROM_CHECKSUM,
 		                            checksum);
 	} else {
@@ -1595,6 +1593,7 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	u32 mflcn_reg, fccfg_reg;
 	u32 reg;
 	u32 rx_pba_size;
+	u32 fcrtl, fcrth;
 
 #ifdef CONFIG_DCB
 	if (hw->fc.requested_mode == ixgbe_fc_pfc)
@@ -1671,41 +1670,21 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
 
-	reg = IXGBE_READ_REG(hw, IXGBE_MTQC);
-	/* Thresholds are different for link flow control when in DCB mode */
-	if (reg & IXGBE_MTQC_RT_ENA) {
-		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
+	rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
+	rx_pba_size >>= IXGBE_RXPBSIZE_SHIFT;
 
-		/* Always disable XON for LFC when in DCB mode */
-		reg = (rx_pba_size >> 5) & 0xFFE0;
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num), reg);
+	fcrth = (rx_pba_size - hw->fc.high_water) << 10;
+	fcrtl = (rx_pba_size - hw->fc.low_water) << 10;
 
-		reg = (rx_pba_size >> 2) & 0xFFE0;
-		if (hw->fc.current_mode & ixgbe_fc_tx_pause)
-			reg |= IXGBE_FCRTH_FCEN;
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num), reg);
-	} else {
-		/*
-		 * Set up and enable Rx high/low water mark thresholds,
-		 * enable XON.
-		 */
-		if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
-			if (hw->fc.send_xon) {
-				IXGBE_WRITE_REG(hw,
-				              IXGBE_FCRTL_82599(packetbuf_num),
-			                      (hw->fc.low_water |
-				              IXGBE_FCRTL_XONE));
-			} else {
-				IXGBE_WRITE_REG(hw,
-				              IXGBE_FCRTL_82599(packetbuf_num),
-				              hw->fc.low_water);
-			}
-
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num),
-			               (hw->fc.high_water | IXGBE_FCRTH_FCEN));
-		}
+	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
+		fcrth |= IXGBE_FCRTH_FCEN;
+		if (hw->fc.send_xon)
+			fcrtl |= IXGBE_FCRTL_XONE;
 	}
 
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num), fcrth);
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num), fcrtl);
+
 	/* Configure pause time (2 TCs per register) */
 	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num / 2));
 	if ((packetbuf_num & 1) == 0)
@@ -2705,3 +2684,48 @@ s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 
 	return 0;
 }
+
+/**
+ *  ixgbe_get_wwn_prefix_generic Get alternative WWNN/WWPN prefix from
+ *  the EEPROM
+ *  @hw: pointer to hardware structure
+ *  @wwnn_prefix: the alternative WWNN prefix
+ *  @wwpn_prefix: the alternative WWPN prefix
+ *
+ *  This function will read the EEPROM from the alternative SAN MAC address
+ *  block to check the support for the alternative WWNN/WWPN prefix support.
+ **/
+s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
+                                        u16 *wwpn_prefix)
+{
+	u16 offset, caps;
+	u16 alt_san_mac_blk_offset;
+
+	/* clear output first */
+	*wwnn_prefix = 0xFFFF;
+	*wwpn_prefix = 0xFFFF;
+
+	/* check if alternative SAN MAC is supported */
+	hw->eeprom.ops.read(hw, IXGBE_ALT_SAN_MAC_ADDR_BLK_PTR,
+	                    &alt_san_mac_blk_offset);
+
+	if ((alt_san_mac_blk_offset == 0) ||
+	    (alt_san_mac_blk_offset == 0xFFFF))
+		goto wwn_prefix_out;
+
+	/* check capability in alternative san mac address block */
+	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_CAPS_OFFSET;
+	hw->eeprom.ops.read(hw, offset, &caps);
+	if (!(caps & IXGBE_ALT_SAN_MAC_ADDR_CAPS_ALTWWN))
+		goto wwn_prefix_out;
+
+	/* get the corresponding prefix for WWNN/WWPN */
+	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_WWNN_OFFSET;
+	hw->eeprom.ops.read(hw, offset, wwnn_prefix);
+
+	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_WWPN_OFFSET;
+	hw->eeprom.ops.read(hw, offset, wwpn_prefix);
+
+wwn_prefix_out:
+	return 0;
+}
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 424c223..341ca51 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -49,9 +49,11 @@ s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
 s32 ixgbe_read_eerd_generic(struct ixgbe_hw *hw, u16 offset, u16 *data);
 s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
                                        u16 *data);
+u16 ixgbe_calc_eeprom_checksum_generic(struct ixgbe_hw *hw);
 s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
                                            u16 *checksum_val);
 s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw);
+s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 
 s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
                           u32 enable_addr);
@@ -81,7 +83,8 @@ s32 ixgbe_clear_vfta_generic(struct ixgbe_hw *hw);
 s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw,
                                  ixgbe_link_speed *speed,
                                  bool *link_up, bool link_up_wait_to_complete);
-
+s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
+                                 u16 *wwpn_prefix);
 s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index 0d44c64..d16c260 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -42,7 +42,8 @@
  * It should be called only after the rules are checked by
  * ixgbe_dcb_check_config().
  */
-s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
+s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *hw,
+				   struct ixgbe_dcb_config *dcb_config,
 				   int max_frame, u8 direction)
 {
 	struct tc_bw_alloc *p;
@@ -124,7 +125,8 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
 			 * credit may not be enough to send out a TSO
 			 * packet in descriptor plane arbitration.
 			 */
-			if (credit_max &&
+			if ((hw->mac.type == ixgbe_mac_82598EB) &&
+			    credit_max &&
 			    (credit_max < MINIMUM_CREDIT_FOR_TSO))
 				credit_max = MINIMUM_CREDIT_FOR_TSO;
 
@@ -150,10 +152,17 @@ s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
                         struct ixgbe_dcb_config *dcb_config)
 {
 	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
 		ret = ixgbe_dcb_hw_config_82598(hw, dcb_config);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		ret = ixgbe_dcb_hw_config_82599(hw, dcb_config);
+		break;
+	default:
+		break;
+	}
 	return ret;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 0208a87..1cfe38e 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -150,7 +150,8 @@ struct ixgbe_dcb_config {
 /* DCB driver APIs */
 
 /* DCB credits calculation */
-s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *, int, u8);
+s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *,
+				   struct ixgbe_dcb_config *, int, u8);
 
 /* DCB hw initialization */
 s32 ixgbe_dcb_hw_config(struct ixgbe_hw *, struct ixgbe_dcb_config *);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 50288bc..9a5e89c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -256,21 +256,17 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
 	 * for each traffic class.
 	 */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		if (dcb_config->rx_pba_cfg == pba_equal) {
-			rx_pba_size = IXGBE_RXPBSIZE_64KB;
-		} else {
-			rx_pba_size = (i < 4) ? IXGBE_RXPBSIZE_80KB
-					      : IXGBE_RXPBSIZE_48KB;
-		}
+		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i));
+		rx_pba_size >>= IXGBE_RXPBSIZE_SHIFT;
+		reg = (rx_pba_size - hw->fc.low_water) << 10;
 
-		reg = ((rx_pba_size >> 5) &  0xFFF0);
 		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx ||
 		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full)
 			reg |= IXGBE_FCRTL_XONE;
 
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTL(i), reg);
 
-		reg = ((rx_pba_size >> 2) & 0xFFF0);
+		reg = (rx_pba_size - hw->fc.high_water) << 10;
 		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx ||
 		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full)
 			reg |= IXGBE_FCRTH_FCEN;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 05f2247..374e1f7 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -251,19 +251,17 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
 
 	/* Configure PFC Tx thresholds per TC */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		if (dcb_config->rx_pba_cfg == pba_equal)
-			rx_pba_size = IXGBE_RXPBSIZE_64KB;
-		else
-			rx_pba_size = (i < 4) ? IXGBE_RXPBSIZE_80KB
-			                      : IXGBE_RXPBSIZE_48KB;
+		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i));
+		rx_pba_size >>= IXGBE_RXPBSIZE_SHIFT;
+
+		reg = (rx_pba_size - hw->fc.low_water) << 10;
 
-		reg = ((rx_pba_size >> 5) & 0xFFE0);
 		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
 		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx)
 			reg |= IXGBE_FCRTL_XONE;
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), reg);
 
-		reg = ((rx_pba_size >> 2) & 0xFFE0);
+		reg = (rx_pba_size - hw->fc.high_water) << 10;
 		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
 		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx)
 			reg |= IXGBE_FCRTH_FCEN;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index b53b465..bf566e8 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -130,15 +130,21 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			netdev->netdev_ops->ndo_stop(netdev);
 		ixgbe_clear_interrupt_scheme(adapter);
 
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82598EB:
 			adapter->last_lfc_mode = adapter->hw.fc.current_mode;
 			adapter->hw.fc.requested_mode = ixgbe_fc_none;
-		}
-		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			break;
+		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
 			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+			break;
+		default:
+			break;
 		}
+
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
@@ -155,8 +161,14 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->dcb_cfg.pfc_mode_enable = false;
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
-			if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			switch (adapter->hw.mac.type) {
+			case ixgbe_mac_82599EB:
+			case ixgbe_mac_X540:
 				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+				break;
+			default:
+				break;
+			}
 
 			ixgbe_init_interrupt_scheme(adapter);
 			if (netif_running(netdev))
@@ -178,9 +190,14 @@ static void ixgbe_dcbnl_get_perm_hw_addr(struct net_device *netdev,
 	for (i = 0; i < netdev->addr_len; i++)
 		perm_addr[i] = adapter->hw.mac.perm_addr[i];
 
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		for (j = 0; j < netdev->addr_len; j++, i++)
 			perm_addr[i] = adapter->hw.mac.san_addr[j];
+		break;
+	default:
+		break;
 	}
 }
 
@@ -366,15 +383,29 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	}
 
 	if (adapter->dcb_cfg.pfc_mode_enable) {
-		if ((adapter->hw.mac.type != ixgbe_mac_82598EB) &&
-			(adapter->hw.fc.current_mode != ixgbe_fc_pfc))
-			adapter->last_lfc_mode = adapter->hw.fc.current_mode;
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
+			if (adapter->hw.fc.current_mode != ixgbe_fc_pfc)
+				adapter->last_lfc_mode =
+				                  adapter->hw.fc.current_mode;
+			break;
+		default:
+			break;
+		}
 		adapter->hw.fc.requested_mode = ixgbe_fc_pfc;
 	} else {
-		if (adapter->hw.mac.type != ixgbe_mac_82598EB)
-			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
-		else
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82598EB:
 			adapter->hw.fc.requested_mode = ixgbe_fc_none;
+			break;
+		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
+			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+			break;
+		default:
+			break;
+		}
 	}
 
 	if (adapter->dcb_set_bitmap & BIT_RESETLINK) {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3dc731c..f9b5839 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -185,6 +185,16 @@ static int ixgbe_get_settings(struct net_device *netdev,
 					     ADVERTISED_FIBRE);
 			ecmd->port = PORT_FIBRE;
 			ecmd->autoneg = AUTONEG_DISABLE;
+		} else if ((hw->device_id == IXGBE_DEV_ID_82599_COMBO_BACKPLANE) ||
+			   (hw->device_id == IXGBE_DEV_ID_82599_KX4_MEZZ)) {
+			ecmd->supported |= (SUPPORTED_1000baseT_Full |
+					    SUPPORTED_Autoneg |
+					    SUPPORTED_FIBRE);
+			ecmd->advertising = (ADVERTISED_10000baseT_Full |
+					     ADVERTISED_1000baseT_Full |
+					     ADVERTISED_Autoneg |
+					     ADVERTISED_FIBRE);
+			ecmd->port = PORT_FIBRE;
 		} else {
 			ecmd->supported |= (SUPPORTED_1000baseT_Full |
 					    SUPPORTED_FIBRE);
@@ -204,6 +214,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	/* Get PHY type */
 	switch (adapter->hw.phy.type) {
 	case ixgbe_phy_tn:
+	case ixgbe_phy_aq:
 	case ixgbe_phy_cu_unknown:
 		/* Copper 10G-BASET */
 		ecmd->port = PORT_TP;
@@ -332,13 +343,6 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	else
 		pause->autoneg = 1;
 
-#ifdef CONFIG_DCB
-	if (hw->fc.current_mode == ixgbe_fc_pfc) {
-		pause->rx_pause = 0;
-		pause->tx_pause = 0;
-	}
-
-#endif
 	if (hw->fc.current_mode == ixgbe_fc_rx_pause) {
 		pause->rx_pause = 1;
 	} else if (hw->fc.current_mode == ixgbe_fc_tx_pause) {
@@ -346,6 +350,11 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	} else if (hw->fc.current_mode == ixgbe_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
+#ifdef CONFIG_DCB
+	} else if (hw->fc.current_mode == ixgbe_fc_pfc) {
+		pause->rx_pause = 0;
+		pause->tx_pause = 0;
+#endif
 	}
 }
 
@@ -363,7 +372,6 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 		return -EINVAL;
 
 #endif
-
 	fc = hw->fc;
 
 	if (pause->autoneg != AUTONEG_ENABLE)
@@ -412,11 +420,6 @@ static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
 	else
 		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
 
-	if (netif_running(netdev))
-		ixgbe_reinit_locked(adapter);
-	else
-		ixgbe_reset(adapter);
-
 	return 0;
 }
 
@@ -428,16 +431,21 @@ static u32 ixgbe_get_tx_csum(struct net_device *netdev)
 static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u32 feature_list;
 
-	if (data) {
-		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			netdev->features |= NETIF_F_SCTP_CSUM;
-	} else {
-		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			netdev->features &= ~NETIF_F_SCTP_CSUM;
+	feature_list = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		feature_list |= NETIF_F_SCTP_CSUM;
+		break;
+	default:
+		break;
 	}
+	if (data)
+		netdev->features |= feature_list;
+	else
+		netdev->features &= ~feature_list;
 
 	return 0;
 }
@@ -530,10 +538,20 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[32] = IXGBE_READ_REG(hw, IXGBE_FCTTV(1));
 	regs_buff[33] = IXGBE_READ_REG(hw, IXGBE_FCTTV(2));
 	regs_buff[34] = IXGBE_READ_REG(hw, IXGBE_FCTTV(3));
-	for (i = 0; i < 8; i++)
-		regs_buff[35 + i] = IXGBE_READ_REG(hw, IXGBE_FCRTL(i));
-	for (i = 0; i < 8; i++)
-		regs_buff[43 + i] = IXGBE_READ_REG(hw, IXGBE_FCRTH(i));
+	for (i = 0; i < 8; i++) {
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
+			regs_buff[35 + i] = IXGBE_READ_REG(hw, IXGBE_FCRTL(i));
+			regs_buff[43 + i] = IXGBE_READ_REG(hw, IXGBE_FCRTH(i));
+			break;
+		case ixgbe_mac_82599EB:
+			regs_buff[35 + i] = IXGBE_READ_REG(hw, IXGBE_FCRTL_82599(i));
+			regs_buff[43 + i] = IXGBE_READ_REG(hw, IXGBE_FCRTH_82599(i));
+			break;
+		default:
+			break;
+		}
+	}
 	regs_buff[51] = IXGBE_READ_REG(hw, IXGBE_FCRTV);
 	regs_buff[52] = IXGBE_READ_REG(hw, IXGBE_TFCS);
 
@@ -615,6 +633,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[827] = IXGBE_READ_REG(hw, IXGBE_WUPM);
 	regs_buff[828] = IXGBE_READ_REG(hw, IXGBE_FHFT(0));
 
+	/* DCB */
 	regs_buff[829] = IXGBE_READ_REG(hw, IXGBE_RMCS);
 	regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_DPMCS);
 	regs_buff[831] = IXGBE_READ_REG(hw, IXGBE_PDPMCS);
@@ -905,13 +924,11 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			memcpy(&temp_tx_ring[i], adapter->tx_ring[i],
 			       sizeof(struct ixgbe_ring));
 			temp_tx_ring[i].count = new_tx_count;
-			err = ixgbe_setup_tx_resources(adapter,
-			                               &temp_tx_ring[i]);
+			err = ixgbe_setup_tx_resources(&temp_tx_ring[i]);
 			if (err) {
 				while (i) {
 					i--;
-					ixgbe_free_tx_resources(adapter,
-					                      &temp_tx_ring[i]);
+					ixgbe_free_tx_resources(&temp_tx_ring[i]);
 				}
 				goto clear_reset;
 			}
@@ -930,13 +947,11 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			memcpy(&temp_rx_ring[i], adapter->rx_ring[i],
 			       sizeof(struct ixgbe_ring));
 			temp_rx_ring[i].count = new_rx_count;
-			err = ixgbe_setup_rx_resources(adapter,
-			                               &temp_rx_ring[i]);
+			err = ixgbe_setup_rx_resources(&temp_rx_ring[i]);
 			if (err) {
 				while (i) {
 					i--;
-					ixgbe_free_rx_resources(adapter,
-					                      &temp_rx_ring[i]);
+					ixgbe_free_rx_resources(&temp_rx_ring[i]);
 				}
 				goto err_setup;
 			}
@@ -951,8 +966,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		/* tx */
 		if (new_tx_count != adapter->tx_ring_count) {
 			for (i = 0; i < adapter->num_tx_queues; i++) {
-				ixgbe_free_tx_resources(adapter,
-				                        adapter->tx_ring[i]);
+				ixgbe_free_tx_resources(adapter->tx_ring[i]);
 				memcpy(adapter->tx_ring[i], &temp_tx_ring[i],
 				       sizeof(struct ixgbe_ring));
 			}
@@ -962,8 +976,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		/* rx */
 		if (new_rx_count != adapter->rx_ring_count) {
 			for (i = 0; i < adapter->num_rx_queues; i++) {
-				ixgbe_free_rx_resources(adapter,
-				                        adapter->rx_ring[i]);
+				ixgbe_free_rx_resources(adapter->rx_ring[i]);
 				memcpy(adapter->rx_ring[i], &temp_rx_ring[i],
 				       sizeof(struct ixgbe_ring));
 			}
@@ -1237,12 +1250,20 @@ static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 	u32 value, before, after;
 	u32 i, toggle;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		toggle = 0x7FFFF30F;
-		test = reg_test_82599;
-	} else {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
 		toggle = 0x7FFFF3FF;
 		test = reg_test_82598;
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		toggle = 0x7FFFF30F;
+		test = reg_test_82599;
+		break;
+	default:
+		*data = 1;
+		return 1;
+		break;
 	}
 
 	/*
@@ -1460,16 +1481,21 @@ static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
 	reg_ctl &= ~IXGBE_TXDCTL_ENABLE;
 	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(tx_ring->reg_idx), reg_ctl);
 
-	if (hw->mac.type == ixgbe_mac_82599EB) {
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		reg_ctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
 		reg_ctl &= ~IXGBE_DMATXCTL_TE;
 		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, reg_ctl);
+		break;
+	default:
+		break;
 	}
 
 	ixgbe_reset(adapter);
 
-	ixgbe_free_tx_resources(adapter, &adapter->test_tx_ring);
-	ixgbe_free_rx_resources(adapter, &adapter->test_rx_ring);
+	ixgbe_free_tx_resources(&adapter->test_tx_ring);
+	ixgbe_free_rx_resources(&adapter->test_rx_ring);
 }
 
 static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
@@ -1483,17 +1509,24 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	/* Setup Tx descriptor ring and Tx buffers */
 	tx_ring->count = IXGBE_DEFAULT_TXD;
 	tx_ring->queue_index = 0;
+	tx_ring->dev = &adapter->pdev->dev;
+	tx_ring->netdev = adapter->netdev;
 	tx_ring->reg_idx = adapter->tx_ring[0]->reg_idx;
 	tx_ring->numa_node = adapter->node;
 
-	err = ixgbe_setup_tx_resources(adapter, tx_ring);
+	err = ixgbe_setup_tx_resources(tx_ring);
 	if (err)
 		return 1;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_DMATXCTL);
 		reg_data |= IXGBE_DMATXCTL_TE;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DMATXCTL, reg_data);
+		break;
+	default:
+		break;
 	}
 
 	ixgbe_configure_tx_ring(adapter, tx_ring);
@@ -1501,11 +1534,13 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	/* Setup Rx Descriptor ring and Rx buffers */
 	rx_ring->count = IXGBE_DEFAULT_RXD;
 	rx_ring->queue_index = 0;
+	rx_ring->dev = &adapter->pdev->dev;
+	rx_ring->netdev = adapter->netdev;
 	rx_ring->reg_idx = adapter->rx_ring[0]->reg_idx;
 	rx_ring->rx_buf_len = IXGBE_RXBUFFER_2048;
 	rx_ring->numa_node = adapter->node;
 
-	err = ixgbe_setup_rx_resources(adapter, rx_ring);
+	err = ixgbe_setup_rx_resources(rx_ring);
 	if (err) {
 		ret_val = 4;
 		goto err_nomem;
@@ -1604,8 +1639,7 @@ static int ixgbe_check_lbtest_frame(struct sk_buff *skb,
 	return 13;
 }
 
-static u16 ixgbe_clean_test_rings(struct ixgbe_adapter *adapter,
-                                  struct ixgbe_ring *rx_ring,
+static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
                                   struct ixgbe_ring *tx_ring,
                                   unsigned int size)
 {
@@ -1627,7 +1661,7 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_adapter *adapter,
 		rx_buffer_info = &rx_ring->rx_buffer_info[rx_ntc];
 
 		/* unmap Rx buffer, will be remapped by alloc_rx_buffers */
-		dma_unmap_single(&adapter->pdev->dev,
+		dma_unmap_single(rx_ring->dev,
 		                 rx_buffer_info->dma,
 				 bufsz,
 				 DMA_FROM_DEVICE);
@@ -1639,7 +1673,7 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_adapter *adapter,
 
 		/* unmap buffer on Tx side */
 		tx_buffer_info = &tx_ring->tx_buffer_info[tx_ntc];
-		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 
 		/* increment Rx/Tx next to clean counters */
 		rx_ntc++;
@@ -1655,7 +1689,7 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_adapter *adapter,
 	}
 
 	/* re-map buffers to ring, store next to clean values */
-	ixgbe_alloc_rx_buffers(adapter, rx_ring, count);
+	ixgbe_alloc_rx_buffers(rx_ring, count);
 	rx_ring->next_to_clean = rx_ntc;
 	tx_ring->next_to_clean = tx_ntc;
 
@@ -1699,7 +1733,6 @@ static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
 		for (i = 0; i < 64; i++) {
 			skb_get(skb);
 			tx_ret_val = ixgbe_xmit_frame_ring(skb,
-							   adapter->netdev,
 							   adapter,
 							   tx_ring);
 			if (tx_ret_val == NETDEV_TX_OK)
@@ -1714,8 +1747,7 @@ static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
 		/* allow 200 milliseconds for packets to go from Tx to Rx */
 		msleep(200);
 
-		good_cnt = ixgbe_clean_test_rings(adapter, rx_ring,
-						  tx_ring, size);
+		good_cnt = ixgbe_clean_test_rings(rx_ring, tx_ring, size);
 		if (good_cnt != 64) {
 			ret_val = 13;
 			break;
@@ -1848,6 +1880,13 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 	int retval = 1;
 
 	switch(hw->device_id) {
+	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
+		/* All except this subdevice support WOL */
+		if (hw->subsystem_device_id ==
+		    IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ) {
+			wol->supported = 0;
+			break;
+		}
 	case IXGBE_DEV_ID_82599_KX4:
 		retval = 0;
 		break;
@@ -1985,6 +2024,41 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+/*
+ * this function must be called before setting the new value of
+ * rx_itr_setting
+ */
+static bool ixgbe_update_rsc(struct ixgbe_adapter *adapter,
+			     struct ethtool_coalesce *ec)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
+		return false;
+
+	/* if interrupt rate is too high then disable RSC */
+	if (ec->rx_coalesce_usecs != 1 &&
+	    ec->rx_coalesce_usecs <= 1000000/IXGBE_MAX_RSC_INT_RATE) {
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
+			e_info(probe, "rx-usecs set too low, "
+				      "disabling RSC\n");
+			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
+			return true;
+		}
+	} else {
+		/* check the feature flag value and enable RSC if necessary */
+		if ((netdev->features & NETIF_F_LRO) &&
+		    !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
+			e_info(probe, "rx-usecs set to %d, "
+				      "re-enabling RSC\n",
+			       ec->rx_coalesce_usecs);
+			adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
+			return true;
+		}
+	}
+	return false;
+}
+
 static int ixgbe_set_coalesce(struct net_device *netdev,
                               struct ethtool_coalesce *ec)
 {
@@ -2002,17 +2076,14 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		adapter->tx_ring[0]->work_limit = ec->tx_max_coalesced_frames_irq;
 
 	if (ec->rx_coalesce_usecs > 1) {
-		u32 max_int;
-		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
-			max_int = IXGBE_MAX_RSC_INT_RATE;
-		else
-			max_int = IXGBE_MAX_INT_RATE;
-
 		/* check the limits */
-		if ((1000000/ec->rx_coalesce_usecs > max_int) ||
+		if ((1000000/ec->rx_coalesce_usecs > IXGBE_MAX_INT_RATE) ||
 		    (1000000/ec->rx_coalesce_usecs < IXGBE_MIN_INT_RATE))
 			return -EINVAL;
 
+		/* check the old value and enable RSC if necessary */
+		need_reset = ixgbe_update_rsc(adapter, ec);
+
 		/* store the value in ints/second */
 		adapter->rx_eitr_param = 1000000/ec->rx_coalesce_usecs;
 
@@ -2021,32 +2092,21 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		/* clear the lower bit as its used for dynamic state */
 		adapter->rx_itr_setting &= ~1;
 	} else if (ec->rx_coalesce_usecs == 1) {
+		/* check the old value and enable RSC if necessary */
+		need_reset = ixgbe_update_rsc(adapter, ec);
+
 		/* 1 means dynamic mode */
 		adapter->rx_eitr_param = 20000;
 		adapter->rx_itr_setting = 1;
 	} else {
+		/* check the old value and enable RSC if necessary */
+		need_reset = ixgbe_update_rsc(adapter, ec);
 		/*
 		 * any other value means disable eitr, which is best
 		 * served by setting the interrupt rate very high
 		 */
 		adapter->rx_eitr_param = IXGBE_MAX_INT_RATE;
 		adapter->rx_itr_setting = 0;
-
-		/*
-		 * if hardware RSC is enabled, disable it when
-		 * setting low latency mode, to avoid errata, assuming
-		 * that when the user set low latency mode they want
-		 * it at the cost of anything else
-		 */
-		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
-			if (netdev->features & NETIF_F_LRO) {
-				netdev->features &= ~NETIF_F_LRO;
-				e_info(probe, "rx-usecs set to 0, "
-				       "disabling RSC\n");
-			}
-			need_reset = true;
-		}
 	}
 
 	if (ec->tx_coalesce_usecs > 1) {
@@ -2133,28 +2193,39 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 		return rc;
 
 	/* if state changes we need to update adapter->flags and reset */
-	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) {
-		/*
-		 * cast both to bool and verify if they are set the same
-		 * but only enable RSC if itr is non-zero, as
-		 * itr=0 and RSC are mutually exclusive
-		 */
-		if (((!!(data & ETH_FLAG_LRO)) !=
-		     (!!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) &&
-		    adapter->rx_itr_setting) {
+	if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
+	    (!!(data & ETH_FLAG_LRO) !=
+	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
+		if ((data & ETH_FLAG_LRO) &&
+		    (!adapter->rx_itr_setting ||
+		     (adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE))) {
+			e_info(probe, "rx-usecs set too low, "
+				      "not enabling RSC.\n");
+		} else {
 			adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
 			switch (adapter->hw.mac.type) {
 			case ixgbe_mac_82599EB:
 				need_reset = true;
 				break;
+			case ixgbe_mac_X540: {
+				int i;
+				for (i = 0; i < adapter->num_rx_queues; i++) {
+					struct ixgbe_ring *ring =
+					                  adapter->rx_ring[i];
+					if (adapter->flags2 &
+					    IXGBE_FLAG2_RSC_ENABLED) {
+						ixgbe_configure_rscctl(adapter,
+						                       ring);
+					} else {
+						ixgbe_clear_rscctl(adapter,
+						                   ring);
+					}
+				}
+			}
+				break;
 			default:
 				break;
 			}
-		} else if (!adapter->rx_itr_setting) {
-			netdev->features &= ~NETIF_F_LRO;
-			if (data & ETH_FLAG_LRO)
-				e_info(probe, "rx-usecs set to 0, "
-				       "LRO/RSC cannot be enabled.\n");
 		}
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 05efa6a..6342d48 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -68,7 +68,7 @@ static inline bool ixgbe_rx_is_fcoe(union ixgbe_adv_rx_desc *rx_desc)
 static inline void ixgbe_fcoe_clear_ddp(struct ixgbe_fcoe_ddp *ddp)
 {
 	ddp->len = 0;
-	ddp->err = 0;
+	ddp->err = 1;
 	ddp->udl = NULL;
 	ddp->udp = 0UL;
 	ddp->sgl = NULL;
@@ -92,6 +92,7 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid)
 	struct ixgbe_fcoe *fcoe;
 	struct ixgbe_adapter *adapter;
 	struct ixgbe_fcoe_ddp *ddp;
+	u32 fcbuff;
 
 	if (!netdev)
 		goto out_ddp_put;
@@ -115,7 +116,14 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCBUFF, 0);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCDMARW,
 				(xid | IXGBE_FCDMARW_WE));
+
+		/* guaranteed to be invalidated after 100us */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCDMARW,
+				(xid | IXGBE_FCDMARW_RE));
+		fcbuff = IXGBE_READ_REG(&adapter->hw, IXGBE_FCBUFF);
 		spin_unlock_bh(&fcoe->lock);
+		if (fcbuff & IXGBE_FCBUFF_VALID)
+			udelay(100);
 	}
 	if (ddp->sgl)
 		pci_unmap_sg(adapter->pdev, ddp->sgl, ddp->sgc,
@@ -168,6 +176,11 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 		return 0;
 	}
 
+	/* no DDP if we are already down or resetting */
+	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_RESETTING, &adapter->state))
+		return 0;
+
 	fcoe = &adapter->fcoe;
 	if (!fcoe->pool) {
 		e_warn(drv, "xid=0x%x no ddp pool for fcoe\n", xid);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fbad4d8..5409af3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -59,6 +59,7 @@ static char ixgbe_copyright[] = "Copyright (c) 1999-2010 Intel Corporation.";
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
 	[board_82599] = &ixgbe_82599_info,
+	[board_X540] = &ixgbe_X540_info,
 };
 
 /* ixgbe_pci_tbl - PCI Device ID Table
@@ -112,6 +113,8 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T),
+	 board_82599 },
 
 	/* required last entry */
 	{0, }
@@ -560,6 +563,7 @@ static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, s8 direction,
 		IXGBE_WRITE_REG(hw, IXGBE_IVAR(index), ivar);
 		break;
 	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		if (direction == -1) {
 			/* other causes */
 			msix_vector |= IXGBE_IVAR_ALLOC_VAL;
@@ -589,29 +593,34 @@ static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
 {
 	u32 mask;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
 		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, mask);
-	} else {
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		mask = (qmask & 0xFFFFFFFF);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(0), mask);
 		mask = (qmask >> 32);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(1), mask);
+		break;
+	default:
+		break;
 	}
 }
 
-void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
-				      struct ixgbe_tx_buffer
-				      *tx_buffer_info)
+void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
+				      struct ixgbe_tx_buffer *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
 		if (tx_buffer_info->mapped_as_page)
-			dma_unmap_page(&adapter->pdev->dev,
+			dma_unmap_page(tx_ring->dev,
 				       tx_buffer_info->dma,
 				       tx_buffer_info->length,
 				       DMA_TO_DEVICE);
 		else
-			dma_unmap_single(&adapter->pdev->dev,
+			dma_unmap_single(tx_ring->dev,
 					 tx_buffer_info->dma,
 					 tx_buffer_info->length,
 					 DMA_TO_DEVICE);
@@ -626,92 +635,166 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 }
 
 /**
- * ixgbe_tx_xon_state - check the tx ring xon state
- * @adapter: the ixgbe adapter
- * @tx_ring: the corresponding tx_ring
+ * ixgbe_dcb_txq_to_tc - convert a reg index to a traffic class
+ * @adapter: driver private struct
+ * @index: reg idx of queue to query (0-127)
  *
- * If not in DCB mode, checks TFCS.TXOFF, otherwise, find out the
- * corresponding TC of this tx_ring when checking TFCS.
+ * Helper function to determine the traffic index for a paticular
+ * register index.
  *
- * Returns : true if in xon state (currently not paused)
+ * Returns : a tc index for use in range 0-7, or 0-3
  */
-static inline bool ixgbe_tx_xon_state(struct ixgbe_adapter *adapter,
-				      struct ixgbe_ring *tx_ring)
+u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 {
-	u32 txoff = IXGBE_TFCS_TXOFF;
+	int tc = -1;
+	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
 
-#ifdef CONFIG_IXGBE_DCB
-	if (adapter->dcb_cfg.pfc_mode_enable) {
-		int tc;
-		int reg_idx = tx_ring->reg_idx;
-		int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	/* if DCB is not enabled the queues have no TC */
+	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+		return tc;
+
+	/* check valid range */
+	if (reg_idx >= adapter->hw.mac.max_tx_queues)
+		return tc;
+
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
+		tc = reg_idx >> 2;
+		break;
+	default:
+		if (dcb_i != 4 && dcb_i != 8)
+			break;
+
+		/* if VMDq is enabled the lowest order bits determine TC */
+		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
+				      IXGBE_FLAG_VMDQ_ENABLED)) {
+			tc = reg_idx & (dcb_i - 1);
+			break;
+		}
+
+		/*
+		 * Convert the reg_idx into the correct TC. This bitmask
+		 * targets the last full 32 ring traffic class and assigns
+		 * it a value of 1. From there the rest of the rings are
+		 * based on shifting the mask further up to include the
+		 * reg_idx / 16 and then reg_idx / 8. It assumes dcB_i
+		 * will only ever be 8 or 4 and that reg_idx will never
+		 * be greater then 128. The code without the power of 2
+		 * optimizations would be:
+		 * (((reg_idx % 32) + 32) * dcb_i) >> (9 - reg_idx / 32)
+		 */
+		tc = ((reg_idx & 0X1F) + 0x20) * dcb_i;
+		tc >>= 9 - (reg_idx >> 5);
+	}
+
+	return tc;
+}
 
-		switch (adapter->hw.mac.type) {
+static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_hw_stats *hwstats = &adapter->stats;
+	u32 data = 0;
+	u32 xoff[8] = {0};
+	int i;
+
+	if ((hw->fc.current_mode == ixgbe_fc_full) ||
+	    (hw->fc.current_mode == ixgbe_fc_rx_pause)) {
+		switch (hw->mac.type) {
 		case ixgbe_mac_82598EB:
-			tc = reg_idx >> 2;
-			txoff = IXGBE_TFCS_TXOFF0;
+			data = IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
 			break;
-		case ixgbe_mac_82599EB:
-			tc = 0;
-			txoff = IXGBE_TFCS_TXOFF;
-			if (dcb_i == 8) {
-				/* TC0, TC1 */
-				tc = reg_idx >> 5;
-				if (tc == 2) /* TC2, TC3 */
-					tc += (reg_idx - 64) >> 4;
-				else if (tc == 3) /* TC4, TC5, TC6, TC7 */
-					tc += 1 + ((reg_idx - 96) >> 3);
-			} else if (dcb_i == 4) {
-				/* TC0, TC1 */
-				tc = reg_idx >> 6;
-				if (tc == 1) {
-					tc += (reg_idx - 64) >> 5;
-					if (tc == 2) /* TC2, TC3 */
-						tc += (reg_idx - 96) >> 4;
-				}
-			}
+		default:
+			data = IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
+		}
+		hwstats->lxoffrxc += data;
+
+		/* refill credits (no tx hang) if we received xoff */
+		if (!data)
+			return;
+
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			clear_bit(__IXGBE_HANG_CHECK_ARMED,
+				  &adapter->tx_ring[i]->state);
+		return;
+	} else if (!(adapter->dcb_cfg.pfc_mode_enable))
+		return;
+
+	/* update stats for each tc, only valid with PFC enabled */
+	for (i = 0; i < MAX_TX_PACKET_BUFFERS; i++) {
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
+			xoff[i] = IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
 			break;
 		default:
-			tc = 0;
+			xoff[i] = IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(i));
 		}
-		txoff <<= tc;
+		hwstats->pxoffrxc[i] += xoff[i];
+	}
+
+	/* disarm tx queues that have received xoff frames */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
+		u32 tc = ixgbe_dcb_txq_to_tc(adapter, tx_ring->reg_idx);
+
+		if (xoff[tc])
+			clear_bit(__IXGBE_HANG_CHECK_ARMED, &tx_ring->state);
 	}
-#endif
-	return IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) & txoff;
 }
 
-static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
-				       struct ixgbe_ring *tx_ring,
-				       unsigned int eop)
+static u64 ixgbe_get_tx_completed(struct ixgbe_ring *ring)
 {
+	return ring->tx_stats.completed;
+}
+
+static u64 ixgbe_get_tx_pending(struct ixgbe_ring *ring)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(ring->netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	/* Detect a transmit hang in hardware, this serializes the
-	 * check with the clearing of time_stamp and movement of eop */
-	adapter->detect_tx_hung = false;
-	if (tx_ring->tx_buffer_info[eop].time_stamp &&
-	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ) &&
-	    ixgbe_tx_xon_state(adapter, tx_ring)) {
-		/* detected Tx unit hang */
-		union ixgbe_adv_tx_desc *tx_desc;
-		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
-		e_err(drv, "Detected Tx Unit Hang\n"
-		      "  Tx Queue             <%d>\n"
-		      "  TDH, TDT             <%x>, <%x>\n"
-		      "  next_to_use          <%x>\n"
-		      "  next_to_clean        <%x>\n"
-		      "tx_buffer_info[next_to_clean]\n"
-		      "  time_stamp           <%lx>\n"
-		      "  jiffies              <%lx>\n",
-		      tx_ring->queue_index,
-		      IXGBE_READ_REG(hw, tx_ring->head),
-		      IXGBE_READ_REG(hw, tx_ring->tail),
-		      tx_ring->next_to_use, eop,
-		      tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
-		return true;
+	u32 head = IXGBE_READ_REG(hw, IXGBE_TDH(ring->reg_idx));
+	u32 tail = IXGBE_READ_REG(hw, IXGBE_TDT(ring->reg_idx));
+
+	if (head != tail)
+		return (head < tail) ?
+			tail - head : (tail + ring->count - head);
+
+	return 0;
+}
+
+static inline bool ixgbe_check_tx_hang(struct ixgbe_ring *tx_ring)
+{
+	u32 tx_done = ixgbe_get_tx_completed(tx_ring);
+	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
+	u32 tx_pending = ixgbe_get_tx_pending(tx_ring);
+	bool ret = false;
+
+	clear_check_for_tx_hang(tx_ring);
+
+	/*
+	 * Check for a hung queue, but be thorough. This verifies
+	 * that a transmit has been completed since the previous
+	 * check AND there is at least one packet pending. The
+	 * ARMED bit is set to indicate a potential hang. The
+	 * bit is cleared if a pause frame is received to remove
+	 * false hang detection due to PFC or 802.3x frames. By
+	 * requiring this to fail twice we avoid races with
+	 * pfc clearing the ARMED bit and conditions where we
+	 * run the check_tx_hang logic with a transmit completion
+	 * pending but without time to complete it yet.
+	 */
+	if ((tx_done_old == tx_done) && tx_pending) {
+		/* make sure it is true for two checks in a row */
+		ret = test_and_set_bit(__IXGBE_HANG_CHECK_ARMED,
+				       &tx_ring->state);
+	} else {
+		/* update completed stats and continue */
+		tx_ring->tx_stats.tx_done_old = tx_done;
+		/* reset the countdown */
+		clear_bit(__IXGBE_HANG_CHECK_ARMED, &tx_ring->state);
 	}
 
-	return false;
+	return ret;
 }
 
 #define IXGBE_MAX_TXD_PWR       14
@@ -734,11 +817,10 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct net_device *netdev = adapter->netdev;
 	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned int i, eop, count = 0;
 	unsigned int total_bytes = 0, total_packets = 0;
+	u16 i, eop, count = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->tx_buffer_info[i].next_to_watch;
@@ -749,148 +831,182 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		bool cleaned = false;
 		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
-			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
-			cleaned = (i == eop);
-			skb = tx_buffer_info->skb;
-
-			if (cleaned && skb) {
-				unsigned int segs, bytecount;
-				unsigned int hlen = skb_headlen(skb);
-
-				/* gso_segs is currently only valid for tcp */
-				segs = skb_shinfo(skb)->gso_segs ?: 1;
-#ifdef IXGBE_FCOE
-				/* adjust for FCoE Sequence Offload */
-				if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
-				    && skb_is_gso(skb)
-				    && vlan_get_protocol(skb) ==
-				    htons(ETH_P_FCOE)) {
-					hlen = skb_transport_offset(skb) +
-						sizeof(struct fc_frame_header) +
-						sizeof(struct fcoe_crc_eof);
-					segs = DIV_ROUND_UP(skb->len - hlen,
-						skb_shinfo(skb)->gso_size);
-				}
-#endif /* IXGBE_FCOE */
-				/* multiply data chunks by size of headers */
-				bytecount = ((segs - 1) * hlen) + skb->len;
-				total_packets += segs;
-				total_bytes += bytecount;
-			}
-
-			ixgbe_unmap_and_free_tx_resource(adapter,
-							 tx_buffer_info);
 
 			tx_desc->wb.status = 0;
+			cleaned = (i == eop);
 
 			i++;
 			if (i == tx_ring->count)
 				i = 0;
+
+			if (cleaned && tx_buffer_info->skb) {
+				total_bytes += tx_buffer_info->bytecount;
+				total_packets += tx_buffer_info->gso_segs;
+			}
+
+			ixgbe_unmap_and_free_tx_resource(tx_ring,
+							 tx_buffer_info);
 		}
 
+		tx_ring->tx_stats.completed++;
 		eop = tx_ring->tx_buffer_info[i].next_to_watch;
 		eop_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
 	}
 
 	tx_ring->next_to_clean = i;
+	tx_ring->total_bytes += total_bytes;
+	tx_ring->total_packets += total_packets;
+	u64_stats_update_begin(&tx_ring->syncp);
+	tx_ring->stats.packets += total_packets;
+	tx_ring->stats.bytes += total_bytes;
+	u64_stats_update_end(&tx_ring->syncp);
+
+	if (check_for_tx_hang(tx_ring) && ixgbe_check_tx_hang(tx_ring)) {
+		/* schedule immediate reset if we believe we hung */
+		struct ixgbe_hw *hw = &adapter->hw;
+		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
+		e_err(drv, "Detected Tx Unit Hang\n"
+			"  Tx Queue             <%d>\n"
+			"  TDH, TDT             <%x>, <%x>\n"
+			"  next_to_use          <%x>\n"
+			"  next_to_clean        <%x>\n"
+			"tx_buffer_info[next_to_clean]\n"
+			"  time_stamp           <%lx>\n"
+			"  jiffies              <%lx>\n",
+			tx_ring->queue_index,
+			IXGBE_READ_REG(hw, IXGBE_TDH(tx_ring->reg_idx)),
+			IXGBE_READ_REG(hw, IXGBE_TDT(tx_ring->reg_idx)),
+			tx_ring->next_to_use, eop,
+			tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
+
+		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+
+		e_info(probe,
+		       "tx hang %d detected on queue %d, resetting adapter\n",
+			adapter->tx_timeout_count + 1, tx_ring->queue_index);
+
+		/* schedule immediate reset if we believe we hung */
+		ixgbe_tx_timeout(adapter->netdev);
+
+		/* the adapter is about to reset, no point in enabling stuff */
+		return true;
+	}
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
-	if (unlikely(count && netif_carrier_ok(netdev) &&
+	if (unlikely(count && netif_carrier_ok(tx_ring->netdev) &&
 		     (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
+		if (__netif_subqueue_stopped(tx_ring->netdev, tx_ring->queue_index) &&
 		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
-			netif_wake_subqueue(netdev, tx_ring->queue_index);
-			++tx_ring->restart_queue;
-		}
-	}
-
-	if (adapter->detect_tx_hung) {
-		if (ixgbe_check_tx_hang(adapter, tx_ring, i)) {
-			/* schedule immediate reset if we believe we hung */
-			e_info(probe, "tx hang %d detected, resetting "
-			       "adapter\n", adapter->tx_timeout_count + 1);
-			ixgbe_tx_timeout(adapter->netdev);
+			netif_wake_subqueue(tx_ring->netdev, tx_ring->queue_index);
+			++tx_ring->tx_stats.restart_queue;
 		}
 	}
 
-	/* re-arm the interrupt */
-	if (count >= tx_ring->work_limit)
-		ixgbe_irq_rearm_queues(adapter, ((u64)1 << q_vector->v_idx));
-
-	tx_ring->total_bytes += total_bytes;
-	tx_ring->total_packets += total_packets;
-	u64_stats_update_begin(&tx_ring->syncp);
-	tx_ring->stats.packets += total_packets;
-	tx_ring->stats.bytes += total_bytes;
-	u64_stats_update_end(&tx_ring->syncp);
 	return count < tx_ring->work_limit;
 }
 
 #ifdef CONFIG_IXGBE_DCA
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring)
+				struct ixgbe_ring *rx_ring,
+				int cpu)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
-	int cpu = get_cpu();
-	int q = rx_ring->reg_idx;
-
-	if (rx_ring->cpu != cpu) {
-		rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-			rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
-			rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
-		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-			rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK_82599;
-			rxctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
-				   IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
-		}
-		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
-		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
-		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
-		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
-			    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
-		rx_ring->cpu = cpu;
+	u8 reg_idx = rx_ring->reg_idx;
+
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(reg_idx));
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
+		rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK_82599;
+		rxctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
+			   IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
+		break;
+	default:
+		break;
 	}
-	put_cpu();
+	rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
+	rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
+	rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
+	rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
+		    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+	IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(reg_idx), rxctrl);
 }
 
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring)
+				struct ixgbe_ring *tx_ring,
+				int cpu)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
 	u32 txctrl;
+	u8 reg_idx = tx_ring->reg_idx;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(reg_idx));
+		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
+		txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
+		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(reg_idx), txctrl);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx));
+		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
+		txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
+			   IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
+		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
+		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx), txctrl);
+		break;
+	default:
+		break;
+	}
+}
+
+static void ixgbe_update_dca(struct ixgbe_q_vector *q_vector)
+{
+	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int cpu = get_cpu();
-	int q = tx_ring->reg_idx;
-	struct ixgbe_hw *hw = &adapter->hw;
+	long r_idx;
+	int i;
 
-	if (tx_ring->cpu != cpu) {
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(q));
-			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
-			txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
-			txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(q), txctrl);
-		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(q));
-			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
-			txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
-				  IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
-			txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(q), txctrl);
-		}
-		tx_ring->cpu = cpu;
+	if (q_vector->cpu == cpu)
+		goto out_no_update;
+
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->txr_count; i++) {
+		ixgbe_update_tx_dca(adapter, adapter->tx_ring[r_idx], cpu);
+		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+				      r_idx + 1);
+	}
+
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rxr_count; i++) {
+		ixgbe_update_rx_dca(adapter, adapter->rx_ring[r_idx], cpu);
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+				      r_idx + 1);
 	}
+
+	q_vector->cpu = cpu;
+out_no_update:
 	put_cpu();
 }
 
 static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 {
+	int num_q_vectors;
 	int i;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
@@ -899,22 +1015,25 @@ static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 	/* always use CB2 mode, difference is masked in the CB driver */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i]->cpu = -1;
-		ixgbe_update_tx_dca(adapter, adapter->tx_ring[i]);
-	}
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i]->cpu = -1;
-		ixgbe_update_rx_dca(adapter, adapter->rx_ring[i]);
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	else
+		num_q_vectors = 1;
+
+	for (i = 0; i < num_q_vectors; i++) {
+		adapter->q_vector[i]->cpu = -1;
+		ixgbe_update_dca(adapter->q_vector[i]);
 	}
 }
 
 static int __ixgbe_notify_dca(struct device *dev, void *data)
 {
-	struct net_device *netdev = dev_get_drvdata(dev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = dev_get_drvdata(dev);
 	unsigned long event = *(unsigned long *)data;
 
+	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
+		return 0;
+
 	switch (event) {
 	case DCA_PROVIDER_ADD:
 		/* if we're already enabled, don't do it again */
@@ -1013,8 +1132,7 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
-static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
-					 struct ixgbe_ring *rx_ring, u32 val)
+static inline void ixgbe_release_rx_desc(struct ixgbe_ring *rx_ring, u32 val)
 {
 	/*
 	 * Force memory writes to complete before letting h/w
@@ -1023,72 +1141,81 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
 	 * such as IA-64).
 	 */
 	wmb();
-	IXGBE_WRITE_REG(hw, IXGBE_RDT(rx_ring->reg_idx), val);
+	writel(val, rx_ring->tail);
 }
 
 /**
  * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
- * @adapter: address of board private structure
+ * @rx_ring: ring to place buffers on
+ * @cleaned_count: number of buffers to replace
  **/
-void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
-			    struct ixgbe_ring *rx_ring,
-			    int cleaned_count)
+void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 {
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
-	unsigned int i;
-	unsigned int bufsz = rx_ring->rx_buf_len;
+	struct sk_buff *skb;
+	u16 i = rx_ring->next_to_use;
 
-	i = rx_ring->next_to_use;
-	bi = &rx_ring->rx_buffer_info[i];
+	/* do nothing if no valid netdev defined */
+	if (!rx_ring->netdev)
+		return;
 
 	while (cleaned_count--) {
 		rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
+		bi = &rx_ring->rx_buffer_info[i];
+		skb = bi->skb;
 
-		if (!bi->page_dma &&
-		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
-			if (!bi->page) {
-				bi->page = netdev_alloc_page(netdev);
-				if (!bi->page) {
-					adapter->alloc_rx_page_failed++;
-					goto no_buffers;
-				}
-				bi->page_offset = 0;
-			} else {
-				/* use a half page if we're re-using */
-				bi->page_offset ^= (PAGE_SIZE / 2);
-			}
-
-			bi->page_dma = dma_map_page(&pdev->dev, bi->page,
-						    bi->page_offset,
-						    (PAGE_SIZE / 2),
-						    DMA_FROM_DEVICE);
-		}
-
-		if (!bi->skb) {
-			struct sk_buff *skb = netdev_alloc_skb_ip_align(netdev,
-									bufsz);
-			bi->skb = skb;
-
+		if (!skb) {
+			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+							rx_ring->rx_buf_len);
 			if (!skb) {
-				adapter->alloc_rx_buff_failed++;
+				rx_ring->rx_stats.alloc_rx_buff_failed++;
 				goto no_buffers;
 			}
 			/* initialize queue mapping */
 			skb_record_rx_queue(skb, rx_ring->queue_index);
+			bi->skb = skb;
 		}
 
 		if (!bi->dma) {
-			bi->dma = dma_map_single(&pdev->dev,
-						 bi->skb->data,
+			bi->dma = dma_map_single(rx_ring->dev,
+						 skb->data,
 						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
+			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
+				rx_ring->rx_stats.alloc_rx_buff_failed++;
+				bi->dma = 0;
+				goto no_buffers;
+			}
 		}
-		/* Refresh the desc even if buffer_addrs didn't change because
-		 * each write-back erases this info. */
-		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
+
+		if (ring_is_ps_enabled(rx_ring)) {
+			if (!bi->page) {
+				bi->page = netdev_alloc_page(rx_ring->netdev);
+				if (!bi->page) {
+					rx_ring->rx_stats.alloc_rx_page_failed++;
+					goto no_buffers;
+				}
+			}
+
+			if (!bi->page_dma) {
+				/* use a half page if we're re-using */
+				bi->page_offset ^= PAGE_SIZE / 2;
+				bi->page_dma = dma_map_page(rx_ring->dev,
+							    bi->page,
+							    bi->page_offset,
+							    PAGE_SIZE / 2,
+							    DMA_FROM_DEVICE);
+				if (dma_mapping_error(rx_ring->dev,
+						      bi->page_dma)) {
+					rx_ring->rx_stats.alloc_rx_page_failed++;
+					bi->page_dma = 0;
+					goto no_buffers;
+				}
+			}
+
+			/* Refresh the desc even if buffer_addrs didn't change
+			 * because each write-back erases this info. */
 			rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
 			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
 		} else {
@@ -1099,56 +1226,48 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
-		bi = &rx_ring->rx_buffer_info[i];
 	}
 
 no_buffers:
 	if (rx_ring->next_to_use != i) {
 		rx_ring->next_to_use = i;
-		if (i-- == 0)
-			i = (rx_ring->count - 1);
-
-		ixgbe_release_rx_desc(&adapter->hw, rx_ring, i);
+		ixgbe_release_rx_desc(rx_ring, i);
 	}
 }
 
-static inline u16 ixgbe_get_hdr_info(union ixgbe_adv_rx_desc *rx_desc)
+static inline u16 ixgbe_get_hlen(union ixgbe_adv_rx_desc *rx_desc)
 {
-	return rx_desc->wb.lower.lo_dword.hs_rss.hdr_info;
-}
-
-static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
-{
-	return rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
-}
-
-static inline u32 ixgbe_get_rsc_count(union ixgbe_adv_rx_desc *rx_desc)
-{
-	return (le32_to_cpu(rx_desc->wb.lower.lo_dword.data) &
-		IXGBE_RXDADV_RSCCNT_MASK) >>
-		IXGBE_RXDADV_RSCCNT_SHIFT;
+	/* HW will not DMA in data larger than the given buffer, even if it
+	 * parses the (NFS, of course) header to be larger.  In that case, it
+	 * fills the header buffer and spills the rest into the page.
+	 */
+	u16 hdr_info = le16_to_cpu(rx_desc->wb.lower.lo_dword.hs_rss.hdr_info);
+	u16 hlen = (hdr_info &  IXGBE_RXDADV_HDRBUFLEN_MASK) >>
+		    IXGBE_RXDADV_HDRBUFLEN_SHIFT;
+	if (hlen > IXGBE_RX_HDR_SIZE)
+		hlen = IXGBE_RX_HDR_SIZE;
+	return hlen;
 }
 
 /**
  * ixgbe_transform_rsc_queue - change rsc queue into a full packet
  * @skb: pointer to the last skb in the rsc queue
- * @count: pointer to number of packets coalesced in this context
  *
  * This function changes a queue full of hw rsc buffers into a completed
  * packet.  It uses the ->prev pointers to find the first packet and then
  * turns it into the frag list owner.
  **/
-static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb,
-							u64 *count)
+static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb)
 {
 	unsigned int frag_list_size = 0;
+	unsigned int skb_cnt = 1;
 
 	while (skb->prev) {
 		struct sk_buff *prev = skb->prev;
 		frag_list_size += skb->len;
 		skb->prev = NULL;
 		skb = prev;
-		*count += 1;
+		skb_cnt++;
 	}
 
 	skb_shinfo(skb)->frag_list = skb->next;
@@ -1156,68 +1275,59 @@ static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb,
 	skb->len += frag_list_size;
 	skb->data_len += frag_list_size;
 	skb->truesize += frag_list_size;
+	IXGBE_RSC_CB(skb)->skb_cnt = skb_cnt;
+
 	return skb;
 }
 
-struct ixgbe_rsc_cb {
-	dma_addr_t dma;
-	bool delay_unmap;
-};
-
-#define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
+static inline bool ixgbe_get_rsc_state(union ixgbe_adv_rx_desc *rx_desc)
+{
+	return !!(le32_to_cpu(rx_desc->wb.lower.lo_dword.data) &
+		IXGBE_RXDADV_RSCCNT_MASK);
+}
 
-static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
+static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *rx_ring,
 			       int *work_done, int work_to_do)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
-	unsigned int i, rsc_count = 0;
-	u32 len, staterr;
-	u16 hdr_info;
-	bool cleaned = false;
-	int cleaned_count = 0;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
+	const int current_node = numa_node_id();
 #ifdef IXGBE_FCOE
 	int ddp_bytes = 0;
 #endif /* IXGBE_FCOE */
+	u32 staterr;
+	u16 i;
+	u16 cleaned_count = 0;
+	bool pkt_is_rsc = false;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
-	rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
 	while (staterr & IXGBE_RXD_STAT_DD) {
 		u32 upper_len = 0;
-		if (*work_done >= work_to_do)
-			break;
-		(*work_done)++;
 
 		rmb(); /* read descriptor and rx_buffer_info after status DD */
-		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
-			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
-			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
-			       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
-			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
-			if ((len > IXGBE_RX_HDR_SIZE) ||
-			    (upper_len && !(hdr_info & IXGBE_RXDADV_SPH)))
-				len = IXGBE_RX_HDR_SIZE;
-		} else {
-			len = le16_to_cpu(rx_desc->wb.upper.length);
-		}
 
-		cleaned = true;
+		rx_buffer_info = &rx_ring->rx_buffer_info[i];
+
 		skb = rx_buffer_info->skb;
-		prefetch(skb->data);
 		rx_buffer_info->skb = NULL;
+		prefetch(skb->data);
+
+		if (ring_is_rsc_enabled(rx_ring))
+			pkt_is_rsc = ixgbe_get_rsc_state(rx_desc);
 
+		/* if this is a skb from previous receive DMA will be 0 */
 		if (rx_buffer_info->dma) {
-			if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
-			    (!(staterr & IXGBE_RXD_STAT_EOP)) &&
-				 (!(skb->prev))) {
+			u16 hlen;
+			if (pkt_is_rsc &&
+			    !(staterr & IXGBE_RXD_STAT_EOP) &&
+			    !skb->prev) {
 				/*
 				 * When HWRSC is enabled, delay unmapping
 				 * of the first packet. It carries the
@@ -1228,29 +1338,42 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				IXGBE_RSC_CB(skb)->delay_unmap = true;
 				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
 			} else {
-				dma_unmap_single(&pdev->dev,
+				dma_unmap_single(rx_ring->dev,
 						 rx_buffer_info->dma,
 						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 			}
 			rx_buffer_info->dma = 0;
-			skb_put(skb, len);
+
+			if (ring_is_ps_enabled(rx_ring)) {
+				hlen = ixgbe_get_hlen(rx_desc);
+				upper_len = le16_to_cpu(rx_desc->wb.upper.length);
+			} else {
+				hlen = le16_to_cpu(rx_desc->wb.upper.length);
+			}
+
+			skb_put(skb, hlen);
+		} else {
+			/* assume packet split since header is unmapped */
+			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
 		}
 
 		if (upper_len) {
-			dma_unmap_page(&pdev->dev, rx_buffer_info->page_dma,
-				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
+			dma_unmap_page(rx_ring->dev,
+				       rx_buffer_info->page_dma,
+				       PAGE_SIZE / 2,
+				       DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 					   rx_buffer_info->page,
 					   rx_buffer_info->page_offset,
 					   upper_len);
 
-			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
-			    (page_count(rx_buffer_info->page) != 1))
-				rx_buffer_info->page = NULL;
-			else
+			if ((page_count(rx_buffer_info->page) == 1) &&
+			    (page_to_nid(rx_buffer_info->page) == current_node))
 				get_page(rx_buffer_info->page);
+			else
+				rx_buffer_info->page = NULL;
 
 			skb->len += upper_len;
 			skb->data_len += upper_len;
@@ -1265,10 +1388,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		prefetch(next_rxd);
 		cleaned_count++;
 
-		if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
-			rsc_count = ixgbe_get_rsc_count(rx_desc);
-
-		if (rsc_count) {
+		if (pkt_is_rsc) {
 			u32 nextp = (staterr & IXGBE_RXDADV_NEXTP_MASK) >>
 				     IXGBE_RXDADV_NEXTP_SHIFT;
 			next_buffer = &rx_ring->rx_buffer_info[nextp];
@@ -1276,32 +1396,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			next_buffer = &rx_ring->rx_buffer_info[i];
 		}
 
-		if (staterr & IXGBE_RXD_STAT_EOP) {
-			if (skb->prev)
-				skb = ixgbe_transform_rsc_queue(skb,
-								&(rx_ring->rsc_count));
-			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-				if (IXGBE_RSC_CB(skb)->delay_unmap) {
-					dma_unmap_single(&pdev->dev,
-							 IXGBE_RSC_CB(skb)->dma,
-							 rx_ring->rx_buf_len,
-							 DMA_FROM_DEVICE);
-					IXGBE_RSC_CB(skb)->dma = 0;
-					IXGBE_RSC_CB(skb)->delay_unmap = false;
-				}
-				if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)
-					rx_ring->rsc_count +=
-						skb_shinfo(skb)->nr_frags;
-				else
-					rx_ring->rsc_count++;
-				rx_ring->rsc_flush++;
-			}
-			u64_stats_update_begin(&rx_ring->syncp);
-			rx_ring->stats.packets++;
-			rx_ring->stats.bytes += skb->len;
-			u64_stats_update_end(&rx_ring->syncp);
-		} else {
-			if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
+		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
+			if (ring_is_ps_enabled(rx_ring)) {
 				rx_buffer_info->skb = next_buffer->skb;
 				rx_buffer_info->dma = next_buffer->dma;
 				next_buffer->skb = skb;
@@ -1310,12 +1406,45 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				skb->next = next_buffer->skb;
 				skb->next->prev = skb;
 			}
-			rx_ring->non_eop_descs++;
+			rx_ring->rx_stats.non_eop_descs++;
 			goto next_desc;
 		}
 
+		if (skb->prev) {
+			skb = ixgbe_transform_rsc_queue(skb);
+			/* if we got here without RSC the packet is invalid */
+			if (!pkt_is_rsc) {
+				__pskb_trim(skb, 0);
+				rx_buffer_info->skb = skb;
+				goto next_desc;
+			}
+		}
+
+		if (ring_is_rsc_enabled(rx_ring)) {
+			if (IXGBE_RSC_CB(skb)->delay_unmap) {
+				dma_unmap_single(rx_ring->dev,
+						 IXGBE_RSC_CB(skb)->dma,
+						 rx_ring->rx_buf_len,
+						 DMA_FROM_DEVICE);
+				IXGBE_RSC_CB(skb)->dma = 0;
+				IXGBE_RSC_CB(skb)->delay_unmap = false;
+			}
+		}
+		if (pkt_is_rsc) {
+			if (ring_is_ps_enabled(rx_ring))
+				rx_ring->rx_stats.rsc_count +=
+					skb_shinfo(skb)->nr_frags;
+			else
+				rx_ring->rx_stats.rsc_count +=
+					IXGBE_RSC_CB(skb)->skb_cnt;
+			rx_ring->rx_stats.rsc_flush++;
+		}
+
+		/* ERR_MASK will only have valid bits if EOP set */
 		if (staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK) {
-			dev_kfree_skb_irq(skb);
+			/* trim packet back to size 0 and recycle it */
+			__pskb_trim(skb, 0);
+			rx_buffer_info->skb = skb;
 			goto next_desc;
 		}
 
@@ -1325,7 +1454,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, adapter->netdev);
+		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
@@ -1339,16 +1468,18 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
 
+		(*work_done)++;
+		if (*work_done >= work_to_do)
+			break;
+
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IXGBE_RX_BUFFER_WRITE) {
-			ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
+			ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
 			cleaned_count = 0;
 		}
 
 		/* use prefetched values */
 		rx_desc = next_rxd;
-		rx_buffer_info = &rx_ring->rx_buffer_info[i];
-
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
@@ -1356,14 +1487,14 @@ next_desc:
 	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
 
 	if (cleaned_count)
-		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
+		ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
 
 #ifdef IXGBE_FCOE
 	/* include DDPed FCoE data */
 	if (ddp_bytes > 0) {
 		unsigned int mss;
 
-		mss = adapter->netdev->mtu - sizeof(struct fcoe_hdr) -
+		mss = rx_ring->netdev->mtu - sizeof(struct fcoe_hdr) -
 			sizeof(struct fc_frame_header) -
 			sizeof(struct fcoe_crc_eof);
 		if (mss > 512)
@@ -1375,8 +1506,10 @@ next_desc:
 
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
-
-	return cleaned;
+	u64_stats_update_begin(&rx_ring->syncp);
+	rx_ring->stats.packets += total_rx_packets;
+	rx_ring->stats.bytes += total_rx_bytes;
+	u64_stats_update_end(&rx_ring->syncp);
 }
 
 static int ixgbe_clean_rxonly(struct napi_struct *, int);
@@ -1390,7 +1523,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *, int);
 static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_q_vector *q_vector;
-	int i, j, q_vectors, v_idx, r_idx;
+	int i, q_vectors, v_idx, r_idx;
 	u32 mask;
 
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
@@ -1406,8 +1539,8 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 				       adapter->num_rx_queues);
 
 		for (i = 0; i < q_vector->rxr_count; i++) {
-			j = adapter->rx_ring[r_idx]->reg_idx;
-			ixgbe_set_ivar(adapter, 0, j, v_idx);
+			u8 reg_idx = adapter->rx_ring[r_idx]->reg_idx;
+			ixgbe_set_ivar(adapter, 0, reg_idx, v_idx);
 			r_idx = find_next_bit(q_vector->rxr_idx,
 					      adapter->num_rx_queues,
 					      r_idx + 1);
@@ -1416,8 +1549,8 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 				       adapter->num_tx_queues);
 
 		for (i = 0; i < q_vector->txr_count; i++) {
-			j = adapter->tx_ring[r_idx]->reg_idx;
-			ixgbe_set_ivar(adapter, 1, j, v_idx);
+			u8 reg_idx = adapter->tx_ring[r_idx]->reg_idx;
+			ixgbe_set_ivar(adapter, 1, reg_idx, v_idx);
 			r_idx = find_next_bit(q_vector->txr_idx,
 					      adapter->num_tx_queues,
 					      r_idx + 1);
@@ -1448,11 +1581,19 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		}
 	}
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
 		ixgbe_set_ivar(adapter, -1, IXGBE_IVAR_OTHER_CAUSES_INDEX,
 			       v_idx);
-	else if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		ixgbe_set_ivar(adapter, -1, 1, v_idx);
+		break;
+
+	default:
+		break;
+	}
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx), 1950);
 
 	/* set up to autoclear timer, and the vectors */
@@ -1548,12 +1689,15 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 	int v_idx = q_vector->v_idx;
 	u32 itr_reg = EITR_INTS_PER_SEC_TO_REG(q_vector->eitr);
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
 		/* must write high and low 16 bits to reset counter */
 		itr_reg |= (itr_reg << 16);
-	} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		/*
-		 * 82599 can support a value of zero, so allow it for
+		 * 82599 and X540 can support a value of zero, so allow it for
 		 * max interrupt rate, but there is an errata where it can
 		 * not be zero with RSC
 		 */
@@ -1566,6 +1710,9 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 		 * immediate assertion of the interrupt
 		 */
 		itr_reg |= IXGBE_EITR_CNT_WDIS;
+		break;
+	default:
+		break;
 	}
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg);
 }
@@ -1573,14 +1720,13 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
+	int i, r_idx;
 	u32 new_itr;
 	u8 current_itr, ret_itr;
-	int i, r_idx;
-	struct ixgbe_ring *rx_ring, *tx_ring;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
-		tx_ring = adapter->tx_ring[r_idx];
+		struct ixgbe_ring *tx_ring = adapter->tx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
 					   q_vector->tx_itr,
 					   tx_ring->total_packets,
@@ -1595,7 +1741,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
-		rx_ring = adapter->rx_ring[r_idx];
+		struct ixgbe_ring *rx_ring = adapter->rx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
 					   q_vector->rx_itr,
 					   rx_ring->total_packets,
@@ -1626,7 +1772,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 
 	if (new_itr != q_vector->eitr) {
 		/* do an exponential smoothing */
-		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
+		new_itr = ((q_vector->eitr * 9) + new_itr)/10;
 
 		/* save the algorithm value here, not the smoothed one */
 		q_vector->eitr = new_itr;
@@ -1694,17 +1840,18 @@ static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 
+	if (eicr & IXGBE_EICR_GPI_SDP2) {
+		/* Clear the interrupt */
+		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP2);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			schedule_work(&adapter->sfp_config_module_task);
+	}
+
 	if (eicr & IXGBE_EICR_GPI_SDP1) {
 		/* Clear the interrupt */
 		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1);
-		schedule_work(&adapter->multispeed_fiber_task);
-	} else if (eicr & IXGBE_EICR_GPI_SDP2) {
-		/* Clear the interrupt */
-		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP2);
-		schedule_work(&adapter->sfp_config_module_task);
-	} else {
-		/* Interrupt isn't for us... */
-		return;
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			schedule_work(&adapter->multispeed_fiber_task);
 	}
 }
 
@@ -1744,16 +1891,9 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	if (eicr & IXGBE_EICR_MAILBOX)
 		ixgbe_msg_task(adapter);
 
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ixgbe_check_fan_failure(adapter, eicr);
-
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		ixgbe_check_sfp_event(adapter, eicr);
-		adapter->interrupt_event = eicr;
-		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC)))
-			schedule_work(&adapter->check_overtemp_task);
-
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		/* Handle Flow Director Full threshold interrupt */
 		if (eicr & IXGBE_EICR_FLOW_DIR) {
 			int i;
@@ -1763,12 +1903,24 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 			for (i = 0; i < adapter->num_tx_queues; i++) {
 				struct ixgbe_ring *tx_ring =
 							    adapter->tx_ring[i];
-				if (test_and_clear_bit(__IXGBE_FDIR_INIT_DONE,
-						       &tx_ring->reinit_state))
+				if (test_and_clear_bit(__IXGBE_TX_FDIR_INIT_DONE,
+						       &tx_ring->state))
 					schedule_work(&adapter->fdir_reinit_task);
 			}
 		}
+		ixgbe_check_sfp_event(adapter, eicr);
+		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
+		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
+			adapter->interrupt_event = eicr;
+			schedule_work(&adapter->check_overtemp_task);
+		}
+		break;
+	default:
+		break;
 	}
+
+	ixgbe_check_fan_failure(adapter, eicr);
+
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
@@ -1779,15 +1931,24 @@ static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
 					   u64 qmask)
 {
 	u32 mask;
+	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
 		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, mask);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		mask = (qmask & 0xFFFFFFFF);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(0), mask);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(0), mask);
 		mask = (qmask >> 32);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1), mask);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(1), mask);
+		break;
+	default:
+		break;
 	}
 	/* skip the flush */
 }
@@ -1796,15 +1957,24 @@ static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
 					    u64 qmask)
 {
 	u32 mask;
+	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
 		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, mask);
-	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_EIMC, mask);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		mask = (qmask & 0xFFFFFFFF);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), mask);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(0), mask);
 		mask = (qmask >> 32);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), mask);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(1), mask);
+		break;
+	default:
+		break;
 	}
 	/* skip the flush */
 }
@@ -1847,8 +2017,13 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	int r_idx;
 	int i;
 
+#ifdef CONFIG_IXGBE_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		ixgbe_update_dca(q_vector);
+#endif
+
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0;  i < q_vector->rxr_count; i++) {
+	for (i = 0; i < q_vector->rxr_count; i++) {
 		rx_ring = adapter->rx_ring[r_idx];
 		rx_ring->total_bytes = 0;
 		rx_ring->total_packets = 0;
@@ -1859,7 +2034,6 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	if (!q_vector->rxr_count)
 		return IRQ_HANDLED;
 
-	/* disable interrupts on this vector only */
 	/* EIAM disabled interrupts (on this vector) for us */
 	napi_schedule(&q_vector->napi);
 
@@ -1918,13 +2092,14 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	int work_done = 0;
 	long r_idx;
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	rx_ring = adapter->rx_ring[r_idx];
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_rx_dca(adapter, rx_ring);
+		ixgbe_update_dca(q_vector);
 #endif
 
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	rx_ring = adapter->rx_ring[r_idx];
+
 	ixgbe_clean_rx_irq(q_vector, rx_ring, &work_done, budget);
 
 	/* If all Rx work done, exit the polling mode */
@@ -1958,13 +2133,14 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	long r_idx;
 	bool tx_clean_complete = true;
 
+#ifdef CONFIG_IXGBE_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		ixgbe_update_dca(q_vector);
+#endif
+
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		ring = adapter->tx_ring[r_idx];
-#ifdef CONFIG_IXGBE_DCA
-		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-			ixgbe_update_tx_dca(adapter, ring);
-#endif
 		tx_clean_complete &= ixgbe_clean_tx_irq(q_vector, ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 				      r_idx + 1);
@@ -1977,10 +2153,6 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
 		ring = adapter->rx_ring[r_idx];
-#ifdef CONFIG_IXGBE_DCA
-		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-			ixgbe_update_rx_dca(adapter, ring);
-#endif
 		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 				      r_idx + 1);
@@ -2019,13 +2191,14 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 	int work_done = 0;
 	long r_idx;
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	tx_ring = adapter->tx_ring[r_idx];
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_tx_dca(adapter, tx_ring);
+		ixgbe_update_dca(q_vector);
 #endif
 
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	tx_ring = adapter->tx_ring[r_idx];
+
 	if (!ixgbe_clean_tx_irq(q_vector, tx_ring))
 		work_done = budget;
 
@@ -2046,24 +2219,27 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 				     int r_idx)
 {
 	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
+	struct ixgbe_ring *rx_ring = a->rx_ring[r_idx];
 
 	set_bit(r_idx, q_vector->rxr_idx);
 	q_vector->rxr_count++;
+	rx_ring->q_vector = q_vector;
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
 				     int t_idx)
 {
 	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
+	struct ixgbe_ring *tx_ring = a->tx_ring[t_idx];
 
 	set_bit(t_idx, q_vector->txr_idx);
 	q_vector->txr_count++;
+	tx_ring->q_vector = q_vector;
 }
 
 /**
  * ixgbe_map_rings_to_vectors - Maps descriptor rings to vectors
  * @adapter: board private structure to initialize
- * @vectors: allotted vector count for descriptor rings
  *
  * This function maps descriptor rings to the queue-specific vectors
  * we were allotted through the MSI-X enabling code.  Ideally, we'd have
@@ -2071,9 +2247,9 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
  * group the rings as "efficiently" as possible.  You would add new
  * mapping configurations in here.
  **/
-static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
-				      int vectors)
+static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter)
 {
+	int q_vectors;
 	int v_start = 0;
 	int rxr_idx = 0, txr_idx = 0;
 	int rxr_remaining = adapter->num_rx_queues;
@@ -2086,11 +2262,13 @@ static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
 	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
 		goto out;
 
+	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
 	/*
 	 * The ideal configuration...
 	 * We have enough vectors to map one per queue.
 	 */
-	if (vectors == adapter->num_rx_queues + adapter->num_tx_queues) {
+	if (q_vectors == adapter->num_rx_queues + adapter->num_tx_queues) {
 		for (; rxr_idx < rxr_remaining; v_start++, rxr_idx++)
 			map_vector_to_rxq(adapter, v_start, rxr_idx);
 
@@ -2106,23 +2284,20 @@ static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
 	 * multiple queues per vector.
 	 */
 	/* Re-adjusting *qpv takes care of the remainder. */
-	for (i = v_start; i < vectors; i++) {
-		rqpv = DIV_ROUND_UP(rxr_remaining, vectors - i);
+	for (i = v_start; i < q_vectors; i++) {
+		rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - i);
 		for (j = 0; j < rqpv; j++) {
 			map_vector_to_rxq(adapter, i, rxr_idx);
 			rxr_idx++;
 			rxr_remaining--;
 		}
-	}
-	for (i = v_start; i < vectors; i++) {
-		tqpv = DIV_ROUND_UP(txr_remaining, vectors - i);
+		tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - i);
 		for (j = 0; j < tqpv; j++) {
 			map_vector_to_txq(adapter, i, txr_idx);
 			txr_idx++;
 			txr_remaining--;
 		}
 	}
-
 out:
 	return err;
 }
@@ -2144,30 +2319,36 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	/* Decrement for Other and TCP Timer vectors */
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
-	/* Map the Tx/Rx rings to the vectors we were allotted. */
-	err = ixgbe_map_rings_to_vectors(adapter, q_vectors);
+	err = ixgbe_map_rings_to_vectors(adapter);
 	if (err)
-		goto out;
+		return err;
 
-#define SET_HANDLER(_v) ((!(_v)->rxr_count) ? &ixgbe_msix_clean_tx : \
-			 (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
-			 &ixgbe_msix_clean_many)
+#define SET_HANDLER(_v) (((_v)->rxr_count && (_v)->txr_count)        \
+					  ? &ixgbe_msix_clean_many : \
+			  (_v)->rxr_count ? &ixgbe_msix_clean_rx   : \
+			  (_v)->txr_count ? &ixgbe_msix_clean_tx   : \
+			  NULL)
 	for (vector = 0; vector < q_vectors; vector++) {
-		handler = SET_HANDLER(adapter->q_vector[vector]);
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
+		handler = SET_HANDLER(q_vector);
 
 		if (handler == &ixgbe_msix_clean_rx) {
-			sprintf(adapter->name[vector], "%s-%s-%d",
+			sprintf(q_vector->name, "%s-%s-%d",
 				netdev->name, "rx", ri++);
 		} else if (handler == &ixgbe_msix_clean_tx) {
-			sprintf(adapter->name[vector], "%s-%s-%d",
+			sprintf(q_vector->name, "%s-%s-%d",
 				netdev->name, "tx", ti++);
-		} else
-			sprintf(adapter->name[vector], "%s-%s-%d",
-				netdev->name, "TxRx", vector);
-
+		} else if (handler == &ixgbe_msix_clean_many) {
+			sprintf(q_vector->name, "%s-%s-%d",
+				netdev->name, "TxRx", ri++);
+			ti++;
+		} else {
+			/* skip this unused q_vector */
+			continue;
+		}
 		err = request_irq(adapter->msix_entries[vector].vector,
-				  handler, 0, adapter->name[vector],
-				  adapter->q_vector[vector]);
+				  handler, 0, q_vector->name,
+				  q_vector);
 		if (err) {
 			e_err(probe, "request_irq failed for MSIX interrupt "
 			      "Error: %d\n", err);
@@ -2175,9 +2356,9 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		}
 	}
 
-	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
+	sprintf(adapter->lsc_int_name, "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
+			  ixgbe_msix_lsc, 0, adapter->lsc_int_name, netdev);
 	if (err) {
 		e_err(probe, "request_irq for msix_lsc failed: %d\n", err);
 		goto free_queue_irqs;
@@ -2193,17 +2374,16 @@ free_queue_irqs:
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-out:
 	return err;
 }
 
 static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
-	u8 current_itr;
-	u32 new_itr = q_vector->eitr;
 	struct ixgbe_ring *rx_ring = adapter->rx_ring[0];
 	struct ixgbe_ring *tx_ring = adapter->tx_ring[0];
+	u32 new_itr = q_vector->eitr;
+	u8 current_itr;
 
 	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
 					    q_vector->tx_itr,
@@ -2233,9 +2413,9 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 
 	if (new_itr != q_vector->eitr) {
 		/* do an exponential smoothing */
-		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
+		new_itr = ((q_vector->eitr * 9) + new_itr)/10;
 
-		/* save the algorithm value here, not the smoothed one */
+		/* save the algorithm value here */
 		q_vector->eitr = new_itr;
 
 		ixgbe_write_eitr(q_vector);
@@ -2256,12 +2436,17 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 		mask |= IXGBE_EIMS_GPI_SDP0;
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		mask |= IXGBE_EIMS_GPI_SDP1;
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		mask |= IXGBE_EIMS_ECC;
 		mask |= IXGBE_EIMS_GPI_SDP1;
 		mask |= IXGBE_EIMS_GPI_SDP2;
 		if (adapter->num_vfs)
 			mask |= IXGBE_EIMS_MAILBOX;
+		break;
+	default:
+		break;
 	}
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
@@ -2317,13 +2502,21 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
-	if (hw->mac.type == ixgbe_mac_82599EB)
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		ixgbe_check_sfp_event(adapter, eicr);
+		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
+		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
+			adapter->interrupt_event = eicr;
+			schedule_work(&adapter->check_overtemp_task);
+		}
+		break;
+	default:
+		break;
+	}
 
 	ixgbe_check_fan_failure(adapter, eicr);
-	if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-	    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC)))
-		schedule_work(&adapter->check_overtemp_task);
 
 	if (napi_schedule_prep(&(q_vector->napi))) {
 		adapter->tx_ring[0]->total_packets = 0;
@@ -2416,14 +2609,20 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 {
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
-	} else {
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFF0000);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), ~0);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
 		if (adapter->num_vfs > 32)
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, 0);
+		break;
+	default:
+		break;
 	}
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -2469,7 +2668,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	u64 tdba = ring->dma;
 	int wait_loop = 10;
 	u32 txdctl;
-	u16 reg_idx = ring->reg_idx;
+	u8 reg_idx = ring->reg_idx;
 
 	/* disable queue to avoid issues while updating state */
 	txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
@@ -2484,8 +2683,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_tx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
-	ring->head = IXGBE_TDH(reg_idx);
-	ring->tail = IXGBE_TDT(reg_idx);
+	ring->tail = hw->hw_addr + IXGBE_TDT(reg_idx);
 
 	/* configure fetching thresholds */
 	if (adapter->rx_itr_setting == 0) {
@@ -2501,7 +2699,16 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	}
 
 	/* reinitialize flowdirector state */
-	set_bit(__IXGBE_FDIR_INIT_DONE, &ring->reinit_state);
+	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) &&
+	    adapter->atr_sample_rate) {
+		ring->atr_sample_rate = adapter->atr_sample_rate;
+		ring->atr_count = 0;
+		set_bit(__IXGBE_TX_FDIR_INIT_DONE, &ring->state);
+	} else {
+		ring->atr_sample_rate = 0;
+	}
+
+	clear_bit(__IXGBE_HANG_CHECK_ARMED, &ring->state);
 
 	/* enable queue */
 	txdctl |= IXGBE_TXDCTL_ENABLE;
@@ -2592,16 +2799,22 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 				   struct ixgbe_ring *rx_ring)
 {
 	u32 srrctl;
-	int index;
-	struct ixgbe_ring_feature *feature = adapter->ring_feature;
+	u8 reg_idx = rx_ring->reg_idx;
 
-	index = rx_ring->reg_idx;
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-		unsigned long mask;
-		mask = (unsigned long) feature[RING_F_RSS].mask;
-		index = index & mask;
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB: {
+		struct ixgbe_ring_feature *feature = adapter->ring_feature;
+		const int mask = feature[RING_F_RSS].mask;
+		reg_idx = reg_idx & mask;
+	}
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+	default:
+		break;
 	}
-	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(index));
+
+	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(reg_idx));
 
 	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
 	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
@@ -2611,7 +2824,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	srrctl |= (IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
 		  IXGBE_SRRCTL_BSIZEHDR_MASK;
 
-	if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
+	if (ring_is_ps_enabled(rx_ring)) {
 #if (PAGE_SIZE / 2) > IXGBE_MAX_RXBUFFER
 		srrctl |= IXGBE_MAX_RXBUFFER >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 #else
@@ -2624,7 +2837,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 	}
 
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(reg_idx), srrctl);
 }
 
 static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
@@ -2694,19 +2907,36 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_clear_rscctl - disable RSC for the indicated ring
+ * @adapter: address of board private structure
+ * @ring: structure containing ring specific data
+ **/
+void ixgbe_clear_rscctl(struct ixgbe_adapter *adapter,
+                        struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 rscctrl;
+	u8 reg_idx = ring->reg_idx;
+
+	rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(reg_idx));
+	rscctrl &= ~IXGBE_RSCCTL_RSCEN;
+	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(reg_idx), rscctrl);
+}
+
+/**
  * ixgbe_configure_rscctl - enable RSC for the indicated ring
  * @adapter:    address of board private structure
  * @index:      index of ring to set
  **/
-static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
+void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 				   struct ixgbe_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rscctrl;
 	int rx_buf_len;
-	u16 reg_idx = ring->reg_idx;
+	u8 reg_idx = ring->reg_idx;
 
-	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))
+	if (!ring_is_rsc_enabled(ring))
 		return;
 
 	rx_buf_len = ring->rx_buf_len;
@@ -2717,7 +2947,7 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 	 * total size of max desc * buf_len is not greater
 	 * than 65535
 	 */
-	if (ring->flags & IXGBE_RING_RX_PS_ENABLED) {
+	if (ring_is_ps_enabled(ring)) {
 #if (MAX_SKB_FRAGS > 16)
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
 #elif (MAX_SKB_FRAGS > 8)
@@ -2770,9 +3000,9 @@ static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 				       struct ixgbe_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int reg_idx = ring->reg_idx;
 	int wait_loop = IXGBE_MAX_RX_DESC_POLL;
 	u32 rxdctl;
+	u8 reg_idx = ring->reg_idx;
 
 	/* RXDCTL.EN will return 0 on 82598 if link is down, so skip it */
 	if (hw->mac.type == ixgbe_mac_82598EB &&
@@ -2796,7 +3026,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 rdba = ring->dma;
 	u32 rxdctl;
-	u16 reg_idx = ring->reg_idx;
+	u8 reg_idx = ring->reg_idx;
 
 	/* disable queue to avoid issues while updating state */
 	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
@@ -2810,8 +3040,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_RDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_RDT(reg_idx), 0);
-	ring->head = IXGBE_RDH(reg_idx);
-	ring->tail = IXGBE_RDT(reg_idx);
+	ring->tail = hw->hw_addr + IXGBE_RDT(reg_idx);
 
 	ixgbe_configure_srrctl(adapter, ring);
 	ixgbe_configure_rscctl(adapter, ring);
@@ -2833,7 +3062,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
 
 	ixgbe_rx_desc_queue_enable(adapter, ring);
-	ixgbe_alloc_rx_buffers(adapter, ring, IXGBE_DESC_UNUSED(ring));
+	ixgbe_alloc_rx_buffers(ring, IXGBE_DESC_UNUSED(ring));
 }
 
 static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
@@ -2956,24 +3185,32 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		rx_ring->rx_buf_len = rx_buf_len;
 
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)
-			rx_ring->flags |= IXGBE_RING_RX_PS_ENABLED;
+			set_ring_ps_enabled(rx_ring);
+		else
+			clear_ring_ps_enabled(rx_ring);
+
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
+			set_ring_rsc_enabled(rx_ring);
 		else
-			rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
+			clear_ring_rsc_enabled(rx_ring);
 
 #ifdef IXGBE_FCOE
 		if (netdev->features & NETIF_F_FCOE_MTU) {
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((i >= f->mask) && (i < f->mask + f->indices)) {
-				rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
+				clear_ring_ps_enabled(rx_ring);
 				if (rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE)
 					rx_ring->rx_buf_len =
 						IXGBE_FCOE_JUMBO_FRAME_SIZE;
+			} else if (!ring_is_rsc_enabled(rx_ring) &&
+				   !ring_is_ps_enabled(rx_ring)) {
+				rx_ring->rx_buf_len =
+						IXGBE_FCOE_JUMBO_FRAME_SIZE;
 			}
 		}
 #endif /* IXGBE_FCOE */
 	}
-
 }
 
 static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
@@ -2996,6 +3233,7 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 		rdrxctl |= IXGBE_RDRXCTL_MVMEN;
 		break;
 	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		/* Disable RSC for ACK packets */
 		IXGBE_WRITE_REG(hw, IXGBE_RSCDBU,
 		   (IXGBE_RSCDBU_RSCACKDIS | IXGBE_READ_REG(hw, IXGBE_RSCDBU)));
@@ -3123,6 +3361,7 @@ static void ixgbe_vlan_strip_disable(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		break;
 	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
@@ -3152,6 +3391,7 @@ static void ixgbe_vlan_strip_enable(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		break;
 	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
@@ -3349,8 +3589,6 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = adapter->netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	u32 txdctl;
-	int i, j;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED)) {
 		if (hw->mac.type == ixgbe_mac_82598EB)
@@ -3366,25 +3604,18 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 		max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
 #endif
 
-	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, max_frame,
+	ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
 					DCB_TX_CONFIG);
-	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, max_frame,
+	ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
 					DCB_RX_CONFIG);
 
-	/* reconfigure the hardware */
-	ixgbe_dcb_hw_config(&adapter->hw, &adapter->dcb_cfg);
-
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i]->reg_idx;
-		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
-		/* PThresh workaround for Tx hang with DFP enabled. */
-		txdctl |= 32;
-		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
-	}
 	/* Enable VLAN tag insert/strip */
 	adapter->netdev->features |= NETIF_F_HW_VLAN_RX;
 
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
+
+	/* reconfigure the hardware */
+	ixgbe_dcb_hw_config(hw, &adapter->dcb_cfg);
 }
 
 #endif
@@ -3516,8 +3747,9 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 		case ixgbe_mac_82598EB:
 			IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);
 			break;
-		default:
 		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
+		default:
 			IXGBE_WRITE_REG(hw, IXGBE_EIAM_EX(0), 0xFFFFFFFF);
 			IXGBE_WRITE_REG(hw, IXGBE_EIAM_EX(1), 0xFFFFFFFF);
 			break;
@@ -3562,12 +3794,20 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		ixgbe_configure_msi_and_legacy(adapter);
 
 	/* enable the optics */
-	if (hw->phy.multispeed_fiber)
+	if (hw->phy.multispeed_fiber && hw->mac.ops.enable_tx_laser)
 		hw->mac.ops.enable_tx_laser(hw);
 
 	clear_bit(__IXGBE_DOWN, &adapter->state);
 	ixgbe_napi_enable_all(adapter);
 
+	if (ixgbe_is_sfp(hw)) {
+		ixgbe_sfp_link_config(adapter);
+	} else {
+		err = ixgbe_non_sfp_link_config(hw);
+		if (err)
+			e_err(probe, "link_config FAILED %d\n", err);
+	}
+
 	/* clear any pending interrupts, may auto mask */
 	IXGBE_READ_REG(hw, IXGBE_EICR);
 	ixgbe_irq_enable(adapter, true, true);
@@ -3590,26 +3830,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	 * If we're not hot-pluggable SFP+, we just need to configure link
 	 * and bring it up.
 	 */
-	if (hw->phy.type == ixgbe_phy_unknown) {
-		err = hw->phy.ops.identify(hw);
-		if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-			/*
-			 * Take the device down and schedule the sfp tasklet
-			 * which will unregister_netdev and log it.
-			 */
-			ixgbe_down(adapter);
-			schedule_work(&adapter->sfp_config_module_task);
-			return err;
-		}
-	}
-
-	if (ixgbe_is_sfp(hw)) {
-		ixgbe_sfp_link_config(adapter);
-	} else {
-		err = ixgbe_non_sfp_link_config(hw);
-		if (err)
-			e_err(probe, "link_config FAILED %d\n", err);
-	}
+	if (hw->phy.type == ixgbe_phy_unknown)
+		schedule_work(&adapter->sfp_config_module_task);
 
 	/* enable transmits */
 	netif_tx_start_all_queues(adapter->netdev);
@@ -3687,15 +3909,13 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
- * @adapter: board private structure
  * @rx_ring: ring to free buffers from
  **/
-static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring)
+static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev = rx_ring->dev;
 	unsigned long size;
-	unsigned int i;
+	u16 i;
 
 	/* ring already cleared, nothing to do */
 	if (!rx_ring->rx_buffer_info)
@@ -3707,7 +3927,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
-			dma_unmap_single(&pdev->dev, rx_buffer_info->dma,
+			dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
 					 rx_ring->rx_buf_len,
 					 DMA_FROM_DEVICE);
 			rx_buffer_info->dma = 0;
@@ -3718,7 +3938,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 			do {
 				struct sk_buff *this = skb;
 				if (IXGBE_RSC_CB(this)->delay_unmap) {
-					dma_unmap_single(&pdev->dev,
+					dma_unmap_single(dev,
 							 IXGBE_RSC_CB(this)->dma,
 							 rx_ring->rx_buf_len,
 							 DMA_FROM_DEVICE);
@@ -3732,7 +3952,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		if (!rx_buffer_info->page)
 			continue;
 		if (rx_buffer_info->page_dma) {
-			dma_unmap_page(&pdev->dev, rx_buffer_info->page_dma,
+			dma_unmap_page(dev, rx_buffer_info->page_dma,
 				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
 		}
@@ -3749,24 +3969,17 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
-
-	if (rx_ring->head)
-		writel(0, adapter->hw.hw_addr + rx_ring->head);
-	if (rx_ring->tail)
-		writel(0, adapter->hw.hw_addr + rx_ring->tail);
 }
 
 /**
  * ixgbe_clean_tx_ring - Free Tx Buffers
- * @adapter: board private structure
  * @tx_ring: ring to be cleaned
  **/
-static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring)
+static void ixgbe_clean_tx_ring(struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned long size;
-	unsigned int i;
+	u16 i;
 
 	/* ring already cleared, nothing to do */
 	if (!tx_ring->tx_buffer_info)
@@ -3775,7 +3988,7 @@ static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
 	/* Free all the Tx ring sk_buffs */
 	for (i = 0; i < tx_ring->count; i++) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 	}
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
@@ -3786,11 +3999,6 @@ static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-
-	if (tx_ring->head)
-		writel(0, adapter->hw.hw_addr + tx_ring->head);
-	if (tx_ring->tail)
-		writel(0, adapter->hw.hw_addr + tx_ring->tail);
 }
 
 /**
@@ -3802,7 +4010,7 @@ static void ixgbe_clean_all_rx_rings(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbe_clean_rx_ring(adapter, adapter->rx_ring[i]);
+		ixgbe_clean_rx_ring(adapter->rx_ring[i]);
 }
 
 /**
@@ -3814,7 +4022,7 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbe_clean_tx_ring(adapter, adapter->tx_ring[i]);
+		ixgbe_clean_tx_ring(adapter->tx_ring[i]);
 }
 
 void ixgbe_down(struct ixgbe_adapter *adapter)
@@ -3823,7 +4031,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
 	u32 txdctl;
-	int i, j;
+	int i;
 	int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	/* signal that we are down to the interrupt handler */
@@ -3881,19 +4089,25 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i]->reg_idx;
-		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
-		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
+		u8 reg_idx = adapter->tx_ring[i]->reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx),
 				(txdctl & ~IXGBE_TXDCTL_ENABLE));
 	}
 	/* Disable the Tx DMA engine on 82599 */
-	if (hw->mac.type == ixgbe_mac_82599EB)
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL,
 				(IXGBE_READ_REG(hw, IXGBE_DMATXCTL) &
 				 ~IXGBE_DMATXCTL_TE));
+		break;
+	default:
+		break;
+	}
 
 	/* power down the optics */
-	if (hw->phy.multispeed_fiber)
+	if (hw->phy.multispeed_fiber && hw->mac.ops.disable_tx_laser)
 		hw->mac.ops.disable_tx_laser(hw);
 
 	/* clear n-tuple filters that are cached */
@@ -3925,10 +4139,8 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	int tx_clean_complete, work_done = 0;
 
 #ifdef CONFIG_IXGBE_DCA
-	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
-		ixgbe_update_tx_dca(adapter, adapter->tx_ring[0]);
-		ixgbe_update_rx_dca(adapter, adapter->rx_ring[0]);
-	}
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		ixgbe_update_dca(q_vector);
 #endif
 
 	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring[0]);
@@ -3956,6 +4168,8 @@ static void ixgbe_tx_timeout(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
+	adapter->tx_timeout_count++;
+
 	/* Do the reset outside of interrupt context */
 	schedule_work(&adapter->reset_task);
 }
@@ -3970,8 +4184,6 @@ static void ixgbe_reset_task(struct work_struct *work)
 	    test_bit(__IXGBE_RESETTING, &adapter->state))
 		return;
 
-	adapter->tx_timeout_count++;
-
 	ixgbe_dump(adapter);
 	netdev_err(adapter->netdev, "Reset adapter\n");
 	ixgbe_reinit_locked(adapter);
@@ -4221,19 +4433,16 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 {
 	int i;
-	bool ret = false;
 
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i]->reg_idx = i;
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i]->reg_idx = i;
-		ret = true;
-	} else {
-		ret = false;
-	}
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		return false;
 
-	return ret;
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		adapter->rx_ring[i]->reg_idx = i;
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		adapter->tx_ring[i]->reg_idx = i;
+
+	return true;
 }
 
 #ifdef CONFIG_IXGBE_DCB
@@ -4250,71 +4459,67 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 	bool ret = false;
 	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
 
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-			/* the number of queues is assumed to be symmetric */
-			for (i = 0; i < dcb_i; i++) {
-				adapter->rx_ring[i]->reg_idx = i << 3;
-				adapter->tx_ring[i]->reg_idx = i << 2;
-			}
-			ret = true;
-		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-			if (dcb_i == 8) {
-				/*
-				 * Tx TC0 starts at: descriptor queue 0
-				 * Tx TC1 starts at: descriptor queue 32
-				 * Tx TC2 starts at: descriptor queue 64
-				 * Tx TC3 starts at: descriptor queue 80
-				 * Tx TC4 starts at: descriptor queue 96
-				 * Tx TC5 starts at: descriptor queue 104
-				 * Tx TC6 starts at: descriptor queue 112
-				 * Tx TC7 starts at: descriptor queue 120
-				 *
-				 * Rx TC0-TC7 are offset by 16 queues each
-				 */
-				for (i = 0; i < 3; i++) {
-					adapter->tx_ring[i]->reg_idx = i << 5;
-					adapter->rx_ring[i]->reg_idx = i << 4;
-				}
-				for ( ; i < 5; i++) {
-					adapter->tx_ring[i]->reg_idx =
-								 ((i + 2) << 4);
-					adapter->rx_ring[i]->reg_idx = i << 4;
-				}
-				for ( ; i < dcb_i; i++) {
-					adapter->tx_ring[i]->reg_idx =
-								 ((i + 8) << 3);
-					adapter->rx_ring[i]->reg_idx = i << 4;
-				}
+	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+		return false;
 
-				ret = true;
-			} else if (dcb_i == 4) {
-				/*
-				 * Tx TC0 starts at: descriptor queue 0
-				 * Tx TC1 starts at: descriptor queue 64
-				 * Tx TC2 starts at: descriptor queue 96
-				 * Tx TC3 starts at: descriptor queue 112
-				 *
-				 * Rx TC0-TC3 are offset by 32 queues each
-				 */
-				adapter->tx_ring[0]->reg_idx = 0;
-				adapter->tx_ring[1]->reg_idx = 64;
-				adapter->tx_ring[2]->reg_idx = 96;
-				adapter->tx_ring[3]->reg_idx = 112;
-				for (i = 0 ; i < dcb_i; i++)
-					adapter->rx_ring[i]->reg_idx = i << 5;
-
-				ret = true;
-			} else {
-				ret = false;
+	/* the number of queues is assumed to be symmetric */
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
+		for (i = 0; i < dcb_i; i++) {
+			adapter->rx_ring[i]->reg_idx = i << 3;
+			adapter->tx_ring[i]->reg_idx = i << 2;
+		}
+		ret = true;
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		if (dcb_i == 8) {
+			/*
+			 * Tx TC0 starts at: descriptor queue 0
+			 * Tx TC1 starts at: descriptor queue 32
+			 * Tx TC2 starts at: descriptor queue 64
+			 * Tx TC3 starts at: descriptor queue 80
+			 * Tx TC4 starts at: descriptor queue 96
+			 * Tx TC5 starts at: descriptor queue 104
+			 * Tx TC6 starts at: descriptor queue 112
+			 * Tx TC7 starts at: descriptor queue 120
+			 *
+			 * Rx TC0-TC7 are offset by 16 queues each
+			 */
+			for (i = 0; i < 3; i++) {
+				adapter->tx_ring[i]->reg_idx = i << 5;
+				adapter->rx_ring[i]->reg_idx = i << 4;
 			}
-		} else {
-			ret = false;
+			for ( ; i < 5; i++) {
+				adapter->tx_ring[i]->reg_idx = ((i + 2) << 4);
+				adapter->rx_ring[i]->reg_idx = i << 4;
+			}
+			for ( ; i < dcb_i; i++) {
+				adapter->tx_ring[i]->reg_idx = ((i + 8) << 3);
+				adapter->rx_ring[i]->reg_idx = i << 4;
+			}
+			ret = true;
+		} else if (dcb_i == 4) {
+			/*
+			 * Tx TC0 starts at: descriptor queue 0
+			 * Tx TC1 starts at: descriptor queue 64
+			 * Tx TC2 starts at: descriptor queue 96
+			 * Tx TC3 starts at: descriptor queue 112
+			 *
+			 * Rx TC0-TC3 are offset by 32 queues each
+			 */
+			adapter->tx_ring[0]->reg_idx = 0;
+			adapter->tx_ring[1]->reg_idx = 64;
+			adapter->tx_ring[2]->reg_idx = 96;
+			adapter->tx_ring[3]->reg_idx = 112;
+			for (i = 0 ; i < dcb_i; i++)
+				adapter->rx_ring[i]->reg_idx = i << 5;
+			ret = true;
 		}
-	} else {
-		ret = false;
+		break;
+	default:
+		break;
 	}
-
 	return ret;
 }
 #endif
@@ -4354,55 +4559,55 @@ static inline bool ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
  */
 static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 {
-	int i, fcoe_rx_i = 0, fcoe_tx_i = 0;
-	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
+	int i;
+	u8 fcoe_rx_i = 0, fcoe_tx_i = 0;
+
+	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
+		return false;
 
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 #ifdef CONFIG_IXGBE_DCB
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			struct ixgbe_fcoe *fcoe = &adapter->fcoe;
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 
-			ixgbe_cache_ring_dcb(adapter);
-			/* find out queues in TC for FCoE */
-			fcoe_rx_i = adapter->rx_ring[fcoe->tc]->reg_idx + 1;
-			fcoe_tx_i = adapter->tx_ring[fcoe->tc]->reg_idx + 1;
-			/*
-			 * In 82599, the number of Tx queues for each traffic
-			 * class for both 8-TC and 4-TC modes are:
-			 * TCs  : TC0 TC1 TC2 TC3 TC4 TC5 TC6 TC7
-			 * 8 TCs:  32  32  16  16   8   8   8   8
-			 * 4 TCs:  64  64  32  32
-			 * We have max 8 queues for FCoE, where 8 the is
-			 * FCoE redirection table size. If TC for FCoE is
-			 * less than or equal to TC3, we have enough queues
-			 * to add max of 8 queues for FCoE, so we start FCoE
-			 * tx descriptor from the next one, i.e., reg_idx + 1.
-			 * If TC for FCoE is above TC3, implying 8 TC mode,
-			 * and we need 8 for FCoE, we have to take all queues
-			 * in that traffic class for FCoE.
-			 */
-			if ((f->indices == IXGBE_FCRETA_SIZE) && (fcoe->tc > 3))
-				fcoe_tx_i--;
-		}
+		ixgbe_cache_ring_dcb(adapter);
+		/* find out queues in TC for FCoE */
+		fcoe_rx_i = adapter->rx_ring[fcoe->tc]->reg_idx + 1;
+		fcoe_tx_i = adapter->tx_ring[fcoe->tc]->reg_idx + 1;
+		/*
+		 * In 82599, the number of Tx queues for each traffic
+		 * class for both 8-TC and 4-TC modes are:
+		 * TCs  : TC0 TC1 TC2 TC3 TC4 TC5 TC6 TC7
+		 * 8 TCs:  32  32  16  16   8   8   8   8
+		 * 4 TCs:  64  64  32  32
+		 * We have max 8 queues for FCoE, where 8 the is
+		 * FCoE redirection table size. If TC for FCoE is
+		 * less than or equal to TC3, we have enough queues
+		 * to add max of 8 queues for FCoE, so we start FCoE
+		 * Tx queue from the next one, i.e., reg_idx + 1.
+		 * If TC for FCoE is above TC3, implying 8 TC mode,
+		 * and we need 8 for FCoE, we have to take all queues
+		 * in that traffic class for FCoE.
+		 */
+		if ((f->indices == IXGBE_FCRETA_SIZE) && (fcoe->tc > 3))
+			fcoe_tx_i--;
+	}
 #endif /* CONFIG_IXGBE_DCB */
-		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
-				ixgbe_cache_ring_fdir(adapter);
-			else
-				ixgbe_cache_ring_rss(adapter);
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
+		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+			ixgbe_cache_ring_fdir(adapter);
+		else
+			ixgbe_cache_ring_rss(adapter);
 
-			fcoe_rx_i = f->mask;
-			fcoe_tx_i = f->mask;
-		}
-		for (i = 0; i < f->indices; i++, fcoe_rx_i++, fcoe_tx_i++) {
-			adapter->rx_ring[f->mask + i]->reg_idx = fcoe_rx_i;
-			adapter->tx_ring[f->mask + i]->reg_idx = fcoe_tx_i;
-		}
-		ret = true;
+		fcoe_rx_i = f->mask;
+		fcoe_tx_i = f->mask;
 	}
-	return ret;
+	for (i = 0; i < f->indices; i++, fcoe_rx_i++, fcoe_tx_i++) {
+		adapter->rx_ring[f->mask + i]->reg_idx = fcoe_rx_i;
+		adapter->tx_ring[f->mask + i]->reg_idx = fcoe_tx_i;
+	}
+	return true;
 }
 
 #endif /* IXGBE_FCOE */
@@ -4471,65 +4676,55 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
  **/
 static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
-	int i;
-	int orig_node = adapter->node;
+	int rx = 0, tx = 0, nid = adapter->node;
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->tx_ring[i];
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
-				    adapter->node);
+	if (nid < 0 || !node_online(nid))
+		nid = first_online_node;
+
+	for (; tx < adapter->num_tx_queues; tx++) {
+		struct ixgbe_ring *ring;
+
+		ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, nid);
 		if (!ring)
-			ring = kzalloc(sizeof(struct ixgbe_ring), GFP_KERNEL);
+			ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 		if (!ring)
-			goto err_tx_ring_allocation;
+			goto err_allocation;
 		ring->count = adapter->tx_ring_count;
-		ring->queue_index = i;
-		ring->numa_node = adapter->node;
+		ring->queue_index = tx;
+		ring->numa_node = nid;
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
 
-		adapter->tx_ring[i] = ring;
+		adapter->tx_ring[tx] = ring;
 	}
 
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
+	for (; rx < adapter->num_rx_queues; rx++) {
+		struct ixgbe_ring *ring;
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->rx_ring[i];
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
-				    adapter->node);
+		ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, nid);
 		if (!ring)
-			ring = kzalloc(sizeof(struct ixgbe_ring), GFP_KERNEL);
+			ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 		if (!ring)
-			goto err_rx_ring_allocation;
+			goto err_allocation;
 		ring->count = adapter->rx_ring_count;
-		ring->queue_index = i;
-		ring->numa_node = adapter->node;
+		ring->queue_index = rx;
+		ring->numa_node = nid;
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
 
-		adapter->rx_ring[i] = ring;
+		adapter->rx_ring[rx] = ring;
 	}
 
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
-
 	ixgbe_cache_ring_register(adapter);
 
 	return 0;
 
-err_rx_ring_allocation:
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		kfree(adapter->tx_ring[i]);
-err_tx_ring_allocation:
+err_allocation:
+	while (tx)
+		kfree(adapter->tx_ring[--tx]);
+
+	while (rx)
+		kfree(adapter->rx_ring[--rx]);
 	return -ENOMEM;
 }
 
@@ -4751,6 +4946,11 @@ err_set_interrupt:
 	return err;
 }
 
+static void ring_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ixgbe_ring, rcu));
+}
+
 /**
  * ixgbe_clear_interrupt_scheme - Clear the current interrupt scheme settings
  * @adapter: board private structure to clear interrupt scheme on
@@ -4767,7 +4967,12 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 		adapter->tx_ring[i] = NULL;
 	}
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		kfree(adapter->rx_ring[i]);
+		struct ixgbe_ring *ring = adapter->rx_ring[i];
+
+		/* ixgbe_get_stats64() might access this ring, we must wait
+		 * a grace period before freeing it.
+		 */
+		call_rcu(&ring->rcu, ring_free_rcu);
 		adapter->rx_ring[i] = NULL;
 	}
 
@@ -4844,6 +5049,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	int j;
 	struct tc_configuration *tc;
 #endif
+	int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* PCI config space info */
 
@@ -4858,11 +5064,14 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
-	if (hw->mac.type == ixgbe_mac_82598EB) {
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
 		if (hw->device_id == IXGBE_DEV_ID_82598AT)
 			adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
-	} else if (hw->mac.type == ixgbe_mac_82599EB) {
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
@@ -4891,6 +5100,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->fcoe.up = IXGBE_FCOE_DEFTC;
 #endif
 #endif /* IXGBE_FCOE */
+		break;
+	default:
+		break;
 	}
 
 #ifdef CONFIG_IXGBE_DCB
@@ -4920,8 +5132,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #ifdef CONFIG_DCB
 	adapter->last_lfc_mode = hw->fc.current_mode;
 #endif
-	hw->fc.high_water = IXGBE_DEFAULT_FCRTH;
-	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
+	hw->fc.high_water = FC_HIGH_WATER(max_frame);
+	hw->fc.low_water = FC_LOW_WATER(max_frame);
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
 	hw->fc.send_xon = true;
 	hw->fc.disable_fc_autoneg = false;
@@ -4959,15 +5171,13 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_setup_tx_resources - allocate Tx resources (Descriptors)
- * @adapter: board private structure
  * @tx_ring:    tx descriptor ring (for a specific queue) to setup
  *
  * Return 0 on success, negative on failure
  **/
-int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *tx_ring)
+int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev = tx_ring->dev;
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
@@ -4982,7 +5192,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
+	tx_ring->desc = dma_alloc_coherent(dev, tx_ring->size,
 					   &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->desc)
 		goto err;
@@ -4995,7 +5205,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 err:
 	vfree(tx_ring->tx_buffer_info);
 	tx_ring->tx_buffer_info = NULL;
-	e_err(probe, "Unable to allocate memory for the Tx descriptor ring\n");
+	dev_err(dev, "Unable to allocate memory for the Tx descriptor ring\n");
 	return -ENOMEM;
 }
 
@@ -5014,7 +5224,7 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		err = ixgbe_setup_tx_resources(adapter, adapter->tx_ring[i]);
+		err = ixgbe_setup_tx_resources(adapter->tx_ring[i]);
 		if (!err)
 			continue;
 		e_err(probe, "Allocation for Tx Queue %u failed\n", i);
@@ -5026,48 +5236,41 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_setup_rx_resources - allocate Rx resources (Descriptors)
- * @adapter: board private structure
  * @rx_ring:    rx descriptor ring (for a specific queue) to setup
  *
  * Returns 0 on success, negative on failure
  **/
-int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *rx_ring)
+int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev = rx_ring->dev;
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vmalloc_node(size, adapter->node);
+	rx_ring->rx_buffer_info = vmalloc_node(size, rx_ring->numa_node);
 	if (!rx_ring->rx_buffer_info)
 		rx_ring->rx_buffer_info = vmalloc(size);
-	if (!rx_ring->rx_buffer_info) {
-		e_err(probe, "vmalloc allocation failed for the Rx "
-		      "descriptor ring\n");
-		goto alloc_failed;
-	}
+	if (!rx_ring->rx_buffer_info)
+		goto err;
 	memset(rx_ring->rx_buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
-	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
+	rx_ring->desc = dma_alloc_coherent(dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
 
-	if (!rx_ring->desc) {
-		e_err(probe, "Memory allocation failed for the Rx "
-		      "descriptor ring\n");
-		vfree(rx_ring->rx_buffer_info);
-		goto alloc_failed;
-	}
+	if (!rx_ring->desc)
+		goto err;
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
 	return 0;
-
-alloc_failed:
+err:
+	vfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
+	dev_err(dev, "Unable to allocate memory for the Rx descriptor ring\n");
 	return -ENOMEM;
 }
 
@@ -5081,13 +5284,12 @@ alloc_failed:
  *
  * Return 0 on success, negative on failure
  **/
-
 static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 {
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = ixgbe_setup_rx_resources(adapter, adapter->rx_ring[i]);
+		err = ixgbe_setup_rx_resources(adapter->rx_ring[i]);
 		if (!err)
 			continue;
 		e_err(probe, "Allocation for Rx Queue %u failed\n", i);
@@ -5099,23 +5301,23 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_free_tx_resources - Free Tx Resources per Queue
- * @adapter: board private structure
  * @tx_ring: Tx descriptor ring for a specific queue
  *
  * Free all transmit software resources
  **/
-void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *tx_ring)
+void ixgbe_free_tx_resources(struct ixgbe_ring *tx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
-	ixgbe_clean_tx_ring(adapter, tx_ring);
+	ixgbe_clean_tx_ring(tx_ring);
 
 	vfree(tx_ring->tx_buffer_info);
 	tx_ring->tx_buffer_info = NULL;
 
-	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
-			  tx_ring->dma);
+	/* if not set, then don't free */
+	if (!tx_ring->desc)
+		return;
+
+	dma_free_coherent(tx_ring->dev, tx_ring->size,
+			  tx_ring->desc, tx_ring->dma);
 
 	tx_ring->desc = NULL;
 }
@@ -5132,28 +5334,28 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		if (adapter->tx_ring[i]->desc)
-			ixgbe_free_tx_resources(adapter, adapter->tx_ring[i]);
+			ixgbe_free_tx_resources(adapter->tx_ring[i]);
 }
 
 /**
  * ixgbe_free_rx_resources - Free Rx Resources
- * @adapter: board private structure
  * @rx_ring: ring to clean the resources from
  *
  * Free all receive software resources
  **/
-void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *rx_ring)
+void ixgbe_free_rx_resources(struct ixgbe_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
-	ixgbe_clean_rx_ring(adapter, rx_ring);
+	ixgbe_clean_rx_ring(rx_ring);
 
 	vfree(rx_ring->rx_buffer_info);
 	rx_ring->rx_buffer_info = NULL;
 
-	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
-			  rx_ring->dma);
+	/* if not set, then don't free */
+	if (!rx_ring->desc)
+		return;
+
+	dma_free_coherent(rx_ring->dev, rx_ring->size,
+			  rx_ring->desc, rx_ring->dma);
 
 	rx_ring->desc = NULL;
 }
@@ -5170,7 +5372,7 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		if (adapter->rx_ring[i]->desc)
-			ixgbe_free_rx_resources(adapter, adapter->rx_ring[i]);
+			ixgbe_free_rx_resources(adapter->rx_ring[i]);
 }
 
 /**
@@ -5183,6 +5385,7 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* MTU < 68 is an error and causes problems on some kernels */
@@ -5193,6 +5396,9 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
+	hw->fc.high_water = FC_HIGH_WATER(max_frame);
+	hw->fc.low_water = FC_LOW_WATER(max_frame);
+
 	if (netif_running(netdev))
 		ixgbe_reinit_locked(adapter);
 
@@ -5288,8 +5494,8 @@ static int ixgbe_close(struct net_device *netdev)
 #ifdef CONFIG_PM
 static int ixgbe_resume(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
 	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
@@ -5320,7 +5526,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);
 
 	if (netif_running(netdev)) {
-		err = ixgbe_open(adapter->netdev);
+		err = ixgbe_open(netdev);
 		if (err)
 			return err;
 	}
@@ -5333,8 +5539,8 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 ctrl, fctrl;
 	u32 wufc = adapter->wol;
@@ -5351,6 +5557,8 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		ixgbe_free_all_rx_resources(adapter);
 	}
 
+	ixgbe_clear_interrupt_scheme(adapter);
+
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
 	if (retval)
@@ -5377,15 +5585,20 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		IXGBE_WRITE_REG(hw, IXGBE_WUFC, 0);
 	}
 
-	if (wufc && hw->mac.type == ixgbe_mac_82599EB)
-		pci_wake_from_d3(pdev, true);
-	else
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
 		pci_wake_from_d3(pdev, false);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		pci_wake_from_d3(pdev, !!wufc);
+		break;
+	default:
+		break;
+	}
 
 	*enable_wake = !!wufc;
 
-	ixgbe_clear_interrupt_scheme(adapter);
-
 	ixgbe_release_hw_control(adapter);
 
 	pci_disable_device(pdev);
@@ -5434,10 +5647,12 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_hw_stats *hwstats = &adapter->stats;
 	u64 total_mpc = 0;
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
-	u64 non_eop_descs = 0, restart_queue = 0;
-	struct ixgbe_hw_stats *hwstats = &adapter->stats;
+	u64 non_eop_descs = 0, restart_queue = 0, tx_busy = 0;
+	u64 alloc_rx_page_failed = 0, alloc_rx_buff_failed = 0;
+	u64 bytes = 0, packets = 0;
 
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
 	    test_bit(__IXGBE_RESETTING, &adapter->state))
@@ -5450,21 +5665,41 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 			adapter->hw_rx_no_dma_resources +=
 				IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			rsc_count += adapter->rx_ring[i]->rsc_count;
-			rsc_flush += adapter->rx_ring[i]->rsc_flush;
+			rsc_count += adapter->rx_ring[i]->rx_stats.rsc_count;
+			rsc_flush += adapter->rx_ring[i]->rx_stats.rsc_flush;
 		}
 		adapter->rsc_total_count = rsc_count;
 		adapter->rsc_total_flush = rsc_flush;
 	}
 
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct ixgbe_ring *rx_ring = adapter->rx_ring[i];
+		non_eop_descs += rx_ring->rx_stats.non_eop_descs;
+		alloc_rx_page_failed += rx_ring->rx_stats.alloc_rx_page_failed;
+		alloc_rx_buff_failed += rx_ring->rx_stats.alloc_rx_buff_failed;
+		bytes += rx_ring->stats.bytes;
+		packets += rx_ring->stats.packets;
+	}
+	adapter->non_eop_descs = non_eop_descs;
+	adapter->alloc_rx_page_failed = alloc_rx_page_failed;
+	adapter->alloc_rx_buff_failed = alloc_rx_buff_failed;
+	netdev->stats.rx_bytes = bytes;
+	netdev->stats.rx_packets = packets;
+
+	bytes = 0;
+	packets = 0;
 	/* gather some stats to the adapter struct that are per queue */
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		restart_queue += adapter->tx_ring[i]->restart_queue;
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
+		restart_queue += tx_ring->tx_stats.restart_queue;
+		tx_busy += tx_ring->tx_stats.tx_busy;
+		bytes += tx_ring->stats.bytes;
+		packets += tx_ring->stats.packets;
+	}
 	adapter->restart_queue = restart_queue;
-
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		non_eop_descs += adapter->rx_ring[i]->non_eop_descs;
-	adapter->non_eop_descs = non_eop_descs;
+	adapter->tx_busy = tx_busy;
+	netdev->stats.tx_bytes = bytes;
+	netdev->stats.tx_packets = packets;
 
 	hwstats->crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
 	for (i = 0; i < 8; i++) {
@@ -5479,17 +5714,18 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		hwstats->qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
 		hwstats->qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
 		hwstats->qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
-		if (hw->mac.type == ixgbe_mac_82599EB) {
-			hwstats->pxonrxc[i] +=
-				IXGBE_READ_REG(hw, IXGBE_PXONRXCNT(i));
-			hwstats->pxoffrxc[i] +=
-				IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(i));
-			hwstats->qprdc[i] += IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
-		} else {
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
 			hwstats->pxonrxc[i] +=
 				IXGBE_READ_REG(hw, IXGBE_PXONRXC(i));
-			hwstats->pxoffrxc[i] +=
-				IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
+			break;
+		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
+			hwstats->pxonrxc[i] +=
+				IXGBE_READ_REG(hw, IXGBE_PXONRXCNT(i));
+			break;
+		default:
+			break;
 		}
 		hwstats->pxontxc[i] += IXGBE_READ_REG(hw, IXGBE_PXONTXC(i));
 		hwstats->pxofftxc[i] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(i));
@@ -5498,21 +5734,25 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	/* work around hardware counting issue */
 	hwstats->gprc -= missed_rx;
 
+	ixgbe_update_xoff_received(adapter);
+
 	/* 82598 hardware only has a 32 bit counter in the high register */
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		u64 tmp;
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		hwstats->lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
+		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
+		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
+		hwstats->tor += IXGBE_READ_REG(hw, IXGBE_TORH);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
-		tmp = IXGBE_READ_REG(hw, IXGBE_GORCH) & 0xF;
-						/* 4 high bits of GORC */
-		hwstats->gorc += (tmp << 32);
+		IXGBE_READ_REG(hw, IXGBE_GORCH); /* to clear */
 		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
-		tmp = IXGBE_READ_REG(hw, IXGBE_GOTCH) & 0xF;
-						/* 4 high bits of GOTC */
-		hwstats->gotc += (tmp << 32);
+		IXGBE_READ_REG(hw, IXGBE_GOTCH); /* to clear */
 		hwstats->tor += IXGBE_READ_REG(hw, IXGBE_TORL);
-		IXGBE_READ_REG(hw, IXGBE_TORH);	/* to clear */
+		IXGBE_READ_REG(hw, IXGBE_TORH); /* to clear */
 		hwstats->lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
-		hwstats->lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
 		hwstats->fdirmatch += IXGBE_READ_REG(hw, IXGBE_FDIRMATCH);
 		hwstats->fdirmiss += IXGBE_READ_REG(hw, IXGBE_FDIRMISS);
 #ifdef IXGBE_FCOE
@@ -5523,12 +5763,9 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		hwstats->fcoedwrc += IXGBE_READ_REG(hw, IXGBE_FCOEDWRC);
 		hwstats->fcoedwtc += IXGBE_READ_REG(hw, IXGBE_FCOEDWTC);
 #endif /* IXGBE_FCOE */
-	} else {
-		hwstats->lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
-		hwstats->lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
-		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
-		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
-		hwstats->tor += IXGBE_READ_REG(hw, IXGBE_TORH);
+		break;
+	default:
+		break;
 	}
 	bprc = IXGBE_READ_REG(hw, IXGBE_BPRC);
 	hwstats->bprc += bprc;
@@ -5701,8 +5938,8 @@ static void ixgbe_fdir_reinit_task(struct work_struct *work)
 
 	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			set_bit(__IXGBE_FDIR_INIT_DONE,
-				&(adapter->tx_ring[i]->reinit_state));
+			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
+				&(adapter->tx_ring[i]->state));
 	} else {
 		e_err(probe, "failed to finish FDIR re-initialization, "
 		      "ignored adding FDIR ATR filters\n");
@@ -5764,17 +6001,27 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		if (!netif_carrier_ok(netdev)) {
 			bool flow_rx, flow_tx;
 
-			if (hw->mac.type == ixgbe_mac_82599EB) {
-				u32 mflcn = IXGBE_READ_REG(hw, IXGBE_MFLCN);
-				u32 fccfg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
-				flow_rx = !!(mflcn & IXGBE_MFLCN_RFCE);
-				flow_tx = !!(fccfg & IXGBE_FCCFG_TFCE_802_3X);
-			} else {
+			switch (hw->mac.type) {
+			case ixgbe_mac_82598EB: {
 				u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 				u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
 				flow_rx = !!(frctl & IXGBE_FCTRL_RFCE);
 				flow_tx = !!(rmcs & IXGBE_RMCS_TFCE_802_3X);
 			}
+				break;
+			case ixgbe_mac_82599EB:
+			case ixgbe_mac_X540: {
+				u32 mflcn = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+				u32 fccfg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
+				flow_rx = !!(mflcn & IXGBE_MFLCN_RFCE);
+				flow_tx = !!(fccfg & IXGBE_FCCFG_TFCE_802_3X);
+			}
+				break;
+			default:
+				flow_tx = false;
+				flow_rx = false;
+				break;
+			}
 
 			e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
 			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
@@ -5788,7 +6035,10 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			netif_carrier_on(netdev);
 		} else {
 			/* Force detection of hung controller */
-			adapter->detect_tx_hung = true;
+			for (i = 0; i < adapter->num_tx_queues; i++) {
+				tx_ring = adapter->tx_ring[i];
+				set_check_for_tx_hang(tx_ring);
+			}
 		}
 	} else {
 		adapter->link_up = false;
@@ -6000,15 +6250,17 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			struct ixgbe_ring *tx_ring,
 			struct sk_buff *skb, u32 tx_flags,
-			unsigned int first)
+			unsigned int first, const u8 hdr_len)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev = tx_ring->dev;
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int len;
 	unsigned int total = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
+	unsigned int bytecount = skb->len;
+	u16 gso_segs = 1;
 
 	i = tx_ring->next_to_use;
 
@@ -6023,10 +6275,10 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		tx_buffer_info->length = size;
 		tx_buffer_info->mapped_as_page = false;
-		tx_buffer_info->dma = dma_map_single(&pdev->dev,
+		tx_buffer_info->dma = dma_map_single(dev,
 						     skb->data + offset,
 						     size, DMA_TO_DEVICE);
-		if (dma_mapping_error(&pdev->dev, tx_buffer_info->dma))
+		if (dma_mapping_error(dev, tx_buffer_info->dma))
 			goto dma_error;
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
@@ -6059,12 +6311,12 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 			tx_buffer_info->length = size;
-			tx_buffer_info->dma = dma_map_page(&adapter->pdev->dev,
+			tx_buffer_info->dma = dma_map_page(dev,
 							   frag->page,
 							   offset, size,
 							   DMA_TO_DEVICE);
 			tx_buffer_info->mapped_as_page = true;
-			if (dma_mapping_error(&pdev->dev, tx_buffer_info->dma))
+			if (dma_mapping_error(dev, tx_buffer_info->dma))
 				goto dma_error;
 			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
@@ -6078,6 +6330,19 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			break;
 	}
 
+	if (tx_flags & IXGBE_TX_FLAGS_TSO)
+		gso_segs = skb_shinfo(skb)->gso_segs;
+#ifdef IXGBE_FCOE
+	/* adjust for FCoE Sequence Offload */
+	else if (tx_flags & IXGBE_TX_FLAGS_FSO)
+		gso_segs = DIV_ROUND_UP(skb->len - hdr_len,
+					skb_shinfo(skb)->gso_size);
+#endif /* IXGBE_FCOE */
+	bytecount += (gso_segs - 1) * hdr_len;
+
+	/* multiply data chunks by size of headers */
+	tx_ring->tx_buffer_info[i].bytecount = bytecount;
+	tx_ring->tx_buffer_info[i].gso_segs = gso_segs;
 	tx_ring->tx_buffer_info[i].skb = skb;
 	tx_ring->tx_buffer_info[first].next_to_watch = i;
 
@@ -6099,14 +6364,13 @@ dma_error:
 			i += tx_ring->count;
 		i--;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 	}
 
 	return 0;
 }
 
-static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
-			   struct ixgbe_ring *tx_ring,
+static void ixgbe_tx_queue(struct ixgbe_ring *tx_ring,
 			   int tx_flags, int count, u32 paylen, u8 hdr_len)
 {
 	union ixgbe_adv_tx_desc *tx_desc = NULL;
@@ -6171,60 +6435,46 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 	wmb();
 
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tail);
+	writel(i, tx_ring->tail);
 }
 
 static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
-		      int queue, u32 tx_flags, __be16 protocol)
+		      u8 queue, u32 tx_flags, __be16 protocol)
 {
 	struct ixgbe_atr_input atr_input;
-	struct tcphdr *th;
 	struct iphdr *iph = ip_hdr(skb);
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
-	u16 vlan_id, src_port, dst_port, flex_bytes;
-	u32 src_ipv4_addr, dst_ipv4_addr;
-	u8 l4type = 0;
+	struct tcphdr *th;
+	u16 vlan_id;
 
-	/* Right now, we support IPv4 only */
-	if (protocol != htons(ETH_P_IP))
-		return;
-	/* check if we're UDP or TCP */
-	if (iph->protocol == IPPROTO_TCP) {
-		th = tcp_hdr(skb);
-		src_port = th->source;
-		dst_port = th->dest;
-		l4type |= IXGBE_ATR_L4TYPE_TCP;
-		/* l4type IPv4 type is 0, no need to assign */
-	} else {
-		/* Unsupported L4 header, just bail here */
+	/* Right now, we support IPv4 w/ TCP only */
+	if (protocol != htons(ETH_P_IP) ||
+	    iph->protocol != IPPROTO_TCP)
 		return;
-	}
 
 	memset(&atr_input, 0, sizeof(struct ixgbe_atr_input));
 
 	vlan_id = (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK) >>
 		   IXGBE_TX_FLAGS_VLAN_SHIFT;
-	src_ipv4_addr = iph->saddr;
-	dst_ipv4_addr = iph->daddr;
-	flex_bytes = eth->h_proto;
+
+	th = tcp_hdr(skb);
 
 	ixgbe_atr_set_vlan_id_82599(&atr_input, vlan_id);
-	ixgbe_atr_set_src_port_82599(&atr_input, dst_port);
-	ixgbe_atr_set_dst_port_82599(&atr_input, src_port);
-	ixgbe_atr_set_flex_byte_82599(&atr_input, flex_bytes);
-	ixgbe_atr_set_l4type_82599(&atr_input, l4type);
+	ixgbe_atr_set_src_port_82599(&atr_input, th->dest);
+	ixgbe_atr_set_dst_port_82599(&atr_input, th->source);
+	ixgbe_atr_set_flex_byte_82599(&atr_input, eth->h_proto);
+	ixgbe_atr_set_l4type_82599(&atr_input, IXGBE_ATR_L4TYPE_TCP);
 	/* src and dst are inverted, think how the receiver sees them */
-	ixgbe_atr_set_src_ipv4_82599(&atr_input, dst_ipv4_addr);
-	ixgbe_atr_set_dst_ipv4_82599(&atr_input, src_ipv4_addr);
+	ixgbe_atr_set_src_ipv4_82599(&atr_input, iph->daddr);
+	ixgbe_atr_set_dst_ipv4_82599(&atr_input, iph->saddr);
 
 	/* This assumes the Rx queue and Tx queue are bound to the same CPU */
 	ixgbe_fdir_add_signature_filter_82599(&adapter->hw, &atr_input, queue);
 }
 
-static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
-				 struct ixgbe_ring *tx_ring, int size)
+static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
 {
-	netif_stop_subqueue(netdev, tx_ring->queue_index);
+	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -6236,17 +6486,16 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(netdev, tx_ring->queue_index);
-	++tx_ring->restart_queue;
+	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	++tx_ring->tx_stats.restart_queue;
 	return 0;
 }
 
-static int ixgbe_maybe_stop_tx(struct net_device *netdev,
-			      struct ixgbe_ring *tx_ring, int size)
+static int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
 {
 	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
 		return 0;
-	return __ixgbe_maybe_stop_tx(netdev, tx_ring, size);
+	return __ixgbe_maybe_stop_tx(tx_ring, size);
 }
 
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
@@ -6291,10 +6540,11 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return skb_tx_hash(dev, skb);
 }
 
-netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev,
+netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
 {
+	struct net_device *netdev = tx_ring->netdev;
 	struct netdev_queue *txq;
 	unsigned int first;
 	unsigned int tx_flags = 0;
@@ -6352,8 +6602,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
-	if (ixgbe_maybe_stop_tx(netdev, tx_ring, count)) {
-		adapter->tx_busy++;
+	if (ixgbe_maybe_stop_tx(tx_ring, count)) {
+		tx_ring->tx_stats.tx_busy++;
 		return NETDEV_TX_BUSY;
 	}
 
@@ -6387,14 +6637,14 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 			tx_flags |= IXGBE_TX_FLAGS_CSUM;
 	}
 
-	count = ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first);
+	count = ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first, hdr_len);
 	if (count) {
 		/* add the ATR filter if ATR is on */
 		if (tx_ring->atr_sample_rate) {
 			++tx_ring->atr_count;
 			if ((tx_ring->atr_count >= tx_ring->atr_sample_rate) &&
-			     test_bit(__IXGBE_FDIR_INIT_DONE,
-				      &tx_ring->reinit_state)) {
+			     test_bit(__IXGBE_TX_FDIR_INIT_DONE,
+				      &tx_ring->state)) {
 				ixgbe_atr(adapter, skb, tx_ring->queue_index,
 					  tx_flags, protocol);
 				tx_ring->atr_count = 0;
@@ -6403,9 +6653,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 		txq = netdev_get_tx_queue(netdev, tx_ring->queue_index);
 		txq->tx_bytes += skb->len;
 		txq->tx_packets++;
-		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
-			       hdr_len);
-		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
+		ixgbe_tx_queue(tx_ring, tx_flags, count, skb->len, hdr_len);
+		ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
 	} else {
 		dev_kfree_skb_any(skb);
@@ -6422,7 +6671,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netd
 	struct ixgbe_ring *tx_ring;
 
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
-	return ixgbe_xmit_frame_ring(skb, netdev, adapter, tx_ring);
+	return ixgbe_xmit_frame_ring(skb, adapter, tx_ring);
 }
 
 /**
@@ -6563,20 +6812,23 @@ static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 
 	/* accurate rx/tx bytes/packets stats */
 	dev_txq_stats_fold(netdev, stats);
+	rcu_read_lock();
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->rx_ring[i];
+		struct ixgbe_ring *ring = ACCESS_ONCE(adapter->rx_ring[i]);
 		u64 bytes, packets;
 		unsigned int start;
 
-		do {
-			start = u64_stats_fetch_begin_bh(&ring->syncp);
-			packets = ring->stats.packets;
-			bytes   = ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
-		stats->rx_packets += packets;
-		stats->rx_bytes   += bytes;
+		if (ring) {
+			do {
+				start = u64_stats_fetch_begin_bh(&ring->syncp);
+				packets = ring->stats.packets;
+				bytes   = ring->stats.bytes;
+			} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+			stats->rx_packets += packets;
+			stats->rx_bytes   += bytes;
+		}
 	}
-
+	rcu_read_unlock();
 	/* following stats updated by ixgbe_watchdog_task() */
 	stats->multicast	= netdev->stats.multicast;
 	stats->rx_errors	= netdev->stats.rx_errors;
@@ -6758,8 +7010,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
+	pci_set_drvdata(pdev, adapter);
 
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
@@ -6832,8 +7084,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 
 	/* Make it possible the adapter to be woken up via WOL */
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);
+		break;
+	default:
+		break;
+	}
 
 	/*
 	 * If there is a fan on this device and it has failed log the
@@ -6942,7 +7200,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	/* power down the optics */
-	if (hw->phy.multispeed_fiber)
+	if (hw->phy.multispeed_fiber && hw->mac.ops.disable_tx_laser)
 		hw->mac.ops.disable_tx_laser(hw);
 
 	init_timer(&adapter->watchdog_timer);
@@ -6957,6 +7215,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 
 	switch (pdev->device) {
+	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
+		/* All except this subdevice support WOL */
+		if (pdev->subsystem_device ==
+		    IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ) {
+			adapter->wol = 0;
+			break;
+		}
 	case IXGBE_DEV_ID_82599_KX4:
 		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
 				IXGBE_WUFC_MC | IXGBE_WUFC_BC);
@@ -7082,8 +7347,8 @@ err_dma:
  **/
 static void __devexit ixgbe_remove(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	/* clear the module not found bit to make sure the worker won't
@@ -7153,8 +7418,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 						pci_channel_state_t state)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
 
 	netif_device_detach(netdev);
 
@@ -7177,8 +7442,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
  */
 static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	pci_ers_result_t result;
 	int err;
 
@@ -7216,8 +7480,8 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
  */
 static void ixgbe_io_resume(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
 
 	if (netif_running(netdev)) {
 		if (ixgbe_up(adapter)) {
@@ -7282,6 +7546,7 @@ static void __exit ixgbe_exit_module(void)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 #ifdef CONFIG_IXGBE_DCA
diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index 471f0f2..027c628 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -319,8 +319,14 @@ static s32 ixgbe_check_for_rst_pf(struct ixgbe_hw *hw, u16 vf_number)
 	u32 vflre = 0;
 	s32 ret_val = IXGBE_ERR_MBX;
 
-	if (hw->mac.type == ixgbe_mac_82599EB)
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		vflre = IXGBE_READ_REG(hw, IXGBE_VFLRE(reg_offset));
+		break;
+	default:
+		break;
+	}
 
 	if (vflre & (1 << vf_shift)) {
 		ret_val = 0;
@@ -439,22 +445,26 @@ void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 
-	if (hw->mac.type != ixgbe_mac_82599EB)
-		return;
-
-	mbx->timeout = 0;
-	mbx->usec_delay = 0;
-
-	mbx->size = IXGBE_VFMAILBOX_SIZE;
-
-	mbx->stats.msgs_tx = 0;
-	mbx->stats.msgs_rx = 0;
-	mbx->stats.reqs = 0;
-	mbx->stats.acks = 0;
-	mbx->stats.rsts = 0;
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		mbx->timeout = 0;
+		mbx->usec_delay = 0;
+
+		mbx->size = IXGBE_VFMAILBOX_SIZE;
+
+		mbx->stats.msgs_tx = 0;
+		mbx->stats.msgs_rx = 0;
+		mbx->stats.reqs = 0;
+		mbx->stats.acks = 0;
+		mbx->stats.rsts = 0;
+		break;
+	default:
+		break;
+	}
 }
 
-struct ixgbe_mbx_operations mbx_ops_82599 = {
+struct ixgbe_mbx_operations mbx_ops_generic = {
 	.read                   = ixgbe_read_mbx_pf,
 	.write                  = ixgbe_write_mbx_pf,
 	.read_posted            = ixgbe_read_posted_mbx,
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
index 7e0d08f..3df9b15 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -88,6 +88,6 @@ s32 ixgbe_check_for_ack(struct ixgbe_hw *, u16);
 s32 ixgbe_check_for_rst(struct ixgbe_hw *, u16);
 void ixgbe_init_mbx_params_pf(struct ixgbe_hw *);
 
-extern struct ixgbe_mbx_operations mbx_ops_82599;
+extern struct ixgbe_mbx_operations mbx_ops_generic;
 
 #endif /* _IXGBE_MBX_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 6c0d42e..c445fbc 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -115,6 +115,9 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	case TN1010_PHY_ID:
 		phy_type = ixgbe_phy_tn;
 		break;
+	case AQ1202_PHY_ID:
+		phy_type = ixgbe_phy_aq;
+		break;
 	case QT2022_PHY_ID:
 		phy_type = ixgbe_phy_qt;
 		break;
@@ -425,6 +428,39 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 }
 
 /**
+ * ixgbe_get_copper_link_capabilities_generic - Determines link capabilities
+ * @hw: pointer to hardware structure
+ * @speed: pointer to link speed
+ * @autoneg: boolean auto-negotiation value
+ *
+ * Determines the link capabilities by reading the AUTOC register.
+ */
+s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed *speed,
+                                               bool *autoneg)
+{
+	s32 status = IXGBE_ERR_LINK_SETUP;
+	u16 speed_ability;
+
+	*speed = 0;
+	*autoneg = true;
+
+	status = hw->phy.ops.read_reg(hw, MDIO_SPEED, MDIO_MMD_PMAPMD,
+	                              &speed_ability);
+
+	if (status == 0) {
+		if (speed_ability & MDIO_SPEED_10G)
+			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		if (speed_ability & MDIO_PMA_SPEED_1000)
+			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
+		if (speed_ability & MDIO_PMA_SPEED_100)
+			*speed |= IXGBE_LINK_SPEED_100_FULL;
+	}
+
+	return status;
+}
+
+/**
  *  ixgbe_reset_phy_nl - Performs a PHY reset
  *  @hw: pointer to hardware structure
  **/
@@ -1378,6 +1414,22 @@ s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_get_phy_firmware_version_generic - Gets the PHY Firmware Version
+ *  @hw: pointer to hardware structure
+ *  @firmware_version: pointer to the PHY Firmware Version
+**/
+s32 ixgbe_get_phy_firmware_version_generic(struct ixgbe_hw *hw,
+                                           u16 *firmware_version)
+{
+	s32 status = 0;
+
+	status = hw->phy.ops.read_reg(hw, AQ_FW_REV, MDIO_MMD_VEND1,
+	                              firmware_version);
+
+	return status;
+}
+
+/**
  *  ixgbe_tn_check_overtemp - Checks if an overtemp occured.
  *  @hw: pointer to hardware structure
  *
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index fb3898f..e2c6b7e 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -96,6 +96,9 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
                                        ixgbe_link_speed speed,
                                        bool autoneg,
                                        bool autoneg_wait_to_complete);
+s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed *speed,
+                                               bool *autoneg);
 
 /* PHY specific */
 s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
@@ -103,6 +106,8 @@ s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
                              bool *link_up);
 s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
                                        u16 *firmware_version);
+s32 ixgbe_get_phy_firmware_version_generic(struct ixgbe_hw *hw,
+                                           u16 *firmware_version);
 
 s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw);
 s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw);
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 93f40bc..6e3e94b 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -178,8 +178,7 @@ static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 {
 	unsigned char vf_mac_addr[6];
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	unsigned int vfn = (event_mask & 0x3f);
 
 	bool enable = ((event_mask & 0x10000000U) != 0);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index d3cc6ce..42c6073 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -57,6 +57,8 @@
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 #define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
+#define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
+#define IXGBE_DEV_ID_X540T               0x1528
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000
@@ -994,8 +996,10 @@
 /* PHY IDs*/
 #define TN1010_PHY_ID    0x00A19410
 #define TNX_FW_REV       0xB
+#define AQ1202_PHY_ID    0x03A1B440
 #define QT2022_PHY_ID    0x0043A400
 #define ATH_PHY_ID       0x03429050
+#define AQ_FW_REV        0x20
 
 /* PHY Types */
 #define IXGBE_M88E1145_E_PHY_ID  0x01410CD0
@@ -1491,6 +1495,7 @@
 #define IXGBE_EEC_PRES      0x00000100 /* EEPROM Present */
 #define IXGBE_EEC_ARD       0x00000200 /* EEPROM Auto Read Done */
 #define IXGBE_EEC_FLUP      0x00800000 /* Flash update command */
+#define IXGBE_EEC_SEC1VAL   0x02000000 /* Sector 1 Valid */
 #define IXGBE_EEC_FLUDONE   0x04000000 /* Flash update done */
 /* EEPROM Addressing bits based on type (0-small, 1-large) */
 #define IXGBE_EEC_ADDR_SIZE 0x00000400
@@ -1505,7 +1510,9 @@
 #define IXGBE_EEPROM_SUM        0xBABA
 #define IXGBE_PCIE_ANALOG_PTR   0x03
 #define IXGBE_ATLAS0_CONFIG_PTR 0x04
+#define IXGBE_PHY_PTR           0x04
 #define IXGBE_ATLAS1_CONFIG_PTR 0x05
+#define IXGBE_OPTION_ROM_PTR    0x05
 #define IXGBE_PCIE_GENERAL_PTR  0x06
 #define IXGBE_PCIE_CONFIG0_PTR  0x07
 #define IXGBE_PCIE_CONFIG1_PTR  0x08
@@ -2113,6 +2120,14 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PHYSICAL_LAYER_10GBASE_XAUI 0x1000
 #define IXGBE_PHYSICAL_LAYER_SFP_ACTIVE_DA 0x2000
 
+/* Flow Control Macros */
+#define PAUSE_RTT	8
+#define PAUSE_MTU(MTU)	((MTU + 1024 - 1) / 1024)
+
+#define FC_HIGH_WATER(MTU) ((((PAUSE_RTT + PAUSE_MTU(MTU)) * 144) + 99) / 100 +\
+				PAUSE_MTU(MTU))
+#define FC_LOW_WATER(MTU)  (2 * (2 * PAUSE_MTU(MTU) + PAUSE_RTT))
+
 /* Software ATR hash keys */
 #define IXGBE_ATR_BUCKET_HASH_KEY    0xE214AD3D
 #define IXGBE_ATR_SIGNATURE_HASH_KEY 0x14364D17
@@ -2164,6 +2179,7 @@ struct ixgbe_atr_input_masks {
 enum ixgbe_eeprom_type {
 	ixgbe_eeprom_uninitialized = 0,
 	ixgbe_eeprom_spi,
+	ixgbe_flash,
 	ixgbe_eeprom_none /* No NVM support */
 };
 
@@ -2171,12 +2187,14 @@ enum ixgbe_mac_type {
 	ixgbe_mac_unknown = 0,
 	ixgbe_mac_82598EB,
 	ixgbe_mac_82599EB,
+	ixgbe_mac_X540,
 	ixgbe_num_macs
 };
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
 	ixgbe_phy_tn,
+	ixgbe_phy_aq,
 	ixgbe_phy_cu_unknown,
 	ixgbe_phy_qt,
 	ixgbe_phy_xaui,
@@ -2405,6 +2423,7 @@ struct ixgbe_eeprom_operations {
 	s32 (*write)(struct ixgbe_hw *, u16, u16);
 	s32 (*validate_checksum)(struct ixgbe_hw *, u16 *);
 	s32 (*update_checksum)(struct ixgbe_hw *);
+	u16 (*calc_checksum)(struct ixgbe_hw *);
 };
 
 struct ixgbe_mac_operations {
@@ -2574,6 +2593,7 @@ struct ixgbe_hw {
 	u16				subsystem_vendor_id;
 	u8				revision_id;
 	bool				adapter_stopped;
+	bool				force_full_reset;
 };
 
 struct ixgbe_info {
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
new file mode 100644
index 0000000..9649fa7
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -0,0 +1,722 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2010 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/sched.h>
+
+#include "ixgbe.h"
+#include "ixgbe_phy.h"
+//#include "ixgbe_mbx.h"
+
+#define IXGBE_X540_MAX_TX_QUEUES 128
+#define IXGBE_X540_MAX_RX_QUEUES 128
+#define IXGBE_X540_RAR_ENTRIES   128
+#define IXGBE_X540_MC_TBL_SIZE   128
+#define IXGBE_X540_VFT_TBL_SIZE  128
+
+static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw);
+static s32 ixgbe_poll_flash_update_done_X540(struct ixgbe_hw *hw);
+static s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask);
+static void ixgbe_release_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask);
+static s32 ixgbe_get_swfw_sync_semaphore(struct ixgbe_hw *hw);
+static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw);
+
+static enum ixgbe_media_type ixgbe_get_media_type_X540(struct ixgbe_hw *hw)
+{
+	return ixgbe_media_type_copper;
+}
+
+static s32 ixgbe_get_invariants_X540(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mac_info *mac = &hw->mac;
+
+	/* Call PHY identify routine to get the phy type */
+	ixgbe_identify_phy_generic(hw);
+
+	mac->mcft_size = IXGBE_X540_MC_TBL_SIZE;
+	mac->vft_size = IXGBE_X540_VFT_TBL_SIZE;
+	mac->num_rar_entries = IXGBE_X540_RAR_ENTRIES;
+	mac->max_rx_queues = IXGBE_X540_MAX_RX_QUEUES;
+	mac->max_tx_queues = IXGBE_X540_MAX_TX_QUEUES;
+	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_generic(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_setup_mac_link_X540 - Set the auto advertised capabilitires
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: true if autonegotiation enabled
+ *  @autoneg_wait_to_complete: true when waiting for completion is needed
+ **/
+static s32 ixgbe_setup_mac_link_X540(struct ixgbe_hw *hw,
+                                     ixgbe_link_speed speed, bool autoneg,
+                                     bool autoneg_wait_to_complete)
+{
+	return hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	                                    autoneg_wait_to_complete);
+}
+
+/**
+ *  ixgbe_reset_hw_X540 - Perform hardware reset
+ *  @hw: pointer to hardware structure
+ *
+ *  Resets the hardware by resetting the transmit and receive units, masks
+ *  and clears all interrupts, perform a PHY reset, and perform a link (MAC)
+ *  reset.
+ **/
+static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
+{
+	ixgbe_link_speed link_speed;
+	s32 status = 0;
+	u32 ctrl;
+	u32 ctrl_ext;
+	u32 reset_bit;
+	u32 i;
+	u32 autoc;
+	u32 autoc2;
+	bool link_up = false;
+
+	/* Call adapter stop to disable tx/rx and clear interrupts */
+	hw->mac.ops.stop_adapter(hw);
+
+	/*
+	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
+	 * access and verify no pending requests before reset
+	 */
+	status = ixgbe_disable_pcie_master(hw);
+	if (status != 0) {
+		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
+		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+	}
+
+	/*
+	 * Issue global reset to the MAC.  Needs to be SW reset if link is up.
+	 * If link reset is used when link is up, it might reset the PHY when
+	 * mng is using it.  If link is down or the flag to force full link
+	 * reset is set, then perform link reset.
+	 */
+	if (hw->force_full_reset) {
+		reset_bit = IXGBE_CTRL_LNK_RST;
+	} else {
+		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+		if (!link_up)
+			reset_bit = IXGBE_CTRL_LNK_RST;
+		else
+			reset_bit = IXGBE_CTRL_RST;
+	}
+
+	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | IXGBE_CTRL_RST));
+	IXGBE_WRITE_FLUSH(hw);
+
+	/* Poll for reset bit to self-clear indicating reset is complete */
+	for (i = 0; i < 10; i++) {
+		udelay(1);
+		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+		if (!(ctrl & IXGBE_CTRL_RST))
+			break;
+	}
+	if (ctrl & IXGBE_CTRL_RST) {
+		status = IXGBE_ERR_RESET_FAILED;
+		hw_dbg(hw, "Reset polling failed to complete.\n");
+	}
+
+	/* Clear PF Reset Done bit so PF/VF Mail Ops can work */
+	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
+	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
+
+	msleep(50);
+
+	/* Set the Rx packet buffer size. */
+	IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(0), 384 << IXGBE_RXPBSIZE_SHIFT);
+
+	/* Store the permanent mac address */
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
+
+	/*
+	 * Store the original AUTOC/AUTOC2 values if they have not been
+	 * stored off yet.  Otherwise restore the stored original
+	 * values since the reset operation sets back to defaults.
+	 */
+	autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	if (hw->mac.orig_link_settings_stored == false) {
+		hw->mac.orig_autoc = autoc;
+		hw->mac.orig_autoc2 = autoc2;
+		hw->mac.orig_link_settings_stored = true;
+	} else {
+		if (autoc != hw->mac.orig_autoc)
+			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (hw->mac.orig_autoc |
+			                IXGBE_AUTOC_AN_RESTART));
+
+		if ((autoc2 & IXGBE_AUTOC2_UPPER_MASK) !=
+		    (hw->mac.orig_autoc2 & IXGBE_AUTOC2_UPPER_MASK)) {
+			autoc2 &= ~IXGBE_AUTOC2_UPPER_MASK;
+			autoc2 |= (hw->mac.orig_autoc2 &
+			           IXGBE_AUTOC2_UPPER_MASK);
+			IXGBE_WRITE_REG(hw, IXGBE_AUTOC2, autoc2);
+		}
+	}
+
+	/*
+	 * Store MAC address from RAR0, clear receive address registers, and
+	 * clear the multicast table.  Also reset num_rar_entries to 128,
+	 * since we modify this value when programming the SAN MAC address.
+	 */
+	hw->mac.num_rar_entries = 128;
+	hw->mac.ops.init_rx_addrs(hw);
+
+	/* Store the permanent mac address */
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
+
+	/* Store the permanent SAN mac address */
+	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
+
+	/* Add the SAN MAC address to the RAR only if it's a valid address */
+	if (ixgbe_validate_mac_addr(hw->mac.san_addr) == 0) {
+		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
+		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
+
+		/* Reserve the last RAR for the SAN MAC address */
+		hw->mac.num_rar_entries--;
+	}
+
+	/* Store the alternative WWNN/WWPN prefix */
+	hw->mac.ops.get_wwn_prefix(hw, &hw->mac.wwnn_prefix,
+	                           &hw->mac.wwpn_prefix);
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_supported_physical_layer_X540 - Returns physical layer type
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines physical layer capabilities of the current configuration.
+ **/
+static u32 ixgbe_get_supported_physical_layer_X540(struct ixgbe_hw *hw)
+{
+	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+	u16 ext_ability = 0;
+
+	hw->phy.ops.identify(hw);
+
+	hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
+			     &ext_ability);
+	if (ext_ability & MDIO_PMA_EXTABLE_10GBT)
+		physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
+	if (ext_ability & MDIO_PMA_EXTABLE_1000BT)
+		physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_T;
+	if (ext_ability & MDIO_PMA_EXTABLE_100BTX)
+		physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
+
+	return physical_layer;
+}
+
+/**
+ * ixgbe_init_eeprom_params_X540 - Initialize EEPROM params
+ * @hw: pointer to hardware structure
+ **/
+static s32 ixgbe_init_eeprom_params_X540(struct ixgbe_hw *hw)
+{
+	struct ixgbe_eeprom_info *eeprom = &hw->eeprom;
+	u32 eec;
+	u16 eeprom_size;
+
+	if (eeprom->type == ixgbe_eeprom_uninitialized) {
+		eeprom->semaphore_delay = 10;
+		eeprom->type = ixgbe_flash;
+
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+		eeprom_size = (u16)((eec & IXGBE_EEC_SIZE) >>
+		                    IXGBE_EEC_SIZE_SHIFT);
+		eeprom->word_size = 1 << (eeprom_size +
+		                          IXGBE_EEPROM_WORD_SIZE_SHIFT);
+
+		hw_dbg(hw, "Eeprom params: type = %d, size = %d\n",
+		        eeprom->type, eeprom->word_size);
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_read_eerd_X540 - Read EEPROM word using EERD
+ * @hw: pointer to hardware structure
+ * @offset: offset of word in the EEPROM to read
+ * @data: word read from the EERPOM
+ **/
+static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
+{
+	s32 status;
+
+	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM))
+		status = ixgbe_read_eerd_generic(hw, offset, data);
+	else
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	ixgbe_release_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM);
+	return status;
+}
+
+/**
+ * ixgbe_write_eewr_X540 - Write EEPROM word using EEWR
+ * @hw: pointer to hardware structure
+ * @offset: offset of  word in the EEPROM to write
+ * @data: word write to the EEPROM
+ *
+ * Write a 16 bit word to the EEPROM using the EEWR register.
+ **/
+static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
+{
+	u32 eewr;
+	s32 status;
+
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
+	eewr = (offset << IXGBE_EEPROM_RW_ADDR_SHIFT) |
+	       (data << IXGBE_EEPROM_RW_REG_DATA) |
+	       IXGBE_EEPROM_RW_REG_START;
+
+	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM)) {
+		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
+		if (status != 0) {
+			hw_dbg(hw, "Eeprom write EEWR timed out\n");
+			goto out;
+		}
+
+		IXGBE_WRITE_REG(hw, IXGBE_EEWR, eewr);
+
+		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
+		if (status != 0) {
+			hw_dbg(hw, "Eeprom write EEWR timed out\n");
+			goto out;
+		}
+	} else {
+		status = IXGBE_ERR_SWFW_SYNC;
+	}
+
+out:
+	ixgbe_release_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM);
+	return status;
+}
+
+/**
+ * ixgbe_calc_eeprom_checksum_X540 - Calculates and returns the checksum
+ * @hw: pointer to hardware structure
+ **/
+static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
+{
+	u16 i;
+	u16 j;
+	u16 checksum = 0;
+	u16 length = 0;
+	u16 pointer = 0;
+	u16 word = 0;
+
+	/* Include 0x0-0x3F in the checksum */
+	for (i = 0; i < IXGBE_EEPROM_CHECKSUM; i++) {
+		if (hw->eeprom.ops.read(hw, i, &word) != 0) {
+			hw_dbg(hw, "EEPROM read failed\n");
+			break;
+		}
+		checksum += word;
+	}
+
+	/*
+	 * Include all data from pointers 0x3, 0x6-0xE.  This excludes the
+	 * FW, PHY module, and PCIe Expansion/Option ROM pointers.
+	 */
+	for (i = IXGBE_PCIE_ANALOG_PTR; i < IXGBE_FW_PTR; i++) {
+		if (i == IXGBE_PHY_PTR || i == IXGBE_OPTION_ROM_PTR)
+			continue;
+
+		if (hw->eeprom.ops.read(hw, i, &pointer) != 0) {
+			hw_dbg(hw, "EEPROM read failed\n");
+			break;
+		}
+
+		/* Skip pointer section if the pointer is invalid. */
+		if (pointer == 0xFFFF || pointer == 0 ||
+		    pointer >= hw->eeprom.word_size)
+			continue;
+
+		if (hw->eeprom.ops.read(hw, pointer, &length) != 0) {
+			hw_dbg(hw, "EEPROM read failed\n");
+			break;
+		}
+
+		/* Skip pointer section if length is invalid. */
+		if (length == 0xFFFF || length == 0 ||
+		    (pointer + length) >= hw->eeprom.word_size)
+			continue;
+
+		for (j = pointer+1; j <= pointer+length; j++) {
+			if (hw->eeprom.ops.read(hw, j, &word) != 0) {
+				hw_dbg(hw, "EEPROM read failed\n");
+				break;
+			}
+			checksum += word;
+		}
+	}
+
+	checksum = (u16)IXGBE_EEPROM_SUM - checksum;
+
+	return checksum;
+}
+
+/**
+ * ixgbe_update_eeprom_checksum_X540 - Updates the EEPROM checksum and flash
+ * @hw: pointer to hardware structure
+ *
+ * After writing EEPROM to shadow RAM using EEWR register, software calculates
+ * checksum and updates the EEPROM and instructs the hardware to update
+ * the flash.
+ **/
+static s32 ixgbe_update_eeprom_checksum_X540(struct ixgbe_hw *hw)
+{
+	s32 status;
+
+	status = ixgbe_update_eeprom_checksum_generic(hw);
+
+	if (status)
+		status = ixgbe_update_flash_X540(hw);
+
+	return status;
+}
+
+/**
+ * ixgbe_update_flash_X540 - Instruct HW to copy EEPROM to Flash device
+ * @hw: pointer to hardware structure
+ *
+ * Set FLUP (bit 23) of the EEC register to instruct Hardware to copy
+ * EEPROM from shadow RAM to the flash device.
+ **/
+static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw)
+{
+	u32 flup;
+	s32 status = IXGBE_ERR_EEPROM;
+
+	status = ixgbe_poll_flash_update_done_X540(hw);
+	if (status == IXGBE_ERR_EEPROM) {
+		hw_dbg(hw, "Flash update time out\n");
+		goto out;
+	}
+
+	flup = IXGBE_READ_REG(hw, IXGBE_EEC) | IXGBE_EEC_FLUP;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, flup);
+
+	status = ixgbe_poll_flash_update_done_X540(hw);
+	if (status)
+		hw_dbg(hw, "Flash update complete\n");
+	else
+		hw_dbg(hw, "Flash update time out\n");
+
+	if (hw->revision_id == 0) {
+		flup = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		if (flup & IXGBE_EEC_SEC1VAL) {
+			flup |= IXGBE_EEC_FLUP;
+			IXGBE_WRITE_REG(hw, IXGBE_EEC, flup);
+		}
+
+		status = ixgbe_poll_flash_update_done_X540(hw);
+		if (status)
+			hw_dbg(hw, "Flash update complete\n");
+		else
+			hw_dbg(hw, "Flash update time out\n");
+
+	}
+out:
+	return status;
+}
+
+/**
+ * ixgbe_poll_flash_update_done_X540 - Poll flash update status
+ * @hw: pointer to hardware structure
+ *
+ * Polls the FLUDONE (bit 26) of the EEC Register to determine when the
+ * flash update is done.
+ **/
+static s32 ixgbe_poll_flash_update_done_X540(struct ixgbe_hw *hw)
+{
+	u32 i;
+	u32 reg;
+	s32 status = IXGBE_ERR_EEPROM;
+
+	for (i = 0; i < IXGBE_FLUDONE_ATTEMPTS; i++) {
+		reg = IXGBE_READ_REG(hw, IXGBE_EEC);
+		if (reg & IXGBE_EEC_FLUDONE) {
+			status = 0;
+			break;
+		}
+		udelay(5);
+	}
+	return status;
+}
+
+/**
+ * ixgbe_acquire_swfw_sync_X540 - Acquire SWFW semaphore
+ * @hw: pointer to hardware structure
+ * @mask: Mask to specify which semaphore to acquire
+ *
+ * Acquires the SWFW semaphore thought the SW_FW_SYNC register for
+ * the specified function (CSR, PHY0, PHY1, NVM, Flash)
+ **/
+static s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask)
+{
+	u32 swfw_sync;
+	u32 swmask = mask;
+	u32 fwmask = mask << 5;
+	u32 hwmask = 0;
+	u32 timeout = 200;
+	u32 i;
+
+	if (swmask == IXGBE_GSSR_EEP_SM)
+		hwmask = IXGBE_GSSR_FLASH_SM;
+
+	for (i = 0; i < timeout; i++) {
+		/*
+		 * SW NVM semaphore bit is used for access to all
+		 * SW_FW_SYNC bits (not just NVM)
+		 */
+		if (ixgbe_get_swfw_sync_semaphore(hw))
+			return IXGBE_ERR_SWFW_SYNC;
+
+		swfw_sync = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
+		if (!(swfw_sync & (fwmask | swmask | hwmask))) {
+			swfw_sync |= swmask;
+			IXGBE_WRITE_REG(hw, IXGBE_SWFW_SYNC, swfw_sync);
+			ixgbe_release_swfw_sync_semaphore(hw);
+			break;
+		} else {
+			/*
+			 * Firmware currently using resource (fwmask),
+			 * hardware currently using resource (hwmask),
+			 * or other software thread currently using
+			 * resource (swmask)
+			 */
+			ixgbe_release_swfw_sync_semaphore(hw);
+			msleep(5);
+		}
+	}
+
+	/*
+	 * If the resource is not released by the FW/HW the SW can assume that
+	 * the FW/HW malfunctions. In that case the SW should sets the
+	 * SW bit(s) of the requested resource(s) while ignoring the
+	 * corresponding FW/HW bits in the SW_FW_SYNC register.
+	 */
+	if (i >= timeout) {
+		swfw_sync = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
+		if (swfw_sync & (fwmask | hwmask)) {
+			if (ixgbe_get_swfw_sync_semaphore(hw))
+				return IXGBE_ERR_SWFW_SYNC;
+
+			swfw_sync |= swmask;
+			IXGBE_WRITE_REG(hw, IXGBE_SWFW_SYNC, swfw_sync);
+			ixgbe_release_swfw_sync_semaphore(hw);
+		}
+	}
+
+	msleep(5);
+	return 0;
+}
+
+/**
+ * ixgbe_release_swfw_sync_X540 - Release SWFW semaphore
+ * @hw: pointer to hardware structure
+ * @mask: Mask to specify which semaphore to release
+ *
+ * Releases the SWFW semaphore throught the SW_FW_SYNC register
+ * for the specified function (CSR, PHY0, PHY1, EVM, Flash)
+ **/
+static void ixgbe_release_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask)
+{
+	u32 swfw_sync;
+	u32 swmask = mask;
+
+	ixgbe_get_swfw_sync_semaphore(hw);
+
+	swfw_sync = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
+	swfw_sync &= ~swmask;
+	IXGBE_WRITE_REG(hw, IXGBE_SWFW_SYNC, swfw_sync);
+
+	ixgbe_release_swfw_sync_semaphore(hw);
+	msleep(5);
+}
+
+/**
+ * ixgbe_get_nvm_semaphore - Get hardware semaphore
+ * @hw: pointer to hardware structure
+ *
+ * Sets the hardware semaphores so SW/FW can gain control of shared resources
+ **/
+static s32 ixgbe_get_swfw_sync_semaphore(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_ERR_EEPROM;
+	u32 timeout = 2000;
+	u32 i;
+	u32 swsm;
+
+	/* Get SMBI software semaphore between device drivers first */
+	for (i = 0; i < timeout; i++) {
+		/*
+		 * If the SMBI bit is 0 when we read it, then the bit will be
+		 * set and we have the semaphore
+		 */
+		swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+		if (!(swsm & IXGBE_SWSM_SMBI)) {
+			status = 0;
+			break;
+		}
+		udelay(50);
+	}
+
+	/* Now get the semaphore between SW/FW through the REGSMP bit */
+	if (status) {
+		for (i = 0; i < timeout; i++) {
+			swsm = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
+			if (!(swsm & IXGBE_SWFW_REGSMP))
+				break;
+
+			udelay(50);
+		}
+	} else {
+		hw_dbg(hw, "Software semaphore SMBI between device drivers "
+		           "not granted.\n");
+	}
+
+	return status;
+}
+
+/**
+ * ixgbe_release_nvm_semaphore - Release hardware semaphore
+ * @hw: pointer to hardware structure
+ *
+ * This function clears hardware semaphore bits.
+ **/
+static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw)
+{
+	 u32 swsm;
+
+	/* Release both semaphores by writing 0 to the bits REGSMP and SMBI */
+
+	swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+	swsm &= ~IXGBE_SWSM_SMBI;
+	IXGBE_WRITE_REG(hw, IXGBE_SWSM, swsm);
+
+	swsm = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
+	swsm &= ~IXGBE_SWFW_REGSMP;
+	IXGBE_WRITE_REG(hw, IXGBE_SWFW_SYNC, swsm);
+
+	IXGBE_WRITE_FLUSH(hw);
+}
+
+static struct ixgbe_mac_operations mac_ops_X540 = {
+	.init_hw                = &ixgbe_init_hw_generic,
+	.reset_hw               = &ixgbe_reset_hw_X540,
+	.start_hw               = &ixgbe_start_hw_generic,
+	.clear_hw_cntrs         = &ixgbe_clear_hw_cntrs_generic,
+	.get_media_type         = &ixgbe_get_media_type_X540,
+	.get_supported_physical_layer =
+                                  &ixgbe_get_supported_physical_layer_X540,
+	.enable_rx_dma          = &ixgbe_enable_rx_dma_generic,
+	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
+	.get_san_mac_addr       = &ixgbe_get_san_mac_addr_generic,
+	.get_device_caps        = NULL,
+	.get_wwn_prefix         = &ixgbe_get_wwn_prefix_generic,
+	.stop_adapter           = &ixgbe_stop_adapter_generic,
+	.get_bus_info           = &ixgbe_get_bus_info_generic,
+	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
+	.read_analog_reg8       = NULL,
+	.write_analog_reg8      = NULL,
+	.setup_link             = &ixgbe_setup_mac_link_X540,
+	.check_link             = &ixgbe_check_mac_link_generic,
+	.get_link_capabilities  = &ixgbe_get_copper_link_capabilities_generic,
+	.led_on                 = &ixgbe_led_on_generic,
+	.led_off                = &ixgbe_led_off_generic,
+	.blink_led_start        = &ixgbe_blink_led_start_generic,
+	.blink_led_stop         = &ixgbe_blink_led_stop_generic,
+	.set_rar                = &ixgbe_set_rar_generic,
+	.clear_rar              = &ixgbe_clear_rar_generic,
+	.set_vmdq               = &ixgbe_set_vmdq_generic,
+	.clear_vmdq             = &ixgbe_clear_vmdq_generic,
+	.init_rx_addrs          = &ixgbe_init_rx_addrs_generic,
+	.update_uc_addr_list    = &ixgbe_update_uc_addr_list_generic,
+	.update_mc_addr_list    = &ixgbe_update_mc_addr_list_generic,
+	.enable_mc              = &ixgbe_enable_mc_generic,
+	.disable_mc             = &ixgbe_disable_mc_generic,
+	.clear_vfta             = &ixgbe_clear_vfta_generic,
+	.set_vfta               = &ixgbe_set_vfta_generic,
+	.fc_enable              = &ixgbe_fc_enable_generic,
+	.init_uta_tables        = &ixgbe_init_uta_tables_generic,
+	.setup_sfp              = NULL,
+};
+
+static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
+	.init_params            = &ixgbe_init_eeprom_params_X540,
+	.read                   = &ixgbe_read_eerd_X540,
+	.write                  = &ixgbe_write_eewr_X540,
+	.calc_checksum		= &ixgbe_calc_eeprom_checksum_X540,
+	.validate_checksum      = &ixgbe_validate_eeprom_checksum_generic,
+	.update_checksum        = &ixgbe_update_eeprom_checksum_X540,
+};
+
+static struct ixgbe_phy_operations phy_ops_X540 = {
+	.identify               = &ixgbe_identify_phy_generic,
+	.identify_sfp           = &ixgbe_identify_sfp_module_generic,
+	.init			= NULL,
+	.reset                  = &ixgbe_reset_phy_generic,
+	.read_reg               = &ixgbe_read_phy_reg_generic,
+	.write_reg              = &ixgbe_write_phy_reg_generic,
+	.setup_link             = &ixgbe_setup_phy_link_generic,
+	.setup_link_speed       = &ixgbe_setup_phy_link_speed_generic,
+	.read_i2c_byte          = &ixgbe_read_i2c_byte_generic,
+	.write_i2c_byte         = &ixgbe_write_i2c_byte_generic,
+	.read_i2c_eeprom        = &ixgbe_read_i2c_eeprom_generic,
+	.write_i2c_eeprom       = &ixgbe_write_i2c_eeprom_generic,
+	.check_overtemp         = &ixgbe_tn_check_overtemp,
+};
+
+struct ixgbe_info ixgbe_X540_info = {
+	.mac                    = ixgbe_mac_X540,
+	.get_invariants         = &ixgbe_get_invariants_X540,
+	.mac_ops                = &mac_ops_X540,
+	.eeprom_ops             = &eeprom_ops_X540,
+	.phy_ops                = &phy_ops_X540,
+	.mbx_ops                = &mbx_ops_generic,
+};
diff --git a/drivers/net/ixgbevf/Makefile b/drivers/net/ixgbevf/Makefile
index dd4e0d2..1f35d22 100644
--- a/drivers/net/ixgbevf/Makefile
+++ b/drivers/net/ixgbevf/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 82599 Virtual Function driver
-# Copyright(c) 1999 - 2009 Intel Corporation.
+# Copyright(c) 1999 - 2010 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ixgbevf/defines.h
index ca2c81f..f8a807d 100644
--- a/drivers/net/ixgbevf/defines.h
+++ b/drivers/net/ixgbevf/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index da4033c..0cd6abc 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index dc03c96..5b8063c 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -51,9 +51,10 @@ char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 82599 Virtual Function";
 
-#define DRV_VERSION "1.0.0-k0"
+#define DRV_VERSION "1.0.12-k0"
 const char ixgbevf_driver_version[] = DRV_VERSION;
-static char ixgbevf_copyright[] = "Copyright (c) 2009 Intel Corporation.";
+static char ixgbevf_copyright[] =
+	"Copyright (c) 2009 - 2010 Intel Corporation.";
 
 static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 	[board_82599_vf] = &ixgbevf_vf_info,
@@ -3424,10 +3425,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	if (hw->mac.ops.get_bus_info)
 		hw->mac.ops.get_bus_info(hw);
 
-
-	netif_carrier_off(netdev);
-	netif_tx_stop_all_queues(netdev);
-
 	strcpy(netdev->name, "eth%d");
 
 	err = register_netdev(netdev);
@@ -3436,6 +3433,8 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 
 	adapter->netdev_registered = true;
 
+	netif_carrier_off(netdev);
+
 	ixgbevf_init_last_counter_stats(adapter);
 
 	/* print the MAC address */
diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/ixgbevf/mbx.c
index 84ac486..7a88331 100644
--- a/drivers/net/ixgbevf/mbx.c
+++ b/drivers/net/ixgbevf/mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/mbx.h b/drivers/net/ixgbevf/mbx.h
index 8c063be..b2b5bf5 100644
--- a/drivers/net/ixgbevf/mbx.h
+++ b/drivers/net/ixgbevf/mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/regs.h b/drivers/net/ixgbevf/regs.h
index 12f7596..fb80ca1 100644
--- a/drivers/net/ixgbevf/regs.h
+++ b/drivers/net/ixgbevf/regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index bfe42c1..971019d 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
index 61f9dc8..144c99d 100644
--- a/drivers/net/ixgbevf/vf.h
+++ b/drivers/net/ixgbevf/vf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2009 Intel Corporation.
+  Copyright(c) 1999 - 2010 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,


