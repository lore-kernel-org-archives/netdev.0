From: David Fries <david@fries.net>
Subject: [PATCH 2/2] ne.c msleep not mdelay
Date: Fri, 29 Aug 2008 21:44:53 -0500
Message-ID: <20080830024453.GB24929@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:37602 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbYH3Co7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 22:44:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdelay(10) replaced by msleep(10) to give up the CPU, it's just
waiting for an interrupt, so timing isn't critical.

Signed-off-by: David Fries <david@fries.net>
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>
---
 drivers/net/ne.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index b0bf47e..bcbeff7 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -529,7 +529,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		outb_p(0x00, ioaddr + EN0_RCNTLO);
 		outb_p(0x00, ioaddr + EN0_RCNTHI);
 		outb_p(E8390_RREAD+E8390_START, ioaddr); /* Trigger it... */
-		mdelay(10);	/* wait 10ms for interrupt to propagate */
+		msleep(10);	/* wait 10ms for interrupt to propagate */
 		outb_p(0x00, ioaddr + EN0_IMR); 		/* Mask it again. */
 		dev->irq = probe_irq_off(cookie);
 		if (ei_debug > 2)
-- 
1.4.4.4

