From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 25/26] drivers: isdn: Move prototype declaration to header
 file dadapter.h
Date: Fri, 7 Feb 2014 18:18:58 +0530
Message-ID: <fa09a161cd57206bfac7f3ea2817fb6d535c727c.1390408520.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file
hardware/eicon/dadapter.h because they are used by more than one file.

This eliminates the following warning in hardware/eicon/dadapter.c:
drivers/isdn/hardware/eicon/dadapter.c:361:22: warning: no previous pro=
totype for =E2=80=98DIVA_DIDD_Read=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/capifunc.c  |    3 +--
 drivers/isdn/hardware/eicon/dadapter.h  |    1 +
 drivers/isdn/hardware/eicon/diddfunc.c  |    1 -
 drivers/isdn/hardware/eicon/diva_didd.c |    2 --
 drivers/isdn/hardware/eicon/divasfunc.c |    3 +--
 drivers/isdn/hardware/eicon/idifunc.c   |    3 +--
 drivers/isdn/hardware/eicon/mntfunc.c   |    3 +--
 7 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hard=
ware/eicon/capifunc.c
index 639d70f..3bcb602 100644
--- a/drivers/isdn/hardware/eicon/capifunc.c
+++ b/drivers/isdn/hardware/eicon/capifunc.c
@@ -18,6 +18,7 @@
 #include "divacapi.h"
 #include "divasync.h"
 #include "capifunc.h"
+#include "dadapter.h"
=20
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
@@ -55,8 +56,6 @@ static char *diva_procinfo(struct capi_ctr *);
 static u16 diva_send_message(struct capi_ctr *,
 			     diva_os_message_buffer_s *);
=20
-extern void DIVA_DIDD_Read(DESCRIPTOR *, int);
-
 /*
  * debug
  */
diff --git a/drivers/isdn/hardware/eicon/dadapter.h b/drivers/isdn/hard=
ware/eicon/dadapter.h
index 5540f46..f6cdebf 100644
--- a/drivers/isdn/hardware/eicon/dadapter.h
+++ b/drivers/isdn/hardware/eicon/dadapter.h
@@ -28,6 +28,7 @@
=20
 void diva_didd_load_time_init(void);
 void diva_didd_load_time_finit(void);
+void IDI_CALL_LINK_T DIVA_DIDD_Read(void IDI_CALL_ENTITY_T *buffer, in=
t length);
=20
 #define NEW_MAX_DESCRIPTORS     64
=20
diff --git a/drivers/isdn/hardware/eicon/diddfunc.c b/drivers/isdn/hard=
ware/eicon/diddfunc.c
index b0b23ed..a8a229f 100644
--- a/drivers/isdn/hardware/eicon/diddfunc.c
+++ b/drivers/isdn/hardware/eicon/diddfunc.c
@@ -20,7 +20,6 @@
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
=20
=20
-extern void DIVA_DIDD_Read(void *, int);
 extern char *DRIVERRELEASE_DIDD;
 static dword notify_handle;
 static DESCRIPTOR _DAdapter;
diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/har=
dware/eicon/diva_didd.c
index 56d32a7..b8e525f 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -39,8 +39,6 @@ MODULE_LICENSE("GPL");
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
=20
-extern void DIVA_DIDD_Read(void *, int);
-
 static struct proc_dir_entry *proc_didd;
 struct proc_dir_entry *proc_net_eicon =3D NULL;
=20
diff --git a/drivers/isdn/hardware/eicon/divasfunc.c b/drivers/isdn/har=
dware/eicon/divasfunc.c
index 4be5f88..a5d44d0 100644
--- a/drivers/isdn/hardware/eicon/divasfunc.c
+++ b/drivers/isdn/hardware/eicon/divasfunc.c
@@ -17,14 +17,13 @@
 #include "divasync.h"
 #include "diva.h"
 #include "xdi_vers.h"
+#include "dadapter.h"
=20
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
=20
 static int debugmask;
=20
-extern void DIVA_DIDD_Read(void *, int);
-
 extern PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
=20
 extern char *DRIVERRELEASE_DIVAS;
diff --git a/drivers/isdn/hardware/eicon/idifunc.c b/drivers/isdn/hardw=
are/eicon/idifunc.c
index bacab74..dc79095 100644
--- a/drivers/isdn/hardware/eicon/idifunc.c
+++ b/drivers/isdn/hardware/eicon/idifunc.c
@@ -15,14 +15,13 @@
 #include "divasync.h"
 #include "um_xdi.h"
 #include "um_idi.h"
+#include "dadapter.h"
=20
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
=20
 extern char *DRIVERRELEASE_IDI;
=20
-extern void DIVA_DIDD_Read(void *, int);
-
 static dword notify_handle;
 static DESCRIPTOR DAdapter;
 static DESCRIPTOR MAdapter;
diff --git a/drivers/isdn/hardware/eicon/mntfunc.c b/drivers/isdn/hardw=
are/eicon/mntfunc.c
index e304a1d..be47431 100644
--- a/drivers/isdn/hardware/eicon/mntfunc.c
+++ b/drivers/isdn/hardware/eicon/mntfunc.c
@@ -15,14 +15,13 @@
 #include "di_defs.h"
 #include "divasync.h"
 #include "debug_if.h"
+#include "dadapter.h"
=20
 extern char *DRIVERRELEASE_MNT;
=20
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
=20
-extern void DIVA_DIDD_Read(void *, int);
-
 static dword notify_handle;
 static DESCRIPTOR DAdapter;
 static DESCRIPTOR MAdapter;
--=20
1.7.9.5
