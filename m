From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] NetCP: Deletion of unnecessary checks before two function
 calls
Date: Tue, 03 Feb 2015 20:22:23 +0100
Message-ID: <54D11FEF.10804@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Murali Karicheri <m-karicheri2@ti.com>,
	Wingman Kwok <w-kwok2@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:53721 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965959AbbBCTW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 14:22:28 -0500
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 3 Feb 2015 20:12:25 +0100

The functions cpsw_ale_destroy() and of_dev_put() test whether their argument
is NULL and then return immediately. Thus the test around the call
is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index fa1041a..cbd6dde 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2010,12 +2010,10 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 quit:
 	if (gbe_dev->hw_stats)
 		devm_kfree(dev, gbe_dev->hw_stats);
-	if (gbe_dev->ale)
-		cpsw_ale_destroy(gbe_dev->ale);
+	cpsw_ale_destroy(gbe_dev->ale);
 	if (gbe_dev->ss_regs)
 		devm_iounmap(dev, gbe_dev->ss_regs);
-	if (interfaces)
-		of_node_put(interfaces);
+	of_node_put(interfaces);
 	devm_kfree(dev, gbe_dev);
 	return ret;
 }
-- 
2.2.2
