From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 11/26] drivers: isdn: Move prototype declarations to header
 file platform.h from mntfunc.c
Date: Fri, 7 Feb 2014 18:03:00 +0530
Message-ID: <8590a8fab9971fc353e0dd4d46c33a3f8ecc18bb.1390408516.git.rashika.kheria@gmail.com>
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

This eliminates the following warnings in hardware/eicon/divamnt.c:
drivers/isdn/hardware/eicon/divamnt.c:75:5: warning: no previous protot=
ype for =E2=80=98diva_os_copy_to_user=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/divamnt.c:80:5: warning: no previous protot=
ype for =E2=80=98diva_os_copy_from_user=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/mntfunc.c  |    5 -----
 drivers/isdn/hardware/eicon/platform.h |    9 +++++++++
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/mntfunc.c b/drivers/isdn/hardw=
are/eicon/mntfunc.c
index 1cd9aff..e304a1d 100644
--- a/drivers/isdn/hardware/eicon/mntfunc.c
+++ b/drivers/isdn/hardware/eicon/mntfunc.c
@@ -29,11 +29,6 @@ static DESCRIPTOR MAdapter;
 static DESCRIPTOR MaintDescriptor =3D
 { IDI_DIMAINT, 0, 0, (IDI_CALL) diva_maint_prtComp };
=20
-extern int diva_os_copy_to_user(void *os_handle, void __user *dst,
-				const void *src, int length);
-extern int diva_os_copy_from_user(void *os_handle, void *dst,
-				  const void __user *src, int length);
-
 static void no_printf(unsigned char *x, ...)
 {
 	/* dummy debug function */
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index ef329e0..f170e21 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -277,6 +277,15 @@ void diva_os_remove_soft_isr(diva_os_soft_isr_t *p=
soft_isr);
 void diva_os_get_time(dword *sec, dword *usec);
=20
 /*
+ * kernel/user space copy functions
+ */
+int diva_os_copy_to_user(void *os_handle, void __user *dst,
+			 const void *src, int length);
+int diva_os_copy_from_user(void *os_handle, void *dst,
+			   const void __user *src, int length);
+
+
+/*
 **  atomic operation, fake because we use threads
 */
 typedef int diva_os_atomic_t;
--=20
1.7.9.5
