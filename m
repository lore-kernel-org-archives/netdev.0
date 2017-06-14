From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v4 07/11] net: mvmdio: check the MII_ADDR_C45 bit is not set for smi operations
Date: Wed, 14 Jun 2017 17:49:07 +0200
Message-ID: <20170614154911.14510-8-antoine.tenart@free-electrons.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34989 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdFNPye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 11:54:34 -0400
In-Reply-To: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a check for the read and write smi operations, to ensure the
MII_ADDR_C45 bit isn't set. This will be needed as soon as the xSMI
support is added to the mvmdio driver.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index e4aa8e2d2e8a..fe6072aae0a6 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -126,6 +126,9 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	u32 val;
 	int ret;
 
+	if (regnum & MII_ADDR_C45)
+		return -EOPNOTSUPP;
+
 	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
 		goto out;
@@ -157,6 +160,9 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	struct orion_mdio_dev *dev = bus->priv;
 	int ret;
 
+	if (regnum & MII_ADDR_C45)
+		return -EOPNOTSUPP;
+
 	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
 		goto out;
-- 
2.9.4
