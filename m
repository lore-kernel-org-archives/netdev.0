From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] wimax: make functions local
Date: Tue, 5 Oct 2010 14:59:59 +0900
Message-ID: <20101005145959.362fbd85@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wimax@vger.kernel.org, netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47292 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754452Ab0JEGAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 02:00:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make wimax variables and functions local if possible.
Compile tested only.

This also removes a couple of unused EXPORT_SYMBOL.
If this breaks some out of tree code, please fix that
by putting the code in the kernel tree.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/wimax/i2400m/control.c	2010-10-05 14:50:34.301255588 +0900
+++ b/drivers/net/wimax/i2400m/control.c	2010-10-05 14:56:54.548224098 +0900
@@ -98,7 +98,7 @@ MODULE_PARM_DESC(power_save_disabled,
 		 "False by default (so the device is told to do power "
 		 "saving).");
 
-int i2400m_passive_mode;	/* 0 (passive mode disabled) by default */
+static int i2400m_passive_mode;	/* 0 (passive mode disabled) by default */
 module_param_named(passive_mode, i2400m_passive_mode, int, 0644);
 MODULE_PARM_DESC(passive_mode,
 		 "If true, the driver will not do any device setup "
@@ -558,8 +558,9 @@ void i2400m_report_hook(struct i2400m *i
  * processing should be done in the function that calls the
  * command. This is here for some cases where it can't happen...
  */
-void i2400m_msg_ack_hook(struct i2400m *i2400m,
-			 const struct i2400m_l3l4_hdr *l3l4_hdr, size_t size)
+static void i2400m_msg_ack_hook(struct i2400m *i2400m,
+				 const struct i2400m_l3l4_hdr *l3l4_hdr,
+				 size_t size)
 {
 	int result;
 	struct device *dev = i2400m_dev(i2400m);
@@ -1135,7 +1136,7 @@ error_alloc:
  * i2400m_report_state_hook() to parse the answer. This will set the
  * carrier state, as well as the RF Kill switches state.
  */
-int i2400m_cmd_get_state(struct i2400m *i2400m)
+static int i2400m_cmd_get_state(struct i2400m *i2400m)
 {
 	int result;
 	struct device *dev = i2400m_dev(i2400m);
@@ -1177,8 +1178,6 @@ error_msg_to_dev:
 error_alloc:
 	return result;
 }
-EXPORT_SYMBOL_GPL(i2400m_cmd_get_state);
-
 
 /**
  * Set basic configuration settings
@@ -1190,8 +1189,9 @@ EXPORT_SYMBOL_GPL(i2400m_cmd_get_state);
  *     right endianess (LE).
  * @arg_size: number of pointers in the @args array
  */
-int i2400m_set_init_config(struct i2400m *i2400m,
-			   const struct i2400m_tlv_hdr **arg, size_t args)
+static int i2400m_set_init_config(struct i2400m *i2400m,
+				  const struct i2400m_tlv_hdr **arg,
+				  size_t args)
 {
 	int result;
 	struct device *dev = i2400m_dev(i2400m);
@@ -1258,8 +1258,6 @@ none:
 	return result;
 
 }
-EXPORT_SYMBOL_GPL(i2400m_set_init_config);
-
 
 /**
  * i2400m_set_idle_timeout - Set the device's idle mode timeout
--- a/drivers/net/wimax/i2400m/driver.c	2010-10-05 14:50:34.337234888 +0900
+++ b/drivers/net/wimax/i2400m/driver.c	2010-10-05 14:52:13.904224891 +0900
@@ -122,7 +122,7 @@ struct i2400m_work *__i2400m_work_setup(
  * works struct was already queued, but we have just allocated it, so
  * it should not happen.
  */
-int i2400m_schedule_work(struct i2400m *i2400m,
+static int i2400m_schedule_work(struct i2400m *i2400m,
 			 void (*fn)(struct work_struct *), gfp_t gfp_flags,
 			 const void *pl, size_t pl_size)
 {
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h	2010-10-05 14:56:05.341233158 +0900
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h	2010-10-05 14:56:13.976640094 +0900
@@ -140,7 +140,6 @@ void i2400ms_init(struct i2400ms *i2400m
 
 extern int i2400ms_rx_setup(struct i2400ms *);
 extern void i2400ms_rx_release(struct i2400ms *);
-extern ssize_t __i2400ms_rx_get_size(struct i2400ms *);
 
 extern int i2400ms_tx_setup(struct i2400ms *);
 extern void i2400ms_tx_release(struct i2400ms *);
--- a/drivers/net/wimax/i2400m/i2400m.h	2010-10-05 14:51:27.325225246 +0900
+++ b/drivers/net/wimax/i2400m/i2400m.h	2010-10-05 14:54:51.460245130 +0900
@@ -910,28 +910,19 @@ struct i2400m_work {
 	u8 pl[0];
 };
 
-extern int i2400m_schedule_work(struct i2400m *,
-				void (*)(struct work_struct *), gfp_t,
-				const void *, size_t);
-
 extern int i2400m_msg_check_status(const struct i2400m_l3l4_hdr *,
 				   char *, size_t);
 extern int i2400m_msg_size_check(struct i2400m *,
 				 const struct i2400m_l3l4_hdr *, size_t);
 extern struct sk_buff *i2400m_msg_to_dev(struct i2400m *, const void *, size_t);
 extern void i2400m_msg_to_dev_cancel_wait(struct i2400m *, int);
-extern void i2400m_msg_ack_hook(struct i2400m *,
-				const struct i2400m_l3l4_hdr *, size_t);
 extern void i2400m_report_hook(struct i2400m *,
 			       const struct i2400m_l3l4_hdr *, size_t);
 extern void i2400m_report_hook_work(struct work_struct *);
 extern int i2400m_cmd_enter_powersave(struct i2400m *);
-extern int i2400m_cmd_get_state(struct i2400m *);
 extern int i2400m_cmd_exit_idle(struct i2400m *);
 extern struct sk_buff *i2400m_get_device_info(struct i2400m *);
 extern int i2400m_firmware_check(struct i2400m *);
-extern int i2400m_set_init_config(struct i2400m *,
-				  const struct i2400m_tlv_hdr **, size_t);
 extern int i2400m_set_idle_timeout(struct i2400m *, unsigned);
 
 static inline
--- a/drivers/net/wimax/i2400m/rx.c	2010-10-05 14:50:34.477224833 +0900
+++ b/drivers/net/wimax/i2400m/rx.c	2010-10-05 14:55:31.480229373 +0900
@@ -922,7 +922,7 @@ void i2400m_roq_queue_update_ws(struct i
  * rx_roq_refcount becomes zero. This routine gets executed when
  * rx_roq_refcount becomes zero.
  */
-void i2400m_rx_roq_destroy(struct kref *ref)
+static void i2400m_rx_roq_destroy(struct kref *ref)
 {
 	unsigned itr;
 	struct i2400m *i2400m
--- a/drivers/net/wimax/i2400m/sdio-rx.c	2010-10-05 14:50:34.517224750 +0900
+++ b/drivers/net/wimax/i2400m/sdio-rx.c	2010-10-05 14:56:19.348230194 +0900
@@ -87,7 +87,7 @@ static const __le32 i2400m_ACK_BARKER[4]
  *
  * sdio_readl() doesn't work.
  */
-ssize_t __i2400ms_rx_get_size(struct i2400ms *i2400ms)
+static ssize_t __i2400ms_rx_get_size(struct i2400ms *i2400ms)
 {
 	int ret, cnt, val;
 	ssize_t rx_size;
