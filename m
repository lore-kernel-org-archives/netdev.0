From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/16) smsc-ircc2 -- replace check_region with
 request_region
Date: Tue, 30 Sep 2003 15:21:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930152124.297b7d48.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than checking region, then using it; use request_region
and release after use. 

diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:26:33 2003
+++ b/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:26:33 2003
@@ -2264,32 +2264,36 @@
 
 static int __init smsc_superio_fdc(unsigned short cfg_base)
 {
-	if (check_region(cfg_base, 2) < 0) {
+	int ret = -1;
+
+	if (!request_region(cfg_base, 2, driver_name)) {
 		WARNING("%s: can't get cfg_base of 0x%03x\n",
 			__FUNCTION__, cfg_base);
-		return -1;
-	}
+	} else {
+		if (!smsc_superio_flat(fdc_chips_flat,cfg_base,"FDC")
+		    ||!smsc_superio_paged(fdc_chips_paged,cfg_base,"FDC"))
+			ret =  0;
 
-	if (!smsc_superio_flat(fdc_chips_flat,cfg_base,"FDC")||!smsc_superio_paged(fdc_chips_paged,cfg_base,"FDC"))
-		return 0;
+		release_region(cfg_base, 2);
+	}
 
-	return -1;
+	return ret;
 }
 
 static int __init smsc_superio_lpc(unsigned short cfg_base)
 {
-#if 0
-	if (check_region(cfg_base, 2) < 0) {
-		IRDA_DEBUG(0, __FUNCTION__ ": can't get cfg_base of 0x%03x\n",
-			   cfg_base);
-		return -1;
-	}
-#endif
+	int ret = -1;
 
-	if (!smsc_superio_flat(lpc_chips_flat,cfg_base,"LPC")||!smsc_superio_paged(lpc_chips_paged,cfg_base,"LPC"))
-		return 0;
-
-	return -1;
+	if (!request_region(cfg_base, 2, driver_name)) {
+		WARNING("%s: can't get cfg_base of 0x%03x\n",
+			__FUNCTION__, cfg_base);
+	} else {
+		if (!smsc_superio_flat(lpc_chips_flat,cfg_base,"LPC")
+		    ||!smsc_superio_paged(lpc_chips_paged,cfg_base,"LPC"))
+			ret = 0;
+		release_region(cfg_base, 2);
+	}
+	return ret;
 }
 
 /************************************************
