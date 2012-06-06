From: Steven King <sfking@fdwdc.com>
Subject: [PATCH net-next] fec: Add support for Coldfire M5441x enet-mac.
Date: Wed, 6 Jun 2012 10:06:20 -0700
Message-ID: <201206061006.21288.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: uClinux development list <uclinux-dev@uclinux.org>,
	Greg Ungerer <gerg@snapgear.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm17-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.21]:24033
	"HELO nm17-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757273Ab2FFRGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:06:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the Freescale Coldfire M5441x; as these parts have an 
enet-mac, add a quirk to distinguish them from the other Coldfire parts so we 
can use the existing enet-mac support.

Signed-off-by: Steven king <sfking@fdwdc.com>
---
 drivers/net/ethernet/freescale/Kconfig |    5 ++---
 drivers/net/ethernet/freescale/fec.c   |    6 +++++-
 drivers/net/ethernet/freescale/fec.h   |    3 ++-
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 3574e14..f9aa244 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -7,7 +7,7 @@ config NET_VENDOR_FREESCALE
 	default y
 	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
-		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM)
+		   M5441x || ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -22,8 +22,7 @@ if NET_VENDOR_FREESCALE
 
 config FEC
 	tristate "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
-	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
-		   ARCH_MXC || SOC_IMX28)
+	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || M5441x || ARCH_MXC || SOC_IMX28)
 	default ARCH_MXC || SOC_IMX28 if ARM
 	select PHYLIB
 	---help---
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ff7f4c5..9567667 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -94,6 +94,9 @@ static struct platform_device_id fec_devtype[] = {
 		.name = "imx6q-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT,
 	}, {
+		.name = "enet-fec",
+		.driver_data = FEC_QUIRK_ENET_MAC,
+	}, {
 		/* sentinel */
 	}
 };
@@ -187,7 +190,8 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
  * account when setting it.
  */
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM) || \
+    defined(CONFIG_M5441x)
 #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
 #else
 #define	OPT_FRAME_SIZE	0
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 8408c62..298cfb7 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -15,7 +15,8 @@
 
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
     defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
-    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28) || \
+    defined(CONFIG_M5441x)
 /*
  *	Just figures, Motorola would have to change the offsets for
  *	registers in the same peripheral device on different models
