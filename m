From: Dan Carpenter <error27@gmail.com>
Subject: [patch] stmmac: use resource_size()
Date: Wed, 7 Apr 2010 12:35:46 +0300
Message-ID: <20100407093546.GF5157@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:62073 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238Ab0DGJfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 05:35:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resource size should be calculated as end - start + 1 because we start
counting at zero.  I changed the code to resource_size() to do the 
calculation.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a214a16..4111a85 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1686,7 +1686,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	}
 	pr_info("done!\n");
 
-	if (!request_mem_region(res->start, (res->end - res->start),
+	if (!request_mem_region(res->start, resource_size(res),
 				pdev->name)) {
 		pr_err("%s: ERROR: memory allocation failed"
 		       "cannot get the I/O addr 0x%x\n",
@@ -1695,9 +1695,9 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	addr = ioremap(res->start, (res->end - res->start));
+	addr = ioremap(res->start, resource_size(res));
 	if (!addr) {
-		pr_err("%s: ERROR: memory mapping failed \n", __func__);
+		pr_err("%s: ERROR: memory mapping failed\n", __func__);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1775,7 +1775,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 out:
 	if (ret < 0) {
 		platform_set_drvdata(pdev, NULL);
-		release_mem_region(res->start, (res->end - res->start));
+		release_mem_region(res->start, resource_size(res));
 		if (addr != NULL)
 			iounmap(addr);
 	}
@@ -1813,7 +1813,7 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 
 	iounmap((void *)ndev->base_addr);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, (res->end - res->start));
+	release_mem_region(res->start, resource_size(res));
 
 	free_netdev(ndev);
 
