From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net/ethernet: ks8851_mll: signedness bug in ks8851_probe()
Date: Fri, 17 Feb 2012 09:44:33 +0300
Message-ID: <20120217064433.GC3666@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Danny Kukawka <danny.kukawka@bisect.de>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jan Weitzel <j.weitzel@phytec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:44585 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab2BQGpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 01:45:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev->irq is unsigned, so it's never less than zero.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 10d5798..b8104d9 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1544,7 +1544,7 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 
 	netdev->irq = platform_get_irq(pdev, 0);
 
-	if (netdev->irq < 0) {
+	if ((int)netdev->irq < 0) {
 		err = netdev->irq;
 		goto err_get_irq;
 	}
