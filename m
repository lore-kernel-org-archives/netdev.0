From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/3] via-velocity : cleanups.
Date: Thu, 4 Aug 2011 14:39:03 +0200
Message-ID: <20110804123903.GC14858@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jon Nelson <jnelson@jamponi.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45267 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416Ab1HDMz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 08:55:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- empty lines
- tabs / spaces
- ETHTOOL_GWOL _is_ defined
- useless cast from void *

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |   71 +++++++++++++++----------------------------
 1 files changed, 25 insertions(+), 46 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 27bcd3b..490ec5b 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -42,7 +42,6 @@
  *
  */
 
-
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/bitops.h>
@@ -112,7 +111,6 @@ static void mac_get_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
 	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
 }
 
-
 /**
  *	mac_set_cam_mask	-	Set a CAM mask
  *	@regs: register block for this velocity
@@ -700,7 +698,6 @@ static int velocity_mii_read(struct mac_regs __iomem *regs, u8 index, u16 *data)
 	return 0;
 }
 
-
 /**
  *	mii_check_media_mode	-	check media state
  *	@regs: velocity registers
@@ -866,8 +863,6 @@ static u32 check_connection_type(struct mac_regs __iomem *regs)
 	return status;
 }
 
-
-
 /**
  *	velocity_set_media_mode		-	set media mode
  *	@mii_status: old MII link state
@@ -1262,6 +1257,7 @@ static void setup_queue_timers(struct velocity_info *vptr)
 		writeb(rxqueue_timer, &vptr->mac_regs->RQETMR);
 	}
 }
+
 /**
  * setup_adaptive_interrupts  -  Setup interrupt suppression
  *
@@ -1601,8 +1597,6 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 	vptr->rx.info = NULL;
 }
 
-
-
 /**
  *	velocity_init_rd_ring	-	set up receive ring
  *	@vptr: velocity to configure
@@ -1676,7 +1670,6 @@ static void velocity_free_dma_rings(struct velocity_info *vptr)
 	pci_free_consistent(vptr->pdev, size, vptr->rx.ring, vptr->rx.pool_dma);
 }
 
-
 static int velocity_init_rings(struct velocity_info *vptr, int mtu)
 {
 	int ret;
@@ -1739,7 +1732,6 @@ static void velocity_free_tx_buf(struct velocity_info *vptr,
 	tdinfo->skb = NULL;
 }
 
-
 /*
  *	FIXME: could we merge this with velocity_free_tx_buf ?
  */
@@ -1787,7 +1779,6 @@ static void velocity_free_td_ring(struct velocity_info *vptr)
 	}
 }
 
-
 static void velocity_free_rings(struct velocity_info *vptr)
 {
 	velocity_free_td_ring(vptr);
@@ -2025,7 +2016,6 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
 	}
 }
 
-
 /**
  *	velocity_receive_frame	-	received packet processor
  *	@vptr: velocity we are handling
@@ -2097,7 +2087,6 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	return 0;
 }
 
-
 /**
  *	velocity_rx_srv		-	service RX interrupt
  *	@vptr: velocity
@@ -2405,7 +2394,6 @@ static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd
 	return 0;
 }
 
-
 /**
  *	velocity_ioctl		-	ioctl entry point
  *	@dev: network device
@@ -2620,14 +2608,13 @@ out:
 	return NETDEV_TX_OK;
 }
 
-
 static const struct net_device_ops velocity_netdev_ops = {
 	.ndo_open		= velocity_open,
 	.ndo_stop		= velocity_close,
 	.ndo_start_xmit		= velocity_xmit,
 	.ndo_get_stats		= velocity_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_multicast_list	= velocity_set_multi,
 	.ndo_change_mtu		= velocity_change_mtu,
 	.ndo_do_ioctl		= velocity_ioctl,
@@ -2718,7 +2705,6 @@ static u32 velocity_get_link(struct net_device *dev)
 	return BYTE_REG_BITS_IS_ON(PHYSR0_LINKGD, &regs->PHYSR0) ? 1 : 0;
 }
 
-
 /**
  *	velocity_found1		-	set up discovered velocity card
  *	@pdev: PCI device
@@ -2865,7 +2851,6 @@ err_free_dev:
 	goto out;
 }
 
-
 #ifdef CONFIG_PM
 /**
  *	wol_calc_crc		-	WOL CRC
@@ -3036,7 +3021,7 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	spin_lock_irqsave(&vptr->lock, flags);
 	pci_save_state(pdev);
-#ifdef ETHTOOL_GWOL
+
 	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED) {
 		velocity_get_ip(vptr);
 		velocity_save_context(vptr, &vptr->context);
@@ -3050,9 +3035,7 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_disable_device(pdev);
 		pci_set_power_state(pdev, pci_choose_state(pdev, state));
 	}
-#else
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-#endif
+
 	spin_unlock_irqrestore(&vptr->lock, flags);
 	return 0;
 }
@@ -3133,13 +3116,13 @@ static int velocity_resume(struct pci_dev *pdev)
  *	uses this to handle all our card discover and plugging
  */
 static struct pci_driver velocity_driver = {
-      .name	= VELOCITY_NAME,
-      .id_table	= velocity_id_table,
-      .probe	= velocity_found1,
-      .remove	= __devexit_p(velocity_remove1),
+	.name		= VELOCITY_NAME,
+	.id_table	= velocity_id_table,
+	.probe		= velocity_found1,
+	.remove		= __devexit_p(velocity_remove1),
 #ifdef CONFIG_PM
-      .suspend	= velocity_suspend,
-      .resume	= velocity_resume,
+	.suspend	= velocity_suspend,
+	.resume		= velocity_resume,
 #endif
 };
 
@@ -3521,28 +3504,27 @@ static void velocity_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops velocity_ethtool_ops = {
-	.get_settings	=	velocity_get_settings,
-	.set_settings	=	velocity_set_settings,
-	.get_drvinfo	=	velocity_get_drvinfo,
-	.get_wol	=	velocity_ethtool_get_wol,
-	.set_wol	=	velocity_ethtool_set_wol,
-	.get_msglevel	=	velocity_get_msglevel,
-	.set_msglevel	=	velocity_set_msglevel,
-	.get_link	=	velocity_get_link,
+	.get_settings		= velocity_get_settings,
+	.set_settings		= velocity_set_settings,
+	.get_drvinfo		= velocity_get_drvinfo,
+	.get_wol		= velocity_ethtool_get_wol,
+	.set_wol		= velocity_ethtool_set_wol,
+	.get_msglevel		= velocity_get_msglevel,
+	.set_msglevel		= velocity_set_msglevel,
+	.get_link		= velocity_get_link,
 	.get_strings		= velocity_get_strings,
 	.get_sset_count		= velocity_get_sset_count,
 	.get_ethtool_stats	= velocity_get_ethtool_stats,
-	.get_coalesce	=	velocity_get_coalesce,
-	.set_coalesce	=	velocity_set_coalesce,
-	.begin		=	velocity_ethtool_up,
-	.complete	=	velocity_ethtool_down
+	.get_coalesce		= velocity_get_coalesce,
+	.set_coalesce		= velocity_set_coalesce,
+	.begin			= velocity_ethtool_up,
+	.complete		= velocity_ethtool_down
 };
 
-#ifdef CONFIG_PM
-#ifdef CONFIG_INET
+#if defined(CONFIG_PM) && defined(CONFIG_INET)
 static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr)
 {
-	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
+	struct in_ifaddr *ifa = ptr;
 	struct net_device *dev = ifa->ifa_dev->dev;
 
 	if (dev_net(dev) == &init_net &&
@@ -3551,12 +3533,9 @@ static int velocity_netdev_event(struct notifier_block *nb, unsigned long notifi
 
 	return NOTIFY_DONE;
 }
-#endif	/* CONFIG_INET */
-#endif	/* CONFIG_PM */
 
-#if defined(CONFIG_PM) && defined(CONFIG_INET)
 static struct notifier_block velocity_inetaddr_notifier = {
-      .notifier_call	= velocity_netdev_event,
+	.notifier_call	= velocity_netdev_event,
 };
 
 static void velocity_register_notifier(void)
-- 
1.7.4.4

