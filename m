From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.5 1/3] e100: Fix loss of connectivity to BMC when interface
 is brought down
Date: Mon, 18 Oct 2004 03:23:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410180309030.20965-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.new.c
--- netdev-2.6/drivers/net/e100.c	2004-10-15 12:27:00.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-15 12:27:01.000000000 -0700
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
