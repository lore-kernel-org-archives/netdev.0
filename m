From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2/5 2.5] e100: Fix for BMC connectivity loss on interface
 down
Date: Fri, 15 Oct 2004 06:53:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150552340.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.c.new
--- netdev-2.6/drivers/net/e100.c	2004-10-07 13:58:59.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-07 13:59:00.000000000 -0700
@@ -604,16 +604,6 @@ static void e100_hw_reset(struct nic *ni
 	writel(software_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
 
-	/* TCO workaround - 82559 and greater */
-	if(nic->mac >= mac_82559_D101M) {
-		/* Issue a redundant CU load base without setting
-		 * general pointer, and without waiting for scb to
-		 * clear.  This gets us into post-driver.  Finally,
-		 * wait 20 msec for reset to take effect. */
-		writeb(cuc_load_base, &nic->csr->scb.cmd_lo);
-		mdelay(20);
-	}
-
 	/* Mask off our interrupt line - it's unmasked after reset */
 	e100_disable_irq(nic);
 }
