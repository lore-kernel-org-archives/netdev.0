From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skfddi - fix warning
Date: Tue, 22 Jun 2004 10:51:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622105146.56e92d80@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The conversion to ANSI, caused a warning because the mulitcast code needs
a cast.  dmi->dmi_addr is a u8 array, and fddi_addr is just a wrapper around a u8 array.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	2004-06-22 10:47:41 -07:00
+++ b/drivers/net/skfp/skfddi.c	2004-06-22 10:47:41 -07:00
@@ -909,7 +909,10 @@
 				dmi = dev->mc_list;
 
 				for (i = 0; i < dev->mc_count; i++) {
-					mac_add_multicast(smc, dmi->dmi_addr, 1);
+					mac_add_multicast(smc, 
+							  (struct fddi_addr *)dmi->dmi_addr, 
+							  1);
+
 					PRINTK(KERN_INFO "ENABLE MC ADDRESS:");
 					PRINTK(" %02x %02x %02x ",
 					       dmi->dmi_addr[0],
