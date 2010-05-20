From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] sh_eth: Fix memleak in sh_mdio_release
Date: Thu, 20 May 2010 14:00:59 +0000
Message-ID: <20100520140059.GA8968@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shimoda.yoshihiro@renesas.com, iwamatsu@nigauri.org,
	morimoto.kuninori@renesas.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:59004 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754599Ab0ETOBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 10:01:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocated memory for IRQs should be freed when releasing the mii_bus

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---

drivers/net/sh_eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 586ed09..501a55f 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1294,6 +1294,9 @@ static int sh_mdio_release(struct net_device *ndev)
 	/* remove mdio bus info from net_device */
 	dev_set_drvdata(&ndev->dev, NULL);
 
+	/* free interrupts memory */
+	kfree(bus->irq);
+
 	/* free bitbang info */
 	free_mdio_bitbang(bus);
 
