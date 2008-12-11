From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 3/9][v2] mISDN: make global symbols static or include header files
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a29.05ae660a.58c7.314c@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758909AbYLKWyz@vger.kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The warnings fixed by including an header file for the appropriate
prototype are marked with "*", for all others the corresonponding
symbol has been made static.  This patch fixes all such issues in
mISDN.

Fix this sparse warnings:

  drivers/isdn/hardware/mISDN/hfcmulti.c:174:5: warning: symbol 'plxsd_master' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:426:1: warning: symbol 'write_fifo_regio' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:447:1: warning: symbol 'write_fifo_pcimem' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:469:1: warning: symbol 'read_fifo_regio' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:491:1: warning: symbol 'read_fifo_pcimem' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:710:1: warning: symbol 'vpm_init' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:793:1: warning: symbol 'vpm_check' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:816:1: warning: symbol 'vpm_echocan_on' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcmulti.c:848:1: warning: symbol 'vpm_echocan_off' was not declared. Should it be static?
* drivers/isdn/mISDN/l1oip_codec.c:224:1: warning: symbol 'l1oip_law_to_4bit' was not declared. Should it be static?
* drivers/isdn/mISDN/l1oip_codec.c:261:1: warning: symbol 'l1oip_4bit_to_law' was not declared. Should it be static?
* drivers/isdn/mISDN/l1oip_codec.c:281:1: warning: symbol 'l1oip_alaw_to_ulaw' was not declared. Should it be static?
* drivers/isdn/mISDN/l1oip_codec.c:294:1: warning: symbol 'l1oip_ulaw_to_alaw' was not declared. Should it be static?
* drivers/isdn/mISDN/l1oip_codec.c:311:1: warning: symbol 'l1oip_4bit_free' was not declared. Should it be static?
* drivers/isdn/mISDN/l1oip_codec.c:322:1: warning: symbol 'l1oip_4bit_alloc' was not declared. Should it be static?
  drivers/isdn/mISDN/core.c:29:1: warning: symbol 'device_lock' was not declared. Should it be static?
  drivers/isdn/mISDN/core.c:34:1: warning: symbol 'bp_lock' was not declared. Should it be static?
  drivers/isdn/mISDN/core.c:196:1: warning: symbol 'mISDNInit' was not declared. Should it be static?
  drivers/isdn/mISDN/core.c:227:6: warning: symbol 'mISDN_cleanup' was not declared. Should it be static?
  drivers/isdn/mISDN/stack.c:40:1: warning: symbol 'mISDN_queue_message' was not declared. Should it be static?
* drivers/isdn/mISDN/layer1.c:388:1: warning: symbol 'l1_init' was not declared. Should it be static?
* drivers/isdn/mISDN/layer1.c:400:1: warning: symbol 'l1_cleanup' was not declared. Should it be static?
  drivers/isdn/mISDN/layer2.c:469:1: warning: symbol 'iframe_error' was not declared. Should it be static?
  drivers/isdn/mISDN/layer2.c:487:1: warning: symbol 'super_error' was not declared. Should it be static?
  drivers/isdn/mISDN/layer2.c:496:1: warning: symbol 'unnum_error' was not declared. Should it be static?
  drivers/isdn/mISDN/layer2.c:509:1: warning: symbol 'UI_error' was not declared. Should it be static?
  drivers/isdn/mISDN/layer2.c:522:1: warning: symbol 'FRMR_error' was not declared. Should it be static?
  drivers/isdn/mISDN/layer2.c:1069:1: warning: symbol 'enquiry_cr' was not declared. Should it be static?
* drivers/isdn/mISDN/layer2.c:2196:1: warning: symbol 'Isdnl2_Init' was not declared. Should it be static?
* drivers/isdn/mISDN/layer2.c:2210:1: warning: symbol 'Isdnl2_cleanup' was not declared. Should it be static?
  drivers/isdn/mISDN/tei.c:397:1: warning: symbol 'random_ri' was not declared. Should it be static?
* drivers/isdn/mISDN/timerdev.c:277:1: warning: symbol 'mISDN_inittimer' was not declared. Should it be static?
* drivers/isdn/mISDN/timerdev.c:288:6: warning: symbol 'mISDN_timer_cleanup' was not declared. Should it be static?
  drivers/isdn/mISDN/dsp_core.c:164:12: warning: symbol 'mISDN_dsp_revision' was not declared. Should it be static?
  drivers/isdn/mISDN/dsp_cmx.c:1543:5: warning: symbol 'samplecount' was not declared. Should it be static?
  drivers/isdn/mISDN/dsp_cmx.c:1546:5: warning: symbol 'dsp_start_jiffies' was not declared. Should it be static?
  drivers/isdn/mISDN/dsp_cmx.c:1547:16: warning: symbol 'dsp_start_tv' was not declared. Should it be static?
  drivers/isdn/mISDN/dsp_tones.c:239:3: warning: symbol 'pattern' was not declared. Should it be static?
  drivers/isdn/mISDN/dsp_audio.c:33:4: warning: symbol 'dsp_audio_ulaw_to_alaw' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |   18 +++++++++---------
 drivers/isdn/mISDN/core.c              |    8 ++++----
 drivers/isdn/mISDN/dsp_audio.c         |    2 +-
 drivers/isdn/mISDN/dsp_cmx.c           |    6 +++---
 drivers/isdn/mISDN/dsp_core.c          |    2 +-
 drivers/isdn/mISDN/dsp_tones.c         |    2 +-
 drivers/isdn/mISDN/l1oip_codec.c       |    1 +
 drivers/isdn/mISDN/layer1.c            |    1 +
 drivers/isdn/mISDN/layer2.c            |   14 ++++++++------
 drivers/isdn/mISDN/stack.c             |    2 +-
 drivers/isdn/mISDN/tei.c               |    2 +-
 drivers/isdn/mISDN/timerdev.c          |    1 +
 12 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 46684e1..599d832 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -171,7 +171,7 @@ static int (*unregister_interrupt)(void);
 static int interrupt_registered;
 
 static struct hfc_multi *syncmaster;
-int plxsd_master; /* if we have a master card (yet) */
+static int plxsd_master; /* if we have a master card (yet) */
 static spinlock_t plx_lock; /* may not acquire other lock inside */
 EXPORT_SYMBOL(plx_lock);
 
@@ -422,7 +422,7 @@ HFC_wait_debug(struct hfc_multi *hc, const char *function, int line)
 #endif
 
 /* write fifo data (REGIO) */
-void
+static void
 write_fifo_regio(struct hfc_multi *hc, u_char *data, int len)
 {
 	outb(A_FIFO_DATA0, (hc->pci_iobase)+4);
@@ -443,7 +443,7 @@ write_fifo_regio(struct hfc_multi *hc, u_char *data, int len)
 	}
 }
 /* write fifo data (PCIMEM) */
-void
+static void
 write_fifo_pcimem(struct hfc_multi *hc, u_char *data, int len)
 {
 	while (len>>2) {
@@ -465,7 +465,7 @@ write_fifo_pcimem(struct hfc_multi *hc, u_char *data, int len)
 	}
 }
 /* read fifo data (REGIO) */
-void
+static void
 read_fifo_regio(struct hfc_multi *hc, u_char *data, int len)
 {
 	outb(A_FIFO_DATA0, (hc->pci_iobase)+4);
@@ -487,7 +487,7 @@ read_fifo_regio(struct hfc_multi *hc, u_char *data, int len)
 }
 
 /* read fifo data (PCIMEM) */
-void
+static void
 read_fifo_pcimem(struct hfc_multi *hc, u_char *data, int len)
 {
 	while (len>>2) {
@@ -706,7 +706,7 @@ vpm_out(struct hfc_multi *c, int which, unsigned short addr,
 }
 
 
-void
+static void
 vpm_init(struct hfc_multi *wc)
 {
 	unsigned char reg;
@@ -789,7 +789,7 @@ vpm_init(struct hfc_multi *wc)
 	}
 }
 
-void
+static void
 vpm_check(struct hfc_multi *hctmp)
 {
 	unsigned char gpi2;
@@ -812,7 +812,7 @@ vpm_check(struct hfc_multi *hctmp)
  *
  */
 
-void
+static void
 vpm_echocan_on(struct hfc_multi *hc, int ch, int taps)
 {
 	unsigned int timeslot;
@@ -844,7 +844,7 @@ vpm_echocan_on(struct hfc_multi *hc, int ch, int taps)
 	vpm_out(hc, unit, timeslot, 0x7e);
 }
 
-void
+static void
 vpm_echocan_off(struct hfc_multi *hc, int ch)
 {
 	unsigned int timeslot;
diff --git a/drivers/isdn/mISDN/core.c b/drivers/isdn/mISDN/core.c
index 3306817..751665c 100644
--- a/drivers/isdn/mISDN/core.c
+++ b/drivers/isdn/mISDN/core.c
@@ -26,12 +26,12 @@ MODULE_LICENSE("GPL");
 module_param(debug, uint, S_IRUGO | S_IWUSR);
 
 static LIST_HEAD(devices);
-DEFINE_RWLOCK(device_lock);
+static DEFINE_RWLOCK(device_lock);
 static u64		device_ids;
 #define MAX_DEVICE_ID	63
 
 static LIST_HEAD(Bprotocols);
-DEFINE_RWLOCK(bp_lock);
+static DEFINE_RWLOCK(bp_lock);
 
 struct mISDNdevice
 *get_mdevice(u_int id)
@@ -192,7 +192,7 @@ mISDN_unregister_Bprotocol(struct Bprotocol *bp)
 }
 EXPORT_SYMBOL(mISDN_unregister_Bprotocol);
 
-int
+static int
 mISDNInit(void)
 {
 	int	err;
@@ -224,7 +224,7 @@ error:
 	return err;
 }
 
-void mISDN_cleanup(void)
+static void mISDN_cleanup(void)
 {
 	misdn_sock_cleanup();
 	mISDN_timer_cleanup();
diff --git a/drivers/isdn/mISDN/dsp_audio.c b/drivers/isdn/mISDN/dsp_audio.c
index 1c2dd56..de3795e 100644
--- a/drivers/isdn/mISDN/dsp_audio.c
+++ b/drivers/isdn/mISDN/dsp_audio.c
@@ -30,7 +30,7 @@ EXPORT_SYMBOL(dsp_audio_s16_to_law);
 /* alaw -> ulaw */
 u8 dsp_audio_alaw_to_ulaw[256];
 /* ulaw -> alaw */
-u8 dsp_audio_ulaw_to_alaw[256];
+static u8 dsp_audio_ulaw_to_alaw[256];
 u8 dsp_silence;
 
 
diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index c2f51cc..e868c47 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1540,11 +1540,11 @@ send_packet:
 	schedule_work(&dsp->workq);
 }
 
-u32	samplecount;
+static u32	samplecount;
 struct timer_list dsp_spl_tl;
 u32	dsp_spl_jiffies; /* calculate the next time to fire */
-u32	dsp_start_jiffies; /* jiffies at the time, the calculation begins */
-struct timeval dsp_start_tv; /* time at start of calculation */
+static u32	dsp_start_jiffies; /* jiffies at the time, the calculation begins */
+static struct timeval dsp_start_tv; /* time at start of calculation */
 
 void
 dsp_cmx_send(void *arg)
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 2f10ed8..41af063 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -161,7 +161,7 @@
 #include "core.h"
 #include "dsp.h"
 
-const char *mISDN_dsp_revision = "2.0";
+static const char *mISDN_dsp_revision = "2.0";
 
 static int debug;
 static int options;
diff --git a/drivers/isdn/mISDN/dsp_tones.c b/drivers/isdn/mISDN/dsp_tones.c
index de4d0c9..7a9af66 100644
--- a/drivers/isdn/mISDN/dsp_tones.c
+++ b/drivers/isdn/mISDN/dsp_tones.c
@@ -231,7 +231,7 @@ dsp_audio_generate_ulaw_samples(void)
  * tone sequence definition *
  ****************************/
 
-struct pattern {
+static struct pattern {
 	int tone;
 	u8 *data[10];
 	u32 *siz[10];
diff --git a/drivers/isdn/mISDN/l1oip_codec.c b/drivers/isdn/mISDN/l1oip_codec.c
index a2dc457..2ec4b28 100644
--- a/drivers/isdn/mISDN/l1oip_codec.c
+++ b/drivers/isdn/mISDN/l1oip_codec.c
@@ -49,6 +49,7 @@ NOTE: The bytes are handled as they are law-encoded.
 #include <linux/vmalloc.h>
 #include <linux/mISDNif.h>
 #include "core.h"
+#include "l1oip.h"
 
 /* definitions of codec. don't use calculations, code may run slower. */
 
diff --git a/drivers/isdn/mISDN/layer1.c b/drivers/isdn/mISDN/layer1.c
index 4a55d63..b73e952 100644
--- a/drivers/isdn/mISDN/layer1.c
+++ b/drivers/isdn/mISDN/layer1.c
@@ -18,6 +18,7 @@
 
 #include <linux/module.h>
 #include <linux/mISDNhw.h>
+#include "core.h"
 #include "layer1.h"
 #include "fsm.h"
 
diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 77fca3b..d6e2863 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -15,6 +15,8 @@
  *
  */
 
+#include <linux/mISDNif.h>
+#include "core.h"
 #include "fsm.h"
 #include "layer2.h"
 
@@ -465,7 +467,7 @@ IsRNR(u_char *data, struct layer2 *l2)
 	    data[0] == RNR : (data[0] & 0xf) == RNR;
 }
 
-int
+static int
 iframe_error(struct layer2 *l2, struct sk_buff *skb)
 {
 	u_int	i;
@@ -483,7 +485,7 @@ iframe_error(struct layer2 *l2, struct sk_buff *skb)
 	return 0;
 }
 
-int
+static int
 super_error(struct layer2 *l2, struct sk_buff *skb)
 {
 	if (skb->len != l2addrsize(l2) +
@@ -492,7 +494,7 @@ super_error(struct layer2 *l2, struct sk_buff *skb)
 	return 0;
 }
 
-int
+static int
 unnum_error(struct layer2 *l2, struct sk_buff *skb, int wantrsp)
 {
 	int rsp = (*skb->data & 0x2) >> 1;
@@ -505,7 +507,7 @@ unnum_error(struct layer2 *l2, struct sk_buff *skb, int wantrsp)
 	return 0;
 }
 
-int
+static int
 UI_error(struct layer2 *l2, struct sk_buff *skb)
 {
 	int rsp = *skb->data & 0x2;
@@ -518,7 +520,7 @@ UI_error(struct layer2 *l2, struct sk_buff *skb)
 	return 0;
 }
 
-int
+static int
 FRMR_error(struct layer2 *l2, struct sk_buff *skb)
 {
 	u_int	headers = l2addrsize(l2) + 1;
@@ -1065,7 +1067,7 @@ l2_st6_dm_release(struct FsmInst *fi, int event, void *arg)
 	}
 }
 
-void
+static void
 enquiry_cr(struct layer2 *l2, u_char typ, u_char cr, u_char pf)
 {
 	struct sk_buff *skb;
diff --git a/drivers/isdn/mISDN/stack.c b/drivers/isdn/mISDN/stack.c
index 54cfddc..d55b14a 100644
--- a/drivers/isdn/mISDN/stack.c
+++ b/drivers/isdn/mISDN/stack.c
@@ -36,7 +36,7 @@ _queue_message(struct mISDNstack *st, struct sk_buff *skb)
 	}
 }
 
-int
+static int
 mISDN_queue_message(struct mISDNchannel *ch, struct sk_buff *skb)
 {
 	_queue_message(ch->st, skb);
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index 6fbae42..1a824e7 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -393,7 +393,7 @@ dl_unit_data(struct manager *mgr, struct sk_buff *skb)
 	return 0;
 }
 
-unsigned int
+static unsigned int
 random_ri(void)
 {
 	u16 x;
diff --git a/drivers/isdn/mISDN/timerdev.c b/drivers/isdn/mISDN/timerdev.c
index a8d1d9f..62b5e49 100644
--- a/drivers/isdn/mISDN/timerdev.c
+++ b/drivers/isdn/mISDN/timerdev.c
@@ -23,6 +23,7 @@
 #include <linux/miscdevice.h>
 #include <linux/module.h>
 #include <linux/mISDNif.h>
+#include "core.h"
 
 static u_int	*debug;
 
-- 
1.5.6.3
