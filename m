From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH] pxa168_eth: fix a mdiobus leak
Date: Mon, 30 Aug 2010 07:21:38 +0000
Message-ID: <20100830072138.GA8797@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: error27@gmail.com, ssanap@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:35330 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537Ab0H3HVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 03:21:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdiobus resources must be released on exit
Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/pxa168_eth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 410ea0a..85eddda 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1606,6 +1606,8 @@ static int pxa168_eth_remove(struct platform_device *pdev)
 
 	iounmap(pep->base);
 	pep->base = NULL;
+	mdiobus_unregister(pep->smi_bus);
+	mdiobus_free(pep->smi_bus);
 	unregister_netdev(dev);
 	flush_scheduled_work();
 	free_netdev(dev);
-- 
1.6.4.4

