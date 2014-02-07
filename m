From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 05/26] drivers: isdn: Move prototype declarations to header
 file capifunc.h from message.c
Date: Fri, 7 Feb 2014 17:54:08 +0530
Message-ID: <1f531b30ed44af6d6c8c65e6b16dbfa204c48d9e.1390408514.git.rashika.kheria@gmail.com>
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
hardware/eicon/capifunc.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/capifunc.c:
drivers/isdn/hardware/eicon/capifunc.c:113:6: warning: no previous prot=
otype for =E2=80=98MapController=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:188:7: warning: no previous prot=
otype for =E2=80=98TransmitBufferSet=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:195:7: warning: no previous prot=
otype for =E2=80=98TransmitBufferGet=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:203:6: warning: no previous prot=
otype for =E2=80=98TransmitBufferFree=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:209:7: warning: no previous prot=
otype for =E2=80=98ReceiveBufferGet=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:217:6: warning: no previous prot=
otype for =E2=80=98api_remove_complete=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:225:6: warning: no previous prot=
otype for =E2=80=98sendf=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:1115:5: warning: no previous pro=
totype for =E2=80=98fax_head_line_time=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/capifunc.h |    8 ++++++++
 drivers/isdn/hardware/eicon/message.c  |   12 +-----------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capifunc.h b/drivers/isdn/hard=
ware/eicon/capifunc.h
index e96c45b..fb7091e 100644
--- a/drivers/isdn/hardware/eicon/capifunc.h
+++ b/drivers/isdn/hardware/eicon/capifunc.h
@@ -36,5 +36,13 @@ typedef struct _diva_card {
  */
 int init_capifunc(void);
 void finit_capifunc(void);
+byte MapController(byte);
+void *TransmitBufferSet(APPL *appl, dword ref);
+void *TransmitBufferGet(APPL *appl, void *p);
+void TransmitBufferFree(APPL *appl, void *p);
+void *ReceiveBufferGet(APPL *appl, int Num);
+void api_remove_complete(void);
+void sendf(APPL *, word, dword, word, byte *, ...);
+int fax_head_line_time(char *buffer);
=20
 #endif /* __CAPIFUNC_H__ */
diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardw=
are/eicon/message.c
index a82e542..062cb7b 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -32,6 +32,7 @@
 #include "pc.h"
 #include "capi20.h"
 #include "divacapi.h"
+#include "capifunc.h"
 #include "mdm_msg.h"
 #include "divasync.h"
=20
@@ -84,7 +85,6 @@ static void api_save_msg(API_PARSE *in, byte *format,=
 API_SAVE *out);
 static void api_load_msg(API_SAVE *in, API_PARSE *out);
=20
 word api_remove_start(void);
-void api_remove_complete(void);
=20
 static void plci_remove(PLCI *);
 static void diva_get_extended_adapter_features(DIVA_CAPI_ADAPTER *a);
@@ -224,20 +224,10 @@ static void diva_free_dma_descriptor(PLCI *plci, =
int nr);
 /* external function prototypes                                     */
 /*------------------------------------------------------------------*/
=20
-extern byte MapController(byte);
 extern byte UnMapController(byte);
 #define MapId(Id)(((Id) & 0xffffff00L) | MapController((byte)(Id)))
 #define UnMapId(Id)(((Id) & 0xffffff00L) | UnMapController((byte)(Id))=
)
=20
-void sendf(APPL *, word, dword, word, byte *, ...);
-void *TransmitBufferSet(APPL *appl, dword ref);
-void *TransmitBufferGet(APPL *appl, void *p);
-void TransmitBufferFree(APPL *appl, void *p);
-void *ReceiveBufferGet(APPL *appl, int Num);
-
-int fax_head_line_time(char *buffer);
-
-
 /*------------------------------------------------------------------*/
 /* Global data definitions                                          */
 /*------------------------------------------------------------------*/
--=20
1.7.9.5
