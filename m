From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/5] net: davinci_mdio: Fix type mistake in calling runtime-pm api
Date: Mon, 15 Oct 2012 21:16:33 +0200
Message-ID: <62191bdcb85ab48f5ea16fe69c2f92aa9e9a0a8b.1350327325.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38472 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2JOTQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:16:59 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so447495wib.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:16:58 -0700 (PDT)
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaibhav Hiremath <hvaibhav@ti.com>

By mistake (most likely a copy-paste), instead of pm_runtime_get_sync()
api, driver is calling pm_runtime_put_sync() api in resume callback
function. The bug was introduced by commit id (ae2c07aaf74:
davinci_mdio: runtime PM support).

Now, the reason why it didn't impact functionality is, the patch has
been tested on AM335x-EVM and BeagleBone platform while submitting;
and in case of AM335x the MDIO driver doesn't control the module
enable/disable part, which is handled by CPSW driver.

Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 51a96db..ae74280 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -465,7 +465,7 @@ static int davinci_mdio_resume(struct device *dev)
 	u32 ctrl;
 
 	spin_lock(&data->lock);
-	pm_runtime_put_sync(data->dev);
+	pm_runtime_get_sync(data->dev);
 
 	/* restart the scan state machine */
 	ctrl = __raw_readl(&data->regs->control);
-- 
1.7.2.5
