From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2] net: can: Disable flexcan driver build for big endian CPU on ARM
Date: Mon,  6 Jan 2014 05:21:03 -0800
Message-ID: <1389014463-14649-1-git-send-email-linux@roeck-us.net>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building arm:allmodconfig fails with

flexcan.c: In function 'flexcan_read':
flexcan.c:243:2: error: implicit declaration of function 'in_be32'
flexcan.c: In function 'flexcan_write':
flexcan.c:248:2: error: implicit declaration of function 'out_be32'

in_be32 and out_be32 do not (or no longer) exist for ARM targets.
Disable the build for ARM on big endian CPUs.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2: Instead of marking the build as broken, disable it for big endian ARM CPUs.
    Adjust headline accordingly.

 drivers/net/can/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 3c06947..fd0e5de 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -104,7 +104,7 @@ config CAN_JANZ_ICAN3
 
 config CAN_FLEXCAN
 	tristate "Support for Freescale FLEXCAN based chips"
-	depends on ARM || PPC
+	depends on (ARM && CPU_LITTLE_ENDIAN) || PPC
 	---help---
 	  Say Y here if you want to support for Freescale FlexCAN.
 
-- 
1.7.9.7

