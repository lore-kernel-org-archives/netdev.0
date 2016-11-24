From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 4/5] net: fsl/fman: fix fixed-link-phydev reference leak
Date: Thu, 24 Nov 2016 19:21:30 +0100
Message-ID: <1480011691-13278-5-git-send-email-johan@kernel.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34295 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935645AbcKXSWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 13:22:50 -0500
In-Reply-To: <1480011691-13278-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to drop the reference taken by of_phy_find_device() when
looking up a fixed-link phydev during probe.

Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/freescale/fman/mac.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 8fe6b3e253fa..736db9d9b0ad 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -892,6 +892,8 @@ static int mac_probe(struct platform_device *_of_dev)
 		priv->fixed_link->duplex = phy->duplex;
 		priv->fixed_link->pause = phy->pause;
 		priv->fixed_link->asym_pause = phy->asym_pause;
+
+		put_device(&phy->mdio.dev);
 	}
 
 	err = mac_dev->init(mac_dev);
-- 
2.7.3
