From: Michael Buesch <mb@bu3sch.de>
Subject: Re: BUG in bcm32xx-d80211: sleeping function called with irq's disabled
Date: Sun, 3 Sep 2006 14:49:16 +0200
Message-ID: <200609031449.16702.mb@bu3sch.de>
References: <44FA4F42.1020302@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57262
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750988AbWICMuC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 08:50:02 -0400
To: linville@tuxdriver.com
In-Reply-To: <44FA4F42.1020302@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 03 September 2006 05:42, Larry Finger wrote:
> The latest git pull from wireless-dev (g7844a579) is calling a sleeping function with irq's
> disabled. The kernel is a UP version with preemption disabled. The dump is as follows:
> 
> kernel: bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 4, MAC: 00:06:25:40:6f:03)
> kernel: bcm43xx_d80211: PHY connected
> kernel: BUG: sleeping function called from invalid context at kernel/mutex.c:86
> kernel: in_atomic():0, irqs_disabled():1
> kernel:  [<c0103b67>] show_trace_log_lvl+0x197/0x1c0
> kernel:  [<c0104f7b>] show_trace+0x1b/0x20
> kernel:  [<c0104fa6>] dump_stack+0x26/0x30
> kernel:  [<c0113382>] __might_sleep+0xa2/0xc0
> kernel:  [<c031347d>] mutex_lock+0x1d/0x30
> kernel:  [<e791c72a>] ssb_core_is_enabled+0x1a/0x50 [ssb]
> kernel:  [<e7b2797d>] bcm43xx_wireless_core_reset+0x1d/0xc0 [bcm43xx_d80211]
> kernel:  [<e7b3bd74>] bcm43xx_phy_calibrate+0x74/0xe0 [bcm43xx_d80211]
> kernel:  [<e7b2bbdb>] wireless_core_up+0x5b/0x700 [bcm43xx_d80211]
> kernel:  [<e7b2c98a>] bcm43xx_select_wireless_core+0x22a/0x8c0 [bcm43xx_d80211]
> kernel:  [<e7b2d0a4>] bcm43xx_init_board+0x84/0xb0 [bcm43xx_d80211]
> kernel:  [<e7b2d1a6>] bcm43xx_net_open+0x16/0x20 [bcm43xx_d80211]
> kernel:  [<e79481c5>] ieee80211_open+0x175/0x360 [80211]
> kernel:  [<c02c2233>] dev_open+0x43/0x90
> kernel:  [<c02c11c5>] dev_change_flags+0x55/0x130
> kernel:  [<c03006af>] devinet_ioctl+0x65f/0x6d0
> kernel:  [<c0300a18>] inet_ioctl+0x88/0xb0
> kernel:  [<c02b64cb>] sock_ioctl+0xbb/0x260
> kernel:  [<c01718db>] do_ioctl+0x2b/0x80
> kernel:  [<c0171981>] vfs_ioctl+0x51/0x290
> kernel:  [<c0171c01>] sys_ioctl+0x41/0x60
> kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d
> kernel:  [<b7f35410>] 0xb7f35410
> kernel:  [<c0104f7b>] show_trace+0x1b/0x20
> kernel:  [<c0104fa6>] dump_stack+0x26/0x30
> kernel:  [<c0113382>] __might_sleep+0xa2/0xc0
> kernel:  [<c031347d>] mutex_lock+0x1d/0x30
> kernel:  [<e791c72a>] ssb_core_is_enabled+0x1a/0x50 [ssb]
> kernel:  [<e7b2797d>] bcm43xx_wireless_core_reset+0x1d/0xc0 [bcm43xx_d80211]
> kernel:  [<e7b3bd74>] bcm43xx_phy_calibrate+0x74/0xe0 [bcm43xx_d80211]
> kernel:  [<e7b2bbdb>] wireless_core_up+0x5b/0x700 [bcm43xx_d80211]
> kernel:  [<e7b2c98a>] bcm43xx_select_wireless_core+0x22a/0x8c0 [bcm43xx_d80211]
> kernel:  [<e7b2d0a4>] bcm43xx_init_board+0x84/0xb0 [bcm43xx_d80211]
> kernel:  [<e7b2d1a6>] bcm43xx_net_open+0x16/0x20 [bcm43xx_d80211]
> kernel:  [<e79481c5>] ieee80211_open+0x175/0x360 [80211]
> kernel:  [<c02c2233>] dev_open+0x43/0x90
> kernel:  [<c02c11c5>] dev_change_flags+0x55/0x130
> kernel:  [<c03006af>] devinet_ioctl+0x65f/0x6d0
> kernel:  [<c0300a18>] inet_ioctl+0x88/0xb0
> kernel:  [<c02b64cb>] sock_ioctl+0xbb/0x260
> kernel:  [<c01718db>] do_ioctl+0x2b/0x80
> kernel:  [<c0171981>] vfs_ioctl+0x51/0x290
> kernel:  [<c0171c01>] sys_ioctl+0x41/0x60
> kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d
> kernel: bcm43xx_d80211: PHY disconnected

John, please apply the following patch to wireless-dev.
(And please apply all the other patches, too, as I'm still
waiting to pull ;) )

--

Don't disable IRQs in PHY init.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-08-24 22:18:03.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-09-03 14:39:41.000000000 +0200
@@ -133,22 +133,14 @@ void bcm43xx_phy_write(struct bcm43xx_pr
 void bcm43xx_phy_calibrate(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	unsigned long flags;
 
 	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* Dummy read. */
 	if (phy->calibrated)
 		return;
 	if (phy->type == BCM43xx_PHYTYPE_G && phy->rev == 1) {
-		/* We do not want to be preempted while calibrating
-		 * the hardware.
-		 */
-		local_irq_save(flags);
-
 		bcm43xx_wireless_core_reset(bcm, 0);
 		bcm43xx_phy_initg(bcm);
 		bcm43xx_wireless_core_reset(bcm, 1);
-
-		local_irq_restore(flags);
 	}
 	phy->calibrated = 1;
 }
@@ -2190,12 +2182,6 @@ int bcm43xx_phy_init(struct bcm43xx_priv
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err = -ENODEV;
-	unsigned long flags;
-
-	/* We do not want to be preempted while calibrating
-	 * the hardware.
-	 */
-	local_irq_save(flags);
 
 	switch (phy->type) {
 	case BCM43xx_PHYTYPE_A:
@@ -2229,7 +2215,6 @@ int bcm43xx_phy_init(struct bcm43xx_priv
 		err = 0;
 		break;
 	}
-	local_irq_restore(flags);
 	if (err)
 		printk(KERN_WARNING PFX "Unknown PHYTYPE found!\n");
 


-- 
Greetings Michael.

-- 
VGER BF report: U 0.911121
