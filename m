From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 1/6] isdn/eicon: add function declarations
Date: Sat, 24 Sep 2016 13:16:44 +0800
Message-ID: <1474694204-21563-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: mac@melware.de, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a few warnings when building kernel with W=1:
drivers/isdn/hardware/eicon/diddfunc.c:95:12: warning: no previous prototype for 'diddfunc_init' [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/s_4bri.c:128:6: warning: no previous prototype for 'start_qBri_hardware' [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/idifunc.c:243:12: warning: no previous prototype for 'idifunc_init' [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/capifunc.c:217:6: warning: no previous prototype for 'api_remove_complete' [-Wmissing-prototypes]
....

In fact, these functions need be declare in some header files.

So this patch adds function declarations in
drivers/isdn/hardware/eicon/di_defs.h,
drivers/isdn/hardware/eicon/capifunc.h,
drivers/isdn/hardware/eicon/xdi_adapter.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hardware/eicon/capifunc.c    |  3 --
 drivers/isdn/hardware/eicon/capifunc.h    |  1 +
 drivers/isdn/hardware/eicon/di_defs.h     | 46 +++++++++++++++++++++++++++++++
 drivers/isdn/hardware/eicon/diva.c        |  2 --
 drivers/isdn/hardware/eicon/diva_didd.c   |  5 ----
 drivers/isdn/hardware/eicon/divacapi.h    |  6 ++++
 drivers/isdn/hardware/eicon/divamnt.c     |  4 ---
 drivers/isdn/hardware/eicon/divasi.c      |  3 --
 drivers/isdn/hardware/eicon/divasmain.c   |  5 ----
 drivers/isdn/hardware/eicon/divasproc.c   |  2 --
 drivers/isdn/hardware/eicon/idifunc.c     |  2 --
 drivers/isdn/hardware/eicon/message.c     | 11 --------
 drivers/isdn/hardware/eicon/mntfunc.c     |  5 ----
 drivers/isdn/hardware/eicon/os_4bri.c     | 13 ---------
 drivers/isdn/hardware/eicon/os_bri.c      |  7 -----
 drivers/isdn/hardware/eicon/os_pri.c      |  6 ----
 drivers/isdn/hardware/eicon/um_idi.c      |  5 ----
 drivers/isdn/hardware/eicon/xdi_adapter.h |  6 ++++
 18 files changed, 59 insertions(+), 73 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hardware/eicon/capifunc.c
index 7a0bdbd..869b98e 100644
--- a/drivers/isdn/hardware/eicon/capifunc.c
+++ b/drivers/isdn/hardware/eicon/capifunc.c
@@ -55,9 +55,6 @@ static void diva_release_appl(struct capi_ctr *, __u16);
 static char *diva_procinfo(struct capi_ctr *);
 static u16 diva_send_message(struct capi_ctr *,
 			     diva_os_message_buffer_s *);
-extern void diva_os_set_controller_struct(struct capi_ctr *);
-
-extern void DIVA_DIDD_Read(DESCRIPTOR *, int);
 
 /*
  * debug
diff --git a/drivers/isdn/hardware/eicon/capifunc.h b/drivers/isdn/hardware/eicon/capifunc.h
index e96c45b..4bd0f20 100644
--- a/drivers/isdn/hardware/eicon/capifunc.h
+++ b/drivers/isdn/hardware/eicon/capifunc.h
@@ -36,5 +36,6 @@ typedef struct _diva_card {
  */
 int init_capifunc(void);
 void finit_capifunc(void);
+void diva_os_set_controller_struct(struct capi_ctr *);
 
 #endif /* __CAPIFUNC_H__ */
diff --git a/drivers/isdn/hardware/eicon/di_defs.h b/drivers/isdn/hardware/eicon/di_defs.h
index a5094d2..ed744aa 100644
--- a/drivers/isdn/hardware/eicon/di_defs.h
+++ b/drivers/isdn/hardware/eicon/di_defs.h
@@ -179,3 +179,49 @@ typedef void (IDI_CALL_LINK_T *didd_adapter_change_callback_t)(void IDI_CALL_ENT
 #define DI_VOICE_OVER_IP  0x0800 /* Voice over IP support */
 typedef void (IDI_CALL_LINK_T *_IDI_CALL)(void *, ENTITY *);
 #endif
+
+int diddfunc_init(void);
+void diddfunc_finit(void);
+
+void DIVA_DIDD_Read(void *, int);
+
+int divasfunc_init(int dbgmask);
+void divasfunc_exit(void);
+irqreturn_t diva_os_irq_wrapper(int irq, void *context);
+void diva_xdi_display_adapter_features(int card);
+int create_divas_proc(void);
+void remove_divas_proc(void);
+void prepare_maestra_functions(PISDN_ADAPTER IoAdapter);
+void start_qBri_hardware(PISDN_ADAPTER IoAdapter);
+int qBri_FPGA_download(PISDN_ADAPTER IoAdapter);
+void prepare_qBri_functions(PISDN_ADAPTER IoAdapter);
+void prepare_qBri2_functions(PISDN_ADAPTER IoAdapter);
+
+void prepare_pri_functions(PISDN_ADAPTER IoAdapter);
+void prepare_pri2_functions(PISDN_ADAPTER IoAdapter);
+
+int diva_os_copy_to_user(void *os_handle, void __user *dst,
+			 const void *src, int length);
+int diva_os_copy_from_user(void *os_handle, void *dst,
+			   const void __user *src, int length);
+
+int mntfunc_init(int *, void **, unsigned long);
+void mntfunc_finit(void);
+int maint_read_write(void __user *buf, int count);
+
+void diva_os_wakeup_read(void *os_context);
+void diva_os_wakeup_close(void *os_context);
+
+int idifunc_init(void);
+void idifunc_finit(void);
+
+void diva_user_mode_idi_remove_adapter(int);
+int diva_user_mode_idi_create_adapter(const DESCRIPTOR *, int);
+
+void divas_get_version(char *);
+void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf);
+
+byte MapController(byte);
+
+int fax_head_line_time(char *buffer);
+void api_remove_complete(void);
diff --git a/drivers/isdn/hardware/eicon/diva.c b/drivers/isdn/hardware/eicon/diva.c
index d91dd58..9693add 100644
--- a/drivers/isdn/hardware/eicon/diva.c
+++ b/drivers/isdn/hardware/eicon/diva.c
@@ -28,8 +28,6 @@
 
 PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
 extern IDI_CALL Requests[MAX_ADAPTER];
-extern int create_adapter_proc(diva_os_xdi_adapter_t *a);
-extern void remove_adapter_proc(diva_os_xdi_adapter_t *a);
 
 #define DivaIdiReqFunc(N)						\
 	static void DivaIdiRequest##N(ENTITY *e)			\
diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/hardware/eicon/diva_didd.c
index fab6ccf..b8e525f 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -39,11 +39,6 @@ MODULE_LICENSE("GPL");
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
 
-extern int diddfunc_init(void);
-extern void diddfunc_finit(void);
-
-extern void DIVA_DIDD_Read(void *, int);
-
 static struct proc_dir_entry *proc_didd;
 struct proc_dir_entry *proc_net_eicon = NULL;
 
diff --git a/drivers/isdn/hardware/eicon/divacapi.h b/drivers/isdn/hardware/eicon/divacapi.h
index a315a29..6a28149 100644
--- a/drivers/isdn/hardware/eicon/divacapi.h
+++ b/drivers/isdn/hardware/eicon/divacapi.h
@@ -1358,3 +1358,9 @@ extern word li_total_channels;
 #define NCPI_MDM_DCD_ON_RECEIVED   0x80
 
 /*------------------------------------------------------------------*/
+
+void sendf(APPL *, word, dword, word, byte *, ...);
+void *TransmitBufferSet(APPL *appl, dword ref);
+void *TransmitBufferGet(APPL *appl, void *p);
+void TransmitBufferFree(APPL *appl, void *p);
+void *ReceiveBufferGet(APPL *appl, int Num);
diff --git a/drivers/isdn/hardware/eicon/divamnt.c b/drivers/isdn/hardware/eicon/divamnt.c
index 0de29b7b..6a4fa56 100644
--- a/drivers/isdn/hardware/eicon/divamnt.c
+++ b/drivers/isdn/hardware/eicon/divamnt.c
@@ -46,10 +46,6 @@ char *DRIVERRELEASE_MNT = "2.0";
 static wait_queue_head_t msgwaitq;
 static unsigned long opened;
 
-extern int mntfunc_init(int *, void **, unsigned long);
-extern void mntfunc_finit(void);
-extern int maint_read_write(void __user *buf, int count);
-
 /*
  *  helper functions
  */
diff --git a/drivers/isdn/hardware/eicon/divasi.c b/drivers/isdn/hardware/eicon/divasi.c
index 4103a8c..c2a6f1a 100644
--- a/drivers/isdn/hardware/eicon/divasi.c
+++ b/drivers/isdn/hardware/eicon/divasi.c
@@ -48,9 +48,6 @@ static char *DRIVERLNAME = "diva_idi";
 static char *DEVNAME = "DivasIDI";
 char *DRIVERRELEASE_IDI = "2.0";
 
-extern int idifunc_init(void);
-extern void idifunc_finit(void);
-
 /*
  *  helper functions
  */
diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index 32f3451..854ffb6 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -55,12 +55,7 @@ static char *DRIVERLNAME = "divas";
 static char *DEVNAME = "Divas";
 char *DRIVERRELEASE_DIVAS = "2.0";
 
-extern irqreturn_t diva_os_irq_wrapper(int irq, void *context);
-extern int create_divas_proc(void);
-extern void remove_divas_proc(void);
 extern void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf);
-extern int divasfunc_init(int dbgmask);
-extern void divasfunc_exit(void);
 
 typedef struct _diva_os_thread_dpc {
 	struct tasklet_struct divas_task;
diff --git a/drivers/isdn/hardware/eicon/divasproc.c b/drivers/isdn/hardware/eicon/divasproc.c
index 56ce98a..9161393 100644
--- a/drivers/isdn/hardware/eicon/divasproc.c
+++ b/drivers/isdn/hardware/eicon/divasproc.c
@@ -34,8 +34,6 @@
 
 
 extern PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
-extern void divas_get_version(char *);
-extern void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf);
 
 /*********************************************************
  ** Functions for /proc interface / File operations
diff --git a/drivers/isdn/hardware/eicon/idifunc.c b/drivers/isdn/hardware/eicon/idifunc.c
index fef6586..bacab74 100644
--- a/drivers/isdn/hardware/eicon/idifunc.c
+++ b/drivers/isdn/hardware/eicon/idifunc.c
@@ -22,8 +22,6 @@
 extern char *DRIVERRELEASE_IDI;
 
 extern void DIVA_DIDD_Read(void *, int);
-extern int diva_user_mode_idi_create_adapter(const DESCRIPTOR *, int);
-extern void diva_user_mode_idi_remove_adapter(int);
 
 static dword notify_handle;
 static DESCRIPTOR DAdapter;
diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index 1a1d997..8495bf15 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -84,7 +84,6 @@ static void api_save_msg(API_PARSE *in, byte *format, API_SAVE *out);
 static void api_load_msg(API_SAVE *in, API_PARSE *out);
 
 word api_remove_start(void);
-void api_remove_complete(void);
 
 static void plci_remove(PLCI *);
 static void diva_get_extended_adapter_features(DIVA_CAPI_ADAPTER *a);
@@ -224,20 +223,10 @@ static void diva_free_dma_descriptor(PLCI *plci, int nr);
 /* external function prototypes                                     */
 /*------------------------------------------------------------------*/
 
-extern byte MapController(byte);
 extern byte UnMapController(byte);
 #define MapId(Id)(((Id) & 0xffffff00L) | MapController((byte)(Id)))
 #define UnMapId(Id)(((Id) & 0xffffff00L) | UnMapController((byte)(Id)))
 
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
diff --git a/drivers/isdn/hardware/eicon/mntfunc.c b/drivers/isdn/hardware/eicon/mntfunc.c
index 1cd9aff..e304a1d 100644
--- a/drivers/isdn/hardware/eicon/mntfunc.c
+++ b/drivers/isdn/hardware/eicon/mntfunc.c
@@ -29,11 +29,6 @@ static DESCRIPTOR MAdapter;
 static DESCRIPTOR MaintDescriptor =
 { IDI_DIMAINT, 0, 0, (IDI_CALL) diva_maint_prtComp };
 
-extern int diva_os_copy_to_user(void *os_handle, void __user *dst,
-				const void *src, int length);
-extern int diva_os_copy_from_user(void *os_handle, void *dst,
-				  const void __user *src, int length);
-
 static void no_printf(unsigned char *x, ...)
 {
 	/* dummy debug function */
diff --git a/drivers/isdn/hardware/eicon/os_4bri.c b/drivers/isdn/hardware/eicon/os_4bri.c
index 1891246..80470d6 100644
--- a/drivers/isdn/hardware/eicon/os_4bri.c
+++ b/drivers/isdn/hardware/eicon/os_4bri.c
@@ -22,19 +22,6 @@ static void *diva_xdiLoadFileFile = NULL;
 static dword diva_xdiLoadFileLength = 0;
 
 /*
-**  IMPORTS
-*/
-extern void prepare_qBri_functions(PISDN_ADAPTER IoAdapter);
-extern void prepare_qBri2_functions(PISDN_ADAPTER IoAdapter);
-extern void diva_xdi_display_adapter_features(int card);
-extern void diva_add_slave_adapter(diva_os_xdi_adapter_t *a);
-
-extern int qBri_FPGA_download(PISDN_ADAPTER IoAdapter);
-extern void start_qBri_hardware(PISDN_ADAPTER IoAdapter);
-
-extern int diva_card_read_xlog(diva_os_xdi_adapter_t *a);
-
-/*
 **  LOCALS
 */
 static unsigned long _4bri_bar_length[4] = {
diff --git a/drivers/isdn/hardware/eicon/os_bri.c b/drivers/isdn/hardware/eicon/os_bri.c
index 20f2653..6570abf 100644
--- a/drivers/isdn/hardware/eicon/os_bri.c
+++ b/drivers/isdn/hardware/eicon/os_bri.c
@@ -19,13 +19,6 @@
 #include "dsrv_bri.h"
 
 /*
-**  IMPORTS
-*/
-extern void prepare_maestra_functions(PISDN_ADAPTER IoAdapter);
-extern void diva_xdi_display_adapter_features(int card);
-extern int diva_card_read_xlog(diva_os_xdi_adapter_t *a);
-
-/*
 **  LOCALS
 */
 static int bri_bar_length[3] = {
diff --git a/drivers/isdn/hardware/eicon/os_pri.c b/drivers/isdn/hardware/eicon/os_pri.c
index da4957a..51a79a3 100644
--- a/drivers/isdn/hardware/eicon/os_pri.c
+++ b/drivers/isdn/hardware/eicon/os_pri.c
@@ -28,15 +28,9 @@
 
 #define DIVA_PRI_NO_PCI_BIOS_WORKAROUND 1
 
-extern int diva_card_read_xlog(diva_os_xdi_adapter_t *a);
-
 /*
 **  IMPORTS
 */
-extern void prepare_pri_functions(PISDN_ADAPTER IoAdapter);
-extern void prepare_pri2_functions(PISDN_ADAPTER IoAdapter);
-extern void diva_xdi_display_adapter_features(int card);
-
 static int diva_pri_cleanup_adapter(diva_os_xdi_adapter_t *a);
 static int diva_pri_cmd_card_proc(struct _diva_os_xdi_adapter *a,
 				  diva_xdi_um_cfg_cmd_t *cmd, int length);
diff --git a/drivers/isdn/hardware/eicon/um_idi.c b/drivers/isdn/hardware/eicon/um_idi.c
index e151971..676663a 100644
--- a/drivers/isdn/hardware/eicon/um_idi.c
+++ b/drivers/isdn/hardware/eicon/um_idi.c
@@ -14,11 +14,6 @@
 #define DIVAS_MAX_XDI_ADAPTERS	64
 
 /* --------------------------------------------------------------------------
-   IMPORTS
-   -------------------------------------------------------------------------- */
-extern void diva_os_wakeup_read(void *os_context);
-extern void diva_os_wakeup_close(void *os_context);
-/* --------------------------------------------------------------------------
    LOCALS
    -------------------------------------------------------------------------- */
 static LIST_HEAD(adapter_q);
diff --git a/drivers/isdn/hardware/eicon/xdi_adapter.h b/drivers/isdn/hardware/eicon/xdi_adapter.h
index d303e65..7900741 100644
--- a/drivers/isdn/hardware/eicon/xdi_adapter.h
+++ b/drivers/isdn/hardware/eicon/xdi_adapter.h
@@ -67,4 +67,10 @@ typedef struct _diva_os_xdi_adapter {
 	dword dsp_mask;
 } diva_os_xdi_adapter_t;
 
+void diva_add_slave_adapter(diva_os_xdi_adapter_t *a);
+int diva_card_read_xlog(diva_os_xdi_adapter_t *a);
+
+int create_adapter_proc(diva_os_xdi_adapter_t *a);
+void remove_adapter_proc(diva_os_xdi_adapter_t *a);
+
 #endif
-- 
2.7.4
