From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH 1/1] net: Netconsole poll support for 3c509
Date: Tue, 23 Nov 2004 19:31:33 +1100
Message-ID: <41A2F565.6050002@kolivas.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5EAAA427D3226A5F397F451C"
Cc: Andrew Morton <akpm@osdl.org>, Matt Mackall <mpm@selenic.com>,
        netdev@oss.sgi.com, Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux <linux-kernel@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5EAAA427D3226A5F397F451C
Content-Type: multipart/mixed;
 boundary="------------040009050600080605070202"

This is a multi-part message in MIME format.
--------------040009050600080605070202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch provides poll support to allow netconsole to work with 3c509 
network cards.

Status: Compiled, debugged and tested working by Michael Buesch.

Signed-off-by: Con Kolivas <kernel@kolivas.org>


--------------040009050600080605070202
Content-Type: text/x-patch;
 name="net_3c509_poll.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net_3c509_poll.diff"

diff -urNX /home/mb/dontdiff linux-2.6.10-rc2-mm2.orig/drivers/net/3c509.c linux-2.6.10-rc2-mm2/drivers/net/3c509.c
--- linux-2.6.10-rc2-mm2.orig/drivers/net/3c509.c	2004-11-21 15:10:18.799455108 +0100
+++ linux-2.6.10-rc2-mm2/drivers/net/3c509.c	2004-11-21 15:12:01.677918665 +0100
@@ -209,6 +209,9 @@
 #if defined(CONFIG_EISA) || defined(CONFIG_MCA)
 static int el3_device_remove (struct device *device);
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void el3_poll_controller(struct net_device *dev);
+#endif
 
 #ifdef CONFIG_EISA
 struct eisa_device_id el3_eisa_ids[] = {
@@ -321,6 +324,9 @@
 	dev->set_multicast_list = &set_multicast_list;
 	dev->tx_timeout = el3_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = el3_poll_controller;
+#endif
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
 	err = register_netdev(dev);
@@ -999,6 +1005,19 @@
 }
 
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void el3_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	el3_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static struct net_device_stats *
 el3_get_stats(struct net_device *dev)
 {

--------------040009050600080605070202--

--------------enig5EAAA427D3226A5F397F451C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBovVnZUg7+tp6mRURAs36AJ9xBfYfeulNlFMbIw60M6seZc+U9wCfWpvo
ubPhh3vYjUTkIAtu80U+ymQ=
=pFPk
-----END PGP SIGNATURE-----

--------------enig5EAAA427D3226A5F397F451C--
