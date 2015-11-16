From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ixp4xx_hss: Delete an unnecessary check before the function
 call "dma_pool_destroy"
Date: Mon, 16 Nov 2015 13:36:33 +0100
Message-ID: <5649CDD1.6050600@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Krzysztof Halasa <khalasa@piap.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 16 Nov 2015 13:30:37 +0100

The dma_pool_destroy() function tests whether its argument is NULL
and then returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wan/ixp4xx_hss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index e7bbdb7..0d2593a 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1037,7 +1037,7 @@ static void destroy_hdlc_queues(struct port *port)
 		port->desc_tab = NULL;
 	}
 
-	if (!ports_open && dma_pool) {
+	if (!ports_open) {
 		dma_pool_destroy(dma_pool);
 		dma_pool = NULL;
 	}
-- 
2.6.2
