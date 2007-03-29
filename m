From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-MM GIT PULL] e1000: fixes, API rewrite, cleanups
Date: Thu, 29 Mar 2007 16:57:39 -0700
Message-ID: <20070329165739.04003147.akpm@linux-foundation.org>
References: <20070329225815.C977F40951@ahkok-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, john.ronciak@intel.com,
	arjan@linux.intel.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43574 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359AbXC2X5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 19:57:45 -0400
In-Reply-To: <20070329225815.C977F40951@ahkok-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu Mar 29 15:50:55 PDT 2007
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> Please consider pulling from my git tree:
>     git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 mm
> 
> To get a copy of my current e1000 queue. This tree consists of a recent
> 'master' branch from linus, and the following patches:
> 
> 1) 3 patches from jgarzik's e1000-fixes tree
> 2) 3 patches from jgarzik's upstream branch
> 3) the hardware initialization API rewrite (as a single commit) patch
>      posted on netdev yesterday
> 4) 15 other fixes and cleanups currently in my e1000 queue

OK.  I got quite a lot of git carnage when generating the git-netdev-all
versus git-e1000 diff.  But as long as things don't change too much we
should be OK.

What I do when this happens is to manually create a remove-the-git-rejects
patch.  Hope I got it right..

Davem's tree diddles e1000_main.c as well, so whoever merges second has
a little bit of rework to do.

The current davem diff is 2.2MB, touching 852 files.  Nobody breathe...



 drivers/net/e1000/e1000_ethtool.c |    5 -
 drivers/net/e1000/e1000_main.c    |   91 ----------------------------
 2 files changed, 96 deletions(-)

diff -puN drivers/net/e1000/e1000_ethtool.c~git-e1000-fixup drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c~git-e1000-fixup
+++ a/drivers/net/e1000/e1000_ethtool.c
@@ -1046,13 +1046,8 @@ e1000_setup_desc_rings(struct e1000_adap
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
-<<<<<<< HEAD/drivers/net/e1000/e1000_ethtool.c
-	uint32_t rctl;
-	int i, ret_val;
-=======
 	u32 rctl;
 	int i, ret_val;
->>>>>>> /drivers/net/e1000/e1000_ethtool.c
 
 	/* Setup Tx descriptor ring and Tx buffers */
 
diff -puN drivers/net/e1000/e1000_main.c~git-e1000-fixup drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~git-e1000-fixup
+++ a/drivers/net/e1000/e1000_main.c
@@ -425,42 +425,22 @@ e1000_update_mng_vlan(struct e1000_adapt
 static void
 e1000_release_hw_control(struct e1000_adapter *adapter)
 {
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	uint32_t ctrl_ext;
-	uint32_t swsm;
-=======
 	u32 ctrl_ext;
 	u32 swsm;
->>>>>>> /drivers/net/e1000/e1000_main.c
 
 	/* Let firmware taken over control of h/w */
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	switch (adapter->hw.mac_type) {
-	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
-				swsm & ~E1000_SWSM_DRV_LOAD);
-		break;
-=======
 	switch (adapter->hw.mac.type) {
 	case e1000_82573:
 		swsm = E1000_READ_REG(&adapter->hw, E1000_SWSM);
 		E1000_WRITE_REG(&adapter->hw, E1000_SWSM,
 				swsm & ~E1000_SWSM_DRV_LOAD);
 		break;
->>>>>>> /drivers/net/e1000/e1000_main.c
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	case e1000_ich8lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-=======
 	case e1000_ich8lan:
 		ctrl_ext = E1000_READ_REG(&adapter->hw, E1000_CTRL_EXT);
 		E1000_WRITE_REG(&adapter->hw, E1000_CTRL_EXT,
->>>>>>> /drivers/net/e1000/e1000_main.c
 				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
@@ -482,42 +462,22 @@ e1000_release_hw_control(struct e1000_ad
 static void
 e1000_get_hw_control(struct e1000_adapter *adapter)
 {
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	uint32_t ctrl_ext;
-	uint32_t swsm;
-=======
 	u32 ctrl_ext;
 	u32 swsm;
->>>>>>> /drivers/net/e1000/e1000_main.c
 
 	/* Let firmware know the driver has taken over */
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	switch (adapter->hw.mac_type) {
-	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
-				swsm | E1000_SWSM_DRV_LOAD);
-		break;
-=======
 	switch (adapter->hw.mac.type) {
 	case e1000_82573:
 		swsm = E1000_READ_REG(&adapter->hw, E1000_SWSM);
 		E1000_WRITE_REG(&adapter->hw, E1000_SWSM,
 				swsm | E1000_SWSM_DRV_LOAD);
 		break;
->>>>>>> /drivers/net/e1000/e1000_main.c
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	case e1000_ich8lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-=======
 	case e1000_ich8lan:
 		ctrl_ext = E1000_READ_REG(&adapter->hw, E1000_CTRL_EXT);
 		E1000_WRITE_REG(&adapter->hw, E1000_CTRL_EXT,
->>>>>>> /drivers/net/e1000/e1000_main.c
 				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
@@ -571,19 +531,11 @@ e1000_release_manageability(struct e1000
 	}
 }
 
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-/**
- * e1000_configure - configure the hardware for RX and TX
- * @adapter = private board structure
- **/
-static void e1000_configure(struct e1000_adapter *adapter)
-=======
 /**
  * e1000_configure - configure the hardware for RX and TX
  * @adapter: private board structure
  **/
 static void e1000_configure(struct e1000_adapter *adapter)
->>>>>>> /drivers/net/e1000/e1000_main.c
 {
 	struct net_device *netdev = adapter->netdev;
 	int i;
@@ -705,11 +657,6 @@ e1000_down(struct e1000_adapter *adapter
 	 * reschedule our watchdog timer */
 	set_bit(__E1000_DOWN, &adapter->flags);
 
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_disable(netdev);
-#endif
-=======
 	/* disable receives in the hardware */
 	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
@@ -728,7 +675,6 @@ e1000_down(struct e1000_adapter *adapter
 #ifdef CONFIG_E1000_NAPI
 	netif_poll_disable(netdev);
 #endif
->>>>>>> /drivers/net/e1000/e1000_main.c
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
@@ -1534,30 +1480,6 @@ e1000_open(struct net_device *netdev)
 	    e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	/* before we allocate an interrupt, we must be ready to handle it.
-	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
-	 * as soon as we call pci_request_irq, so we have to setup our
-	 * clean_rx handler before we do so.  */
-	e1000_configure(adapter);
-
-	err = e1000_request_irq(adapter);
-	if (err)
-		goto err_req_irq;
-
-	/* From here on the code is the same as e1000_up() */
-	clear_bit(__E1000_DOWN, &adapter->flags);
-
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
-#endif
-
-	e1000_irq_enable(adapter);
-
-	/* fire a link status change interrupt to start the watchdog */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
-
-=======
 	/* before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
 	 * as soon as we call pci_request_irq, so we have to setup our
@@ -1580,7 +1502,6 @@ e1000_open(struct net_device *netdev)
 	/* fire a link status change interrupt to start the watchdog */
 	E1000_WRITE_REG(&adapter->hw, E1000_ICS, E1000_ICS_LSC);
 
->>>>>>> /drivers/net/e1000/e1000_main.c
 	return E1000_SUCCESS;
 
 err_req_irq:
@@ -2799,13 +2720,9 @@ e1000_watchdog_task(struct work_struct *
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
-=======
 			if (!test_bit(__E1000_DOWN, &adapter->flags))
 				mod_timer(&adapter->phy_info_timer,
 				          round_jiffies(jiffies + 2 * HZ));
->>>>>>> /drivers/net/e1000/e1000_main.c
 			adapter->smartspeed = 0;
 		} else {
 			/* make sure the receive unit is started */
@@ -2822,13 +2739,9 @@ e1000_watchdog_task(struct work_struct *
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
-=======
 			if (!test_bit(__E1000_DOWN, &adapter->flags))
 				mod_timer(&adapter->phy_info_timer,
 				          round_jiffies(jiffies + 2 * HZ));
->>>>>>> /drivers/net/e1000/e1000_main.c
 
 			/* 80003ES2LAN workaround--
 			 * For packet buffer work-around on link down event;
@@ -2881,13 +2794,9 @@ link_up:
 		e1000_rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
 
 	/* Reset the timer */
-<<<<<<< HEAD/drivers/net/e1000/e1000_main.c
-	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
-=======
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		mod_timer(&adapter->watchdog_timer,
 		          round_jiffies(jiffies + 2 * HZ));
->>>>>>> /drivers/net/e1000/e1000_main.c
 }
 
 enum latency_range {
_

