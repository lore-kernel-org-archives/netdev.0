From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/6] tc35815: Statistics cleanup
Date: Sun, 13 Apr 2008 00:11:46 +0900 (JST)
Message-ID: <20080413.001146.25909265.anemo@mba.ocn.ne.jp>
References: <20080411.002412.03977557.anemo@mba.ocn.ne.jp>
	<48007A41.2000803@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: jeff@garzik.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:65465 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712AbYDLPK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 11:10:56 -0400
In-Reply-To: <48007A41.2000803@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Apr 2008 05:00:49 -0400, Jeff Garzik <jeff@garzik.org> wrote:
> applied 1-6

Thanks.

Could you apply this too, or hopufully fold into Andy Fleming's "phy:
Change mii_bus id field to a string" patch (commit c69fedae) ?

------------------------------------------------------
Subject: [PATCH] tc35815: build fix

Fix build failure caused by Andy Fleming's "phy: Change mii_bus id
field to a string" patch.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 744f11f..10e4e85 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -766,7 +766,8 @@ static int tc_mii_init(struct net_device *dev)
 	lp->mii_bus.name = "tc35815_mii_bus";
 	lp->mii_bus.read = tc_mdio_read;
 	lp->mii_bus.write = tc_mdio_write;
-	lp->mii_bus.id = (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn;
+	snprintf(lp->mii_bus.id, MII_BUS_ID_SIZE, "%x",
+		 (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
 	lp->mii_bus.priv = dev;
 	lp->mii_bus.dev = &lp->pci_dev->dev;
 	lp->mii_bus.irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
