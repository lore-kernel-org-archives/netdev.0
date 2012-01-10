From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 02/21] bfin_mac: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:08 +0100
Message-ID: <1326189567-21663-3-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59606 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967Ab2AJJ77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 04:59:59 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/adi/bfin_mac.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index b6d69c9..d812a10 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1670,7 +1670,8 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	miibus->name = "bfin_mii_bus";
 	miibus->phy_mask = mii_bus_pd->phy_mask;
 
-	snprintf(miibus->id, MII_BUS_ID_SIZE, "0");
+	snprintf(miibus->id, MII_BUS_ID_SIZE, "%s-%x",
+		pdev->name, pdev->id);
 	miibus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!miibus->irq)
 		goto out_err_irq_alloc;
-- 
1.7.5.4
