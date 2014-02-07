From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 04/26] drivers: isdn: Add prototype declaration to header
 file platform.h from capifunc.c
Date: Fri, 7 Feb 2014 17:51:18 +0530
Message-ID: <3e85b310587ff4346191ad1dc19aaeee5ddb8240.1390408514.git.rashika.kheria@gmail.com>
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

Move prototype declarations of function to header file
hardware/eicon/um_idi.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/um_idi.c:
drivers/isdn/hardware/eicon/um_idi.c:83:6: warning: no previous prototy=
pe for =E2=80=98diva_user_mode_idi_remove_adapter=E2=80=99 [-Wmissing-p=
rototypes]
drivers/isdn/hardware/eicon/um_idi.c:121:5: warning: no previous protot=
ype for =E2=80=98diva_user_mode_idi_create_adapter=E2=80=99 [-Wmissing-=
prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/capifunc.c |    1 -
 drivers/isdn/hardware/eicon/platform.h |    4 ++++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hard=
ware/eicon/capifunc.c
index 7a0bdbd..8991b0c 100644
--- a/drivers/isdn/hardware/eicon/capifunc.c
+++ b/drivers/isdn/hardware/eicon/capifunc.c
@@ -55,7 +55,6 @@ static void diva_release_appl(struct capi_ctr *, __u1=
6);
 static char *diva_procinfo(struct capi_ctr *);
 static u16 diva_send_message(struct capi_ctr *,
 			     diva_os_message_buffer_s *);
-extern void diva_os_set_controller_struct(struct capi_ctr *);
=20
 extern void DIVA_DIDD_Read(DESCRIPTOR *, int);
=20
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index b2edb75..cdfbb19 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -28,6 +28,7 @@
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/list.h>
+#include <linux/isdn/capilli.h>
 #include <asm/types.h>
 #include <asm/io.h>
=20
@@ -179,6 +180,9 @@ static __inline__ void diva_os_free(unsigned long f=
lags, void *ptr)
 typedef struct sk_buff diva_os_message_buffer_s;
 diva_os_message_buffer_s *diva_os_alloc_message_buffer(unsigned long s=
ize, void **data_buf);
 void diva_os_free_message_buffer(diva_os_message_buffer_s *dmb);
+
+void diva_os_set_controller_struct(struct capi_ctr *);
+
 #define DIVA_MESSAGE_BUFFER_LEN(x) x->len
 #define DIVA_MESSAGE_BUFFER_DATA(x) x->data
=20
--=20
1.7.9.5
