From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 08/26] drivers: isdn: Move prototype declaration to header
 file platform.h from divasmain.c and divasproc.c
Date: Fri, 7 Feb 2014 17:57:30 +0530
Message-ID: <4cb5fd91772555252cb638933c703ace2dfb181f.1390408515.git.rashika.kheria@gmail.com>
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

Move prototype declarations of functions to header file
hardware/eicon/platform.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/divasfunc.c:
drivers/isdn/hardware/eicon/divasfunc.c:49:6: warning: no previous prot=
otype for =E2=80=98diva_get_vserial_number=E2=80=99 [-Wmissing-prototyp=
es]
drivers/isdn/hardware/eicon/divasfunc.c:212:12: warning: no previous pr=
ototype for =E2=80=98divasfunc_init=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/divasfunc.c:233:6: warning: no previous pro=
totype for =E2=80=98divasfunc_exit=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/divasmain.c |    3 ---
 drivers/isdn/hardware/eicon/divasproc.c |    1 -
 drivers/isdn/hardware/eicon/platform.h  |    4 ++++
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/har=
dware/eicon/divasmain.c
index a2e0ed6..83a788f 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -58,9 +58,6 @@ char *DRIVERRELEASE_DIVAS =3D "2.0";
 extern irqreturn_t diva_os_irq_wrapper(int irq, void *context);
 extern int create_divas_proc(void);
 extern void remove_divas_proc(void);
-extern void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf=
);
-extern int divasfunc_init(int dbgmask);
-extern void divasfunc_exit(void);
=20
 typedef struct _diva_os_thread_dpc {
 	struct tasklet_struct divas_task;
diff --git a/drivers/isdn/hardware/eicon/divasproc.c b/drivers/isdn/har=
dware/eicon/divasproc.c
index edb7f39..9161393 100644
--- a/drivers/isdn/hardware/eicon/divasproc.c
+++ b/drivers/isdn/hardware/eicon/divasproc.c
@@ -34,7 +34,6 @@
=20
=20
 extern PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
-extern void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf=
);
=20
 /*********************************************************
  ** Functions for /proc interface / File operations
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index e861857..ef329e0 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -158,6 +158,10 @@ void divas_get_version(char *);
 void diva_xdi_didd_register_adapter(int card);
 void diva_xdi_didd_remove_adapter(int card);
=20
+void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf);
+int divasfunc_init(int dbgmask);
+void divasfunc_exit(void);
+
 /*
 ** memory allocation
 */
--=20
1.7.9.5
