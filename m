From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] typo in net-drivers-2.5-exp 3c507
Date: Tue, 11 Nov 2003 14:42:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111144258.3a02e3c8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix auto-probing loop in new probing code for 3c507. 
This patch is against net-drivers-2.5-exp repository.
Found by viro.

diff -Nru a/drivers/net/3c507.c b/drivers/net/3c507.c
--- a/drivers/net/3c507.c	Tue Nov 11 09:36:13 2003
+++ b/drivers/net/3c507.c	Tue Nov 11 09:36:13 2003
@@ -332,11 +332,11 @@
 	else if (io != 0)
 		err = -ENXIO;		/* Don't probe at all. */
 	else {
-			for (port = ports; *port; port++) {
-					err = el16_probe1(dev, io);
-					if (!err)
-						break;
-			}
+		for (port = ports; *port; port++) {
+			err = el16_probe1(dev, *port);
+			if (!err)
+				break;
+		}
 	}
 
 	if (err)
