From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] fix for integer overflow in hd6457[02] driver code
Date: Sun, 05 Sep 2004 16:26:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3u0ucrdv1.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, marcelo.tosatti@cyclades.com,
        <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

The attached patch fixes an integer overflow in drivers for N2, C101,
PCI200SYN WAN cards (brv * port->settings.clock_rate overflowed at
requested clock rate of 8*1024*1024 bps, problem noted by Nagaraj Kanniah).

Please apply to 2.4 and 2.6 kernel trees. Thanks.

[now the patch has made it here]
-- 
Krzysztof Halasa

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=hd6457x-speed-fix.patch

--- linux-2.6/drivers/net/wan/hd6457x.c	1 Jun 2004 03:47:44 -0000
+++ linux-2.6/drivers/net/wan/hd6457x.c	5 Sep 2004 13:59:22 -0000
@@ -463,8 +463,8 @@
 			brv >>= 1; /* brv = 2^9 = 512 max in specs */
 
 			/* Baud Rate = CLOCK_BASE / TMC / 2^BR */
-			tmc = CLOCK_BASE / (brv * port->settings.clock_rate);
-		}while(br > 1 && tmc <= 128);
+			tmc = CLOCK_BASE / brv / port->settings.clock_rate;
+		}while (br > 1 && tmc <= 128);
 
 		if (tmc < 1) {
 			tmc = 1;
@@ -473,7 +473,7 @@
 		} else if (tmc > 255)
 			tmc = 256; /* tmc=0 means 256 - low baud rates */
 
-		port->settings.clock_rate = CLOCK_BASE / (brv * tmc);
+		port->settings.clock_rate = CLOCK_BASE / brv / tmc;
 	} else {
 		br = 9; /* Minimum clock rate */
 		tmc = 256;	/* 8bit = 0 */

--=-=-=--
