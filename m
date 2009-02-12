From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH] drivers/isdn/hardware/mISDN: fix sparse warnings: make
	symbols static
Date: Thu, 12 Feb 2009 20:28:40 +0100
Message-ID: <20090212192810.7401.70271.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:39386 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbZBLT2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 14:28:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/isdn/hardware/mISDN/hfcpci.c:59:19: warning: symbol 'hfc_tl' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcpci.c:60:9: warning: symbol 'hfc_jiffies' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcsusb.h:201:6: warning: symbol 'conf_str' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcsusb.h:319:12: warning: symbol 'HFC_TE_LAYER1_STATES' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcsusb.h:331:12: warning: symbol 'HFC_NT_LAYER1_STATES' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcsusb.c:38:12: warning: symbol 'hfcsusb_rev' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcsusb.c:978:1: warning: symbol 'fill_isoc_urb' was not declared. Should it be static?
  drivers/isdn/hardware/mISDN/hfcsusb.c:1724:1: warning: symbol 'setup_hfcsusb' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/isdn/hardware/mISDN/hfcpci.c  |    4 ++--
 drivers/isdn/hardware/mISDN/hfcsusb.c |    6 +++---
 drivers/isdn/hardware/mISDN/hfcsusb.h |    6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index f0e14df..2bb85c4 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -56,8 +56,8 @@ static const char *hfcpci_revision = "2.0";
 static int HFC_cnt;
 static uint debug;
 static uint poll, tics;
-struct timer_list hfc_tl;
-u32	hfc_jiffies;
+static struct timer_list hfc_tl;
+static u32 hfc_jiffies;
 
 MODULE_AUTHOR("Karsten Keil");
 MODULE_LICENSE("GPL");
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index ba6925f..9c427fb 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -35,7 +35,7 @@
 #include <linux/mISDNhw.h>
 #include "hfcsusb.h"
 
-const char *hfcsusb_rev = "Revision: 0.3.3 (socket), 2008-11-05";
+static const char *hfcsusb_rev = "Revision: 0.3.3 (socket), 2008-11-05";
 
 static unsigned int debug;
 static int poll = DEFAULT_TRANSP_BURST_SZ;
@@ -974,7 +974,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 	spin_unlock(&hw->lock);
 }
 
-void
+static void
 fill_isoc_urb(struct urb *urb, struct usb_device *dev, unsigned int pipe,
 	      void *buf, int num_packets, int packet_size, int interval,
 	      usb_complete_t complete, void *context)
@@ -1720,7 +1720,7 @@ hfcsusb_stop_endpoint(struct hfcsusb *hw, int channel)
 
 
 /* Hardware Initialization */
-int
+static int
 setup_hfcsusb(struct hfcsusb *hw)
 {
 	int err;
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.h b/drivers/isdn/hardware/mISDN/hfcsusb.h
index 098486b..43efe73 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.h
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.h
@@ -198,7 +198,7 @@ validconf[][19] = {
 };
 
 /* string description of chosen config */
-char *conf_str[] = {
+static char *conf_str[] = {
 	"4 Interrupt IN + 3 Isochron OUT",
 	"3 Interrupt IN + 3 Isochron OUT",
 	"4 Isochron IN + 3 Isochron OUT",
@@ -316,7 +316,7 @@ struct hfcsusb_vdata {
 #define HFC_MAX_TE_LAYER1_STATE 8
 #define HFC_MAX_NT_LAYER1_STATE 4
 
-const char *HFC_TE_LAYER1_STATES[HFC_MAX_TE_LAYER1_STATE + 1] = {
+static const char *HFC_TE_LAYER1_STATES[HFC_MAX_TE_LAYER1_STATE + 1] = {
 	"TE F0 - Reset",
 	"TE F1 - Reset",
 	"TE F2 - Sensing",
@@ -328,7 +328,7 @@ const char *HFC_TE_LAYER1_STATES[HFC_MAX_TE_LAYER1_STATE + 1] = {
 	"TE F8 - Lost framing",
 };
 
-const char *HFC_NT_LAYER1_STATES[HFC_MAX_NT_LAYER1_STATE + 1] = {
+static const char *HFC_NT_LAYER1_STATES[HFC_MAX_NT_LAYER1_STATE + 1] = {
 	"NT G0 - Reset",
 	"NT G1 - Deactive",
 	"NT G2 - Pending activation",

