From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: Crash after reloading driver if network hangs
Date: Sun, 28 Jan 2007 20:04:48 +0100
Message-ID: <20070128190448.GA23060@electric-eye.fr.zoreil.com>
References: <20070128180221.GB2285@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37290 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932737AbXA1TIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jan 2007 14:08:36 -0500
Received: from electric-eye.fr.zoreil.com (localhost.localdomain [127.0.0.1])
	by fr.zoreil.com (8.13.4/8.12.1) with ESMTP id l0SJ4mgB026805
	for <netdev@vger.kernel.org>; Sun, 28 Jan 2007 20:04:48 +0100
Received: (from romieu@localhost)
	by electric-eye.fr.zoreil.com (8.13.4/8.12.1) id l0SJ4mrk026804
	for netdev@vger.kernel.org; Sun, 28 Jan 2007 20:04:48 +0100
Content-Disposition: inline
In-Reply-To: <20070128180221.GB2285@strauss.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernhard Walle <bwalle@suse.de> :
[...]
> Simple fix is attached. Although that seems to fix the symptom and not
> the cause, please apply it if you don't have a better solution.

What about the patch below ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 577babd..4e22af7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1373,7 +1373,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
 	timer->data = (unsigned long)(dev);
 	timer->function = rtl8169_phy_timer;
-	add_timer(timer);
+	mod_timer(timer);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1448,7 +1448,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	rtl8169_phy_reset(dev, tp);
 
-	rtl8169_set_speed(dev, autoneg, speed, duplex);
+	tp->set_speed(dev, autoneg, speed, duplex);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
