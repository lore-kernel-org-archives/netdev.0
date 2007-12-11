From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: [PATCH 2/2] add driver for enc28j60 ethernet chip
Date: Tue, 11 Dec 2007 15:58:49 +0100
Message-ID: <475EA5A9.2020509@eptar.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080504070903040905040807"
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:54986 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbXLKPE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 10:04:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080504070903040905040807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Second part contains changes on Kconfig and Makefile on dir drivers/net

Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

--------------080504070903040905040807
Content-Type: text/x-patch;
 name="enc28j60_p2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="enc28j60_p2.diff"

 drivers/net/Kconfig  |   26 ++++++++++++++++++++++++++
 drivers/net/Makefile |    1 +
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..e643e0f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -922,6 +922,32 @@ config DM9000
 	  To compile this driver as a module, choose M here.  The module
 	  will be called dm9000.
 
+config ENC28J60
+	tristate "ENC28J60 support"
+	depends on EXPERIMENTAL && SPI && NET_ETHERNET
+	select CRC32
+	select MII
+	---help---
+	  Support for the Microchip EN28J60 ethernet chip.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>.  The module will be
+	  called enc28j60.
+
+config ENC28J60_DBGLEVEL
+	int "Debugging verbosity (0 = quiet, 3 = noisy)"
+	depends on ENC28J60
+	default "0"
+	---help---
+	  Determines the verbosity level of the enc28j60 driver debugging messages.
+
+config ENC28J60_WRITEVERIFY
+	bool "Enable write verify"
+	depends on ENC28J60
+	---help---
+	  Enable the verify after the buffer write useful for debugging purpose.
+	  If unsure, say N.
+
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0e5fde4..e91e3a3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -216,6 +216,7 @@ obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
 obj-$(CONFIG_MLX4_CORE) += mlx4/
+obj-$(CONFIG_ENC28J60) += enc28j60.o
 
 obj-$(CONFIG_MACB) += macb.o
 



--------------080504070903040905040807--
