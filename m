From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] chelsio/espi.c:tricn_init(): remove dead code
Date: Fri, 10 Mar 2006 00:06:53 +0100
Message-ID: <20060309230653.GK21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932082AbWCIXHk@vger.kernel.org>
To: maintainers@chelsio.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted these two unused variables.

Please check whether this patch is correct or whether they should be 
used.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/chelsio/espi.c |   14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

--- linux-2.6.16-rc5-mm3-full/drivers/net/chelsio/espi.c.old	2006-03-09 23:19:54.000000000 +0100
+++ linux-2.6.16-rc5-mm3-full/drivers/net/chelsio/espi.c	2006-03-09 23:20:35.000000000 +0100
@@ -87,15 +87,9 @@
 static int tricn_init(adapter_t *adapter)
 {
 	int     i               = 0;
-	int     sme             = 1;
 	int     stat            = 0;
 	int     timeout         = 0;
 	int     is_ready        = 0;
-	int     dynamic_deskew  = 0;
-
-	if (dynamic_deskew)
-		sme = 0;
-
 
 	/* 1 */
 	timeout=1000;
@@ -113,11 +107,9 @@
 	}
 
 	/* 2 */
-	if (sme) {
-		tricn_write(adapter, 0, 0, 0, TRICN_CNFG, 0x81);
-		tricn_write(adapter, 0, 1, 0, TRICN_CNFG, 0x81);
-		tricn_write(adapter, 0, 2, 0, TRICN_CNFG, 0x81);
-	}
+	tricn_write(adapter, 0, 0, 0, TRICN_CNFG, 0x81);
+	tricn_write(adapter, 0, 1, 0, TRICN_CNFG, 0x81);
+	tricn_write(adapter, 0, 2, 0, TRICN_CNFG, 0x81);
 	for (i=1; i<= 8; i++) tricn_write(adapter, 0, 0, i, TRICN_CNFG, 0xf1);
 	for (i=1; i<= 2; i++) tricn_write(adapter, 0, 1, i, TRICN_CNFG, 0xf1);
 	for (i=1; i<= 3; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xe1);
