From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] mii_check_media, update link status in any case
Date: Fri, 18 Feb 2005 16:57:31 +0100
Message-ID: <20050218155731.GA32352@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development Mailing List <netdev@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In some cases it is necessary to check for link and duplex status.
This patch changes the behavior of mii_check_media() to
update the link status in any case.

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

--- vanilla-2.6.11-rc4/drivers/net/mii.c	Sun Feb 13 04:06:05 2005
+++ linux-2.6.11-rc4/drivers/net/mii.c	Fri Feb 18 12:28:14 2005
@@ -208,10 +208,6 @@
 	unsigned int old_carrier, new_carrier;
 	int advertise, lpa, media, duplex;
 
-	/* if forced media, go no further */
-	if (mii->force_media)
-		return 0; /* duplex did not change */
-
 	/* check current and old link status */
 	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
 	new_carrier = (unsigned int) mii_link_ok(mii);
@@ -234,6 +230,13 @@
 	 * we have carrier, see who's on the other end
 	 */
 	netif_carrier_on(mii->dev);
+
+	/* if forced media, go no further */
+	if (mii->force_media) {
+		if (ok_to_print)
+			printk(KERN_INFO "%s: link up\n", mii->dev->name);
+		return 0; /* duplex did not change */
+	}
 
 	/* get MII advertise and LPA values */
 	if ((!init_media) && (mii->advertising))
