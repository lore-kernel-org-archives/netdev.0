From: Alexey Dobriyan <adobriyan@mail.ru>
Subject: [PATCH] prism54: use initialized current_time in debug_code
Date: Wed, 2 Feb 2005 13:34:41 +0200
Message-ID: <200502021334.41648.adobriyan@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: prism54-private@prism54.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Otherwise gcc 4 complains:

drivers/net/wireless/prism54/isl_38xx.c: In function =E2=80=98isl38xx_tri=
gger_device=E2=80=99:
drivers/net/wireless/prism54/isl_38xx.c:131: warning: =E2=80=98current_ti=
me.tv_sec=E2=80=99 is used uninitialized in this function
drivers/net/wireless/prism54/isl_38xx.c:131: warning: =E2=80=98current_ti=
me.tv_usec=E2=80=99 is used uninitialized in this function

Signed-off-by: Alexey Dobriyan <adobriyan@mail.ru>

--- linux-2.6.11-rc2-bk10/drivers/net/wireless/prism54/isl_38xx.c.orig	20=
05-02-02 13:20:57.000000000 +0200
+++ linux-2.6.11-rc2-bk10/drivers/net/wireless/prism54/isl_38xx.c	2005-02=
-02 13:24:25.000000000 +0200
@@ -112,7 +112,9 @@ isl38xx_handle_wakeup(isl38xx_control_bl
 void
 isl38xx_trigger_device(int asleep, void __iomem *device_base)
 {
+#if VERBOSE > SHOW_ERROR_MESSAGES
 	struct timeval current_time;
+#endif
 	u32 reg, counter =3D 0;
=20
 #if VERBOSE > SHOW_ERROR_MESSAGES
@@ -126,11 +128,10 @@ isl38xx_trigger_device(int asleep, void=20
 		do_gettimeofday(&current_time);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
 		      current_time.tv_sec, current_time.tv_usec);
-#endif
-
 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
 		      current_time.tv_sec, current_time.tv_usec,
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
+#endif
 		udelay(ISL38XX_WRITEIO_DELAY);
=20
 		reg =3D readl(device_base + ISL38XX_INT_IDENT_REG);
@@ -148,10 +149,13 @@ isl38xx_trigger_device(int asleep, void=20
 				counter++;
 			}
=20
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register read %08x\n",
 			      current_time.tv_sec, current_time.tv_usec,
 			      readl(device_base + ISL38XX_CTRL_STAT_REG));
+#endif
 			udelay(ISL38XX_WRITEIO_DELAY);
=20
 #if VERBOSE > SHOW_ERROR_MESSAGES
