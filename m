From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 31/36] net: ethernet: xscale: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:58:36 +0900
Message-ID: <003001ce4adf$88b7c370$9a274a50$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>,
	'Xi Wang' <xi.wang@gmail.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:55456 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324Ab3EGE6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:58:38 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00MM0WHMLYD0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:58:37 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 6958a5e..3d689fc 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1472,7 +1472,6 @@ err_phy_dis:
 	phy_disconnect(port->phydev);
 err_free_mem:
 	npe_port_tab[NPE_ID(port->id)] = NULL;
-	platform_set_drvdata(pdev, NULL);
 	release_resource(port->mem_res);
 err_npe_rel:
 	npe_release(port->npe);
@@ -1489,7 +1488,6 @@ static int eth_remove_one(struct platform_device *pdev)
 	unregister_netdev(dev);
 	phy_disconnect(port->phydev);
 	npe_port_tab[NPE_ID(port->id)] = NULL;
-	platform_set_drvdata(pdev, NULL);
 	npe_release(port->npe);
 	release_resource(port->mem_res);
 	free_netdev(dev);
-- 
1.7.2.5
