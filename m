From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] ravb: kill duplicate setting of CCC.CSEL
Date: Sat, 06 Feb 2016 17:46:35 +0300
Message-ID: <2078080.3mtuat95A1@wasted.cogentembedded.com>
References: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When  adding support for the  R-Car gen3 gPTP active in configuration mode,
the code setting the CCC.CSEL field  was duplicated due to an oversight.
For R-Car gen 2 it's just redundant  and for R-Car gen3 the write at this
time is probably  ignored due to CCC.GAC bit being already  set...

Fixes: f5d7837f96e5 ("ravb: ptp: Add CONFIG mode support")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/ravb_main.c |    4 ----
 1 file changed, 4 deletions(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -1814,10 +1814,6 @@ static int ravb_probe(struct platform_de
 			   CCC_OPC_CONFIG | CCC_GAC | CCC_CSEL_HPB, CCC);
 	}
 
-	/* Set CSEL value */
-	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_CSEL) | CCC_CSEL_HPB,
-		   CCC);
-
 	/* Set GTI value */
 	error = ravb_set_gti(ndev);
 	if (error)
