From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 07/14] net/fec: consolidate all i.MX options to CONFIG_ARM
Date: Fri, 11 Feb 2011 11:32:15 +0100
Message-ID: <1297420342-17739-7-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45137 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014Ab1BKKct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:49 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moreover stop listing all i.MX platforms featuring a FEC, and use
the platform's config symbol that selects registration of a fec device
instead.  This might make it easier to add new platforms.

Set default =3D y for ARMs having a fec to reduce defconfig sizes.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/Kconfig |    3 ++-
 drivers/net/fec.c   |    5 ++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..65027a7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1944,7 +1944,8 @@ config 68360_ENET
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
-		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5 || SOC_IMX28
+		IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC
+	default IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC if ARM
 	select PHYLIB
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 14eb660..dd4e580 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -54,7 +54,7 @@
=20
 #include "fec.h"
=20
-#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+#if defined(CONFIG_ARM)
 #define FEC_ALIGNMENT	0xf
 #else
 #define FEC_ALIGNMENT	0x3
@@ -147,8 +147,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address=
");
  * account when setting it.
  */
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M=
528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
-    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_A=
RM)
 #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
 #else
 #define	OPT_FRAME_SIZE	0
--=20
1.7.2.3

