From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 12/15] netdev: relocate sb1000 ISA cable modem driver to legacy
Date: Thu, 28 Oct 2010 21:19:16 -0400
Message-ID: <1288315159-1350-13-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33996 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759621Ab0J2BTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:34 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As yet another ISA device, this board is limited to being used
in motherboards that are 10+ years old.  Hence relocate it to
the legacy dir.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig               |   24 ------------------------
 drivers/net/Makefile              |    1 -
 drivers/net/legacy/Kconfig        |   24 ++++++++++++++++++++++++
 drivers/net/legacy/Makefile       |    1 +
 drivers/net/{ => legacy}/sb1000.c |    0
 5 files changed, 25 insertions(+), 25 deletions(-)
 rename drivers/net/{ => legacy}/sb1000.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7a0912e..707c9f8c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -168,30 +168,6 @@ config VETH
 	  When one end receives the packet it appears on its pair and vice
 	  versa.
 
-config NET_SB1000
-	tristate "General Instruments Surfboard 1000"
-	depends on PNP
-	---help---
-	  This is a driver for the General Instrument (also known as
-	  NextLevel) SURFboard 1000 internal
-	  cable modem. This is an ISA card which is used by a number of cable
-	  TV companies to provide cable modem access. It's a one-way
-	  downstream-only cable modem, meaning that your upstream net link is
-	  provided by your regular phone modem.
-
-	  At present this driver only compiles as a module, so say M here if
-	  you have this card. The module will be called sb1000. Then read
-	  <file:Documentation/networking/README.sb1000> for information on how
-	  to use this module, as it needs special ppp scripts for establishing
-	  a connection. Further documentation and the necessary scripts can be
-	  found at:
-
-	  <http://www.jacksonville.net/~fventuri/>
-	  <http://home.adelphia.net/~siglercm/sb1000.html>
-	  <http://linuxpower.cx/~cable/>
-
-	  If you don't have this card, of course say N.
-
 source "drivers/net/arcnet/Kconfig"
 
 config MII
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3182544..ff138b0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -111,7 +111,6 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac/
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
-obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_FEC) += fec.o
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index 96d667e..b9ea8ed 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -649,3 +649,27 @@ config SMC9194
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called smc9194.
+
+config NET_SB1000
+	tristate "General Instruments Surfboard 1000"
+	depends on PNP
+	---help---
+	  This is a driver for the General Instrument (also known as
+	  NextLevel) SURFboard 1000 internal
+	  cable modem. This is an ISA card which is used by a number of cable
+	  TV companies to provide cable modem access. It's a one-way
+	  downstream-only cable modem, meaning that your upstream net link is
+	  provided by your regular phone modem.
+
+	  At present this driver only compiles as a module, so say M here if
+	  you have this card. The module will be called sb1000. Then read
+	  <file:Documentation/networking/README.sb1000> for information on how
+	  to use this module, as it needs special ppp scripts for establishing
+	  a connection. Further documentation and the necessary scripts can be
+	  found at:
+
+	  <http://www.jacksonville.net/~fventuri/>
+	  <http://home.adelphia.net/~siglercm/sb1000.html>
+	  <http://linuxpower.cx/~cable/>
+
+	  If you don't have this card, of course say N.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index 0268706..b703327 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -75,3 +75,4 @@ obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_SMC9194) += smc9194.o
+obj-$(CONFIG_NET_SB1000) += sb1000.o
diff --git a/drivers/net/sb1000.c b/drivers/net/legacy/sb1000.c
similarity index 100%
rename from drivers/net/sb1000.c
rename to drivers/net/legacy/sb1000.c
-- 
1.7.3.2.146.g2d444

