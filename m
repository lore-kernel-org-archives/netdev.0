From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Remove bogus dosyncppp variable from synclink drivers.
Date: Wed, 02 Jul 2008 21:10:30 +0200
Message-ID: <m3tzf83xw9.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57324 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbYGBTX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

Remove bogus dosyncppp variable from synclink drivers.

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index fb2fb15..cddfb11 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -232,7 +232,6 @@ typedef struct _mgslpc_info {
 
 	/* SPPP/Cisco HDLC device parts */
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 
 #if SYNCLINK_GENERIC_HDLC
@@ -459,13 +458,11 @@ static int ttymajor=0;
 
 static int debug_level = 0;
 static int maxframe[MAX_DEVICE_COUNT] = {0,};
-static int dosyncppp[MAX_DEVICE_COUNT] = {1,1,1,1};
 
 module_param(break_on_load, bool, 0);
 module_param(ttymajor, int, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 
 MODULE_LICENSE("GPL");
 
@@ -2914,7 +2911,6 @@ static void mgslpc_add_device(MGSLPC_INFO *info)
 	if (info->line < MAX_DEVICE_COUNT) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 	}
 
 	mgslpc_device_count++;
diff --git a/drivers/char/synclink.c b/drivers/char/synclink.c
index 9d247d8..9b1748f 100644
--- a/drivers/char/synclink.c
+++ b/drivers/char/synclink.c
@@ -312,7 +312,6 @@ struct mgsl_struct {
 
 	/* generic HDLC device parts */
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 
 #if SYNCLINK_GENERIC_HDLC
@@ -876,7 +875,6 @@ static int irq[MAX_ISA_DEVICES];
 static int dma[MAX_ISA_DEVICES];
 static int debug_level;
 static int maxframe[MAX_TOTAL_DEVICES];
-static int dosyncppp[MAX_TOTAL_DEVICES];
 static int txdmabufs[MAX_TOTAL_DEVICES];
 static int txholdbufs[MAX_TOTAL_DEVICES];
 	
@@ -887,7 +885,6 @@ module_param_array(irq, int, NULL, 0);
 module_param_array(dma, int, NULL, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 module_param_array(txdmabufs, int, NULL, 0);
 module_param_array(txholdbufs, int, NULL, 0);
 
@@ -4265,7 +4262,6 @@ static void mgsl_add_device( struct mgsl_struct *info )
 	if (info->line < MAX_TOTAL_DEVICES) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 
 		if (txdmabufs[info->line]) {
 			info->num_tx_dma_buffers = txdmabufs[info->line];
diff --git a/drivers/char/synclink_gt.c b/drivers/char/synclink_gt.c
index d88a607..aa4e1f2 100644
--- a/drivers/char/synclink_gt.c
+++ b/drivers/char/synclink_gt.c
@@ -128,17 +128,14 @@ static int slgt_device_count;
 static int ttymajor;
 static int debug_level;
 static int maxframe[MAX_DEVICES];
-static int dosyncppp[MAX_DEVICES];
 
 module_param(ttymajor, int, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 
 MODULE_PARM_DESC(ttymajor, "TTY major device number override: 0=auto assigned");
 MODULE_PARM_DESC(debug_level, "Debug syslog output: 0=disabled, 1 to 5=increasing detail");
 MODULE_PARM_DESC(maxframe, "Maximum frame size used by device (4096 to 65535)");
-MODULE_PARM_DESC(dosyncppp, "Enable synchronous net device, 0=disable 1=enable");
 
 /*
  * tty support and callbacks
@@ -356,7 +353,6 @@ struct slgt_info {
 	/* SPPP/Cisco HDLC device parts */
 
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 #if SYNCLINK_GENERIC_HDLC
 	struct net_device *netdev;
@@ -3393,7 +3389,6 @@ static void add_device(struct slgt_info *info)
 	if (info->line < MAX_DEVICES) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 	}
 
 	slgt_device_count++;
diff --git a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
index 10241ed..6a388e5 100644
--- a/drivers/char/synclinkmp.c
+++ b/drivers/char/synclinkmp.c
@@ -276,7 +276,6 @@ typedef struct _synclinkmp_info {
 
 	/* SPPP/Cisco HDLC device parts */
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 
 #if SYNCLINK_GENERIC_HDLC
@@ -475,13 +474,11 @@ static int ttymajor=0;
  */
 static int debug_level = 0;
 static int maxframe[MAX_DEVICES] = {0,};
-static int dosyncppp[MAX_DEVICES] = {0,};
 
 module_param(break_on_load, bool, 0);
 module_param(ttymajor, int, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 
 static char *driver_name = "SyncLink MultiPort driver";
 static char *driver_version = "$Revision: 4.38 $";
@@ -3757,7 +3754,6 @@ static void add_device(SLMP_INFO *info)
 	if (info->line < MAX_DEVICES) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 	}
 
 	synclinkmp_device_count++;

-- 
Krzysztof Halasa
