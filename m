From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 5/7] net,marvell: Add dependency on HAS_IOMEM
Date: Tue, 14 Jan 2014 16:45:43 +0100
Message-ID: <1389714345-20165-5-git-send-email-richard@nod.at>
References: <1389714345-20165-1-git-send-email-richard@nod.at>
Cc: sebastian.hesselbarth@gmail.com, florian@openwrt.org,
	thomas.petazzoni@free-electrons.com, lars@metafoo.de,
	marex@denx.de, acourbot@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, devel@driverdev.osuosl.org,
	linux-iio@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: kishon@ti.com, anton@enomsg.org, dwmw2@infradead.org,
	richardcochran@gmail.com, lidza.louina@gmail.com,
	gregkh@linuxfoundation.org, jic23@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:1672 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751933AbaANPqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 10:46:18 -0500
In-Reply-To: <1389714345-20165-1-git-send-email-richard@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On archs like S390 or um this driver cannot build nor work.
Make it depend on HAS_IOMEM to bypass build failures.

drivers/built-in.o: In function `orion_mdio_probe':
drivers/net/ethernet/marvell/mvmdio.c:228: undefined reference to `devm_ioremap'

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/net/ethernet/marvell/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index a49e81b..6300fd2 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -33,6 +33,7 @@ config MV643XX_ETH
 
 config MVMDIO
 	tristate "Marvell MDIO interface support"
+	depends on HAS_IOMEM
 	select PHYLIB
 	---help---
 	  This driver supports the MDIO interface found in the network
-- 
1.8.1.4
