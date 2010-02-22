From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] isdn: fix a few Kconfig imperfections
Date: Mon, 22 Feb 2010 22:09:38 +0100 (CET)
Message-ID: <20100222210938.75A3B4011D@xenon.ts.pxnet.com>
Cc: Karsten Keil <keil@b1-systems.de>,
	David Miller <davem@davemloft.net>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Rewrite the outdated help texts for config options ISDN and ISDN_CAPI.
2. The MISDN config option appeared between ISDN_I4L and the I4L hardware
   driver options; move it to a less irritating place.
3. HYSDN is not in fact an I4L driver, and needn't depend on ISDN_I4L, so
   move it from the I4L section to the general section.
4. ISDN_HDLC is now also used by drivers outside I4L.  Move it from the
   I4L section to the general section, too.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/Kconfig     |   43 ++++++++++++++++++++++++++++---------------
 drivers/isdn/i4l/Kconfig |    7 -------
 2 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/drivers/isdn/Kconfig b/drivers/isdn/Kconfig
index 022a194..4fb6016 100644
--- a/drivers/isdn/Kconfig
+++ b/drivers/isdn/Kconfig
@@ -7,15 +7,14 @@ menuconfig ISDN
 	depends on NET
 	depends on !S390
 	---help---
-	  ISDN ("Integrated Services Digital Networks", called RNIS in France)
-	  is a special type of fully digital telephone service; it's mostly
-	  used to connect to your Internet service provider (with SLIP or
-	  PPP).  The main advantage is that the speed is higher than ordinary
-	  modem/telephone connections, and that you can have voice
-	  conversations while downloading stuff.  It only works if your
-	  computer is equipped with an ISDN card and both you and your service
-	  provider purchased an ISDN line from the phone company.  For
-	  details, read <http://www.alumni.caltech.edu/~dank/isdn/> on the WWW.
+	  ISDN ("Integrated Services Digital Network", called RNIS in France)
+	  is a fully digital telephone service that can be used for voice and
+	  data connections.  If your computer is equipped with an ISDN
+	  adapter you can use it to connect to your Internet service provider
+	  (with SLIP or PPP) faster than via a conventional telephone modem
+	  (though still much slower than with DSL) or to make and accept
+	  voice calls (eg. turning your PC into a software answering machine
+	  or PABX).
 
 	  Select this option if you want your kernel to support ISDN.
 
@@ -39,17 +38,22 @@ menuconfig ISDN_I4L
 	  It is still available, though, for use with adapters that are not
 	  supported by the new CAPI subsystem yet.
 
-source "drivers/isdn/mISDN/Kconfig"
-
 source "drivers/isdn/i4l/Kconfig"
 
 menuconfig ISDN_CAPI
 	tristate "CAPI 2.0 subsystem"
 	help
-	  This provides the CAPI (Common ISDN Application Programming
-	  Interface, a standard making it easy for programs to access ISDN
-	  hardware, see <http://www.capi.org/>.  This is needed for AVM's set
-	  of active ISDN controllers like B1, T1, M1.
+	  This provides CAPI (the Common ISDN Application Programming
+	  Interface) Version 2.0, a standard making it easy for programs to
+	  access ISDN hardware in a device independent way. (For details see
+	  <http://www.capi.org/>.)  CAPI supports making and accepting voice
+	  and data connections, controlling call options and protocols,
+	  as well as ISDN supplementary services like call forwarding or
+	  three-party conferences (if supported by the specific hardware
+	  driver).
+
+	  Select this option and the appropriate hardware driver below if
+	  you have an ISDN adapter supported by the CAPI subsystem.
 
 if ISDN_CAPI
 
@@ -61,4 +65,13 @@ endif # ISDN_CAPI
 
 source "drivers/isdn/gigaset/Kconfig"
 
+source "drivers/isdn/hysdn/Kconfig"
+
+source "drivers/isdn/mISDN/Kconfig"
+
+config ISDN_HDLC
+	tristate
+	select CRC_CCITT
+	select BITREVERSE
+
 endif # ISDN
diff --git a/drivers/isdn/i4l/Kconfig b/drivers/isdn/i4l/Kconfig
index 07c4e49..9c6650e 100644
--- a/drivers/isdn/i4l/Kconfig
+++ b/drivers/isdn/i4l/Kconfig
@@ -134,14 +134,7 @@ source "drivers/isdn/sc/Kconfig"
 
 source "drivers/isdn/act2000/Kconfig"
 
-source "drivers/isdn/hysdn/Kconfig"
-
 endmenu
 # end ISDN_I4L
 endif
 
-config ISDN_HDLC
-	tristate
-	select CRC_CCITT
-	select BITREVERSE
-
-- 
1.6.5.3.298.g39add
