From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] sky2: PCI irq issues
Date: Wed, 17 Jun 2009 10:30:34 -0700
Message-ID: <20090617173139.699221446@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45309 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758042AbZFQReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:03 -0400
Content-Disposition: inline; filename=sky2-irqpost.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some read's to avoid any PCI posting issues when controlling
irq's.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-17 10:29:52.005685817 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:53.382997969 -0700
@@ -1495,6 +1495,7 @@ static int sky2_up(struct net_device *de
 	imask = sky2_read32(hw, B0_IMSK);
 	imask |= portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
+	sky2_read32(hw, B0_IMSK);
 
 	sky2_set_multicast(dev);
 
@@ -1812,6 +1813,7 @@ static int sky2_down(struct net_device *
 	imask = sky2_read32(hw, B0_IMSK);
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
+	sky2_read32(hw, B0_IMSK);
 
 	synchronize_irq(hw->pdev->irq);
 

-- 

