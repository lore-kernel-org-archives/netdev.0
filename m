From: aris@cathedrallabs.org (Aristeu Sergio Rozanski Filho)
Subject: [patch] 3c509: don't return if request_region fails
Date: Tue, 7 Oct 2003 21:27:16 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008002715.GA31225@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hi,
	this makes el3_probe don't return if request_region fails
	while trying to detect pnp cards. it would leave the
	other pnp cards attached.

-- 
aris


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="3c509-pnpprobe.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#                  ChangeSet    1.1375  -> 1.1376
#        drivers/net/3c509.c    1.43    -> 1.44
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/07      aris@cathedrallabs.org  1.1376
# o 3c509: don't return if request_region fails
# --------------------------------------------
#
diff -Nru a/drivers/net/3c509.c b/drivers/net/3c509.c
--- a/drivers/net/3c509.c       Tue Oct  7 21:19:05 2003
+++ b/drivers/net/3c509.c       Tue Oct  7 21:19:05 2003
@@ -404,7 +404,7 @@
                        ioaddr = pnp_port_start(idev, 0);
                        if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509 PnP")) {
                                pnp_device_detach(idev);
-                               return -EBUSY;
+                               continue;
                        }
                        irq = pnp_irq(idev, 0);
                        if (el3_debug > 3)

--gBBFr7Ir9EOA20Yy--
