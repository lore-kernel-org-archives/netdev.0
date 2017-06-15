From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 09/11] net: mvmdio: simplify the smi read and write error paths
Date: Thu, 15 Jun 2017 16:43:24 +0200
Message-ID: <20170615144326.24463-10-antoine.tenart@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34854 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752651AbdFOOoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:05 -0400
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic patch simplifying the smi read and write error paths. It also
align their error paths with the ones of the xsmi functions.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 0888e50f6b17..c9798210fa0f 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -149,7 +149,7 @@ static int orion_mdio_smi_read(struct mii_bus *bus, int mii_id,
 
 	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
-		goto out;
+		return ret;
 
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
@@ -158,18 +158,15 @@ static int orion_mdio_smi_read(struct mii_bus *bus, int mii_id,
 
 	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
-		goto out;
+		return ret;
 
 	val = readl(dev->regs);
 	if (!(val & MVMDIO_SMI_READ_VALID)) {
 		dev_err(bus->parent, "SMI bus read not valid\n");
-		ret = -ENODEV;
-		goto out;
+		return -ENODEV;
 	}
 
-	ret = val & GENMASK(15, 0);
-out:
-	return ret;
+	return val & GENMASK(15, 0);
 }
 
 static int orion_mdio_smi_write(struct mii_bus *bus, int mii_id,
@@ -183,7 +180,7 @@ static int orion_mdio_smi_write(struct mii_bus *bus, int mii_id,
 
 	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
-		goto out;
+		return ret;
 
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
@@ -191,8 +188,7 @@ static int orion_mdio_smi_write(struct mii_bus *bus, int mii_id,
 		(value << MVMDIO_SMI_DATA_SHIFT)),
 	       dev->regs);
 
-out:
-	return ret;
+	return 0;
 }
 
 static int orion_mdio_xsmi_is_done(struct orion_mdio_dev *dev)
-- 
2.9.4
