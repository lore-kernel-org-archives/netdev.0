From: Dan Carpenter <error27@gmail.com>
Subject: [patch] stmmac: use resource_size()
Date: Mon, 22 Mar 2010 15:11:11 +0300
Message-ID: <20100322121111.GJ21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The size calculation is not correct.  It should be end - start + 1.
Use resource_size() to calculate it instead.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a673361..92bef30 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1685,8 +1685,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	}
 	pr_info("done!\n");
 
-	if (!request_mem_region(res->start, (res->end - res->start),
-				pdev->name)) {
+	if (!request_mem_region(res->start, resource_size(res),	pdev->name)) {
 		pr_err("%s: ERROR: memory allocation failed"
 		       "cannot get the I/O addr 0x%x\n",
 		       __func__, (unsigned int)res->start);
@@ -1694,9 +1693,9 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
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
@@ -1774,7 +1773,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 out:
 	if (ret < 0) {
 		platform_set_drvdata(pdev, NULL);
-		release_mem_region(res->start, (res->end - res->start));
+		release_mem_region(res->start, resource_size(res));
 		if (addr != NULL)
 			iounmap(addr);
 	}
@@ -1812,7 +1811,7 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 
 	iounmap((void *)ndev->base_addr);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, (res->end - res->start));
+	release_mem_region(res->start, resource_size(res));
 
 	free_netdev(ndev);
 
