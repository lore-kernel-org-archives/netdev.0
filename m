From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH] Drivers: isdn: gigaset: checkpatch cleanup
Date: Wed, 31 Dec 2014 18:34:58 +0100
Message-ID: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
Cc: <tilman@imap.cc>, <isdn@linux-pingi.de>,
	<gigaset307x-common@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Bas Peters <baspeters93@gmail.com>
To: <hjlipp@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed many checkpatch.pl complaints, ranging from whitespace issues to
reportedly deprecated function and macro usage.

I have not been able to test the code as I do not have access to the
hardware but since no new features were really added I don't think that
should pose a problem.

There are still some checkpatch complaints, particularly concerning
potentially unnecessary 'out of memory' messages. I will provide patches
for these complaints when I figure out the reason behind it and what to
do about it.

NOTE: This is my first patch (ever). I have attempted to follow all
guidelines provided, but I probably will have missed some. If you have
any comments regarding the quality of this patch or suggestions as to
what I could do better in the future, please let me know.

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/gigaset/asyncdata.c   |  9 +++--
 drivers/isdn/gigaset/bas-gigaset.c | 80 ++++++++++++++++++++------------------
 drivers/isdn/gigaset/capi.c        |  5 ++-
 drivers/isdn/gigaset/common.c      |  8 ++--
 drivers/isdn/gigaset/ev-layer.c    | 38 +++++++++++-------
 drivers/isdn/gigaset/gigaset.h     |  4 +-
 drivers/isdn/gigaset/i4l.c         | 12 +++---
 drivers/isdn/gigaset/interface.c   | 10 ++---
 drivers/isdn/gigaset/isocdata.c    |  3 ++
 drivers/isdn/gigaset/proc.c        | 17 +++++---
 drivers/isdn/gigaset/usb-gigaset.c | 46 +++++++++++++++-------
 11 files changed, 141 insertions(+), 91 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index c90dca5..6120c2b 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -25,9 +25,12 @@
  */
 static inline int muststuff(unsigned char c)
 {
-	if (c < PPP_TRANS) return 1;
-	if (c == PPP_FLAG) return 1;
-	if (c == PPP_ESCAPE) return 1;
+	if (c < PPP_TRANS)
+		return 1;
+	if (c == PPP_FLAG)
+		return 1;
+	if (c == PPP_ESCAPE)
+		return 1;
 	/* other possible candidates: */
 	/* 0x91: XON with parity set */
 	/* 0x93: XOFF with parity set */
diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index aecec6d..c31a416 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -261,11 +261,12 @@ static inline void dump_urb(enum debuglevel level, const char *tag,
 {
 #ifdef CONFIG_GIGASET_DEBUG
 	int i;
+
 	gig_dbg(level, "%s urb(0x%08lx)->{", tag, (unsigned long) urb);
 	if (urb) {
 		gig_dbg(level,
-			"  dev=0x%08lx, pipe=%s:EP%d/DV%d:%s, "
-			"hcpriv=0x%08lx, transfer_flags=0x%x,",
+			"  dev=0x%08lx, pipe=%s:EP%d/DV%d:%s,
+			hcpriv=0x%08lx, transfer_flags=0x%x,",
 			(unsigned long) urb->dev,
 			usb_pipetype_str(urb->pipe),
 			usb_pipeendpoint(urb->pipe), usb_pipedevice(urb->pipe),
@@ -273,27 +274,26 @@ static inline void dump_urb(enum debuglevel level, const char *tag,
 			(unsigned long) urb->hcpriv,
 			urb->transfer_flags);
 		gig_dbg(level,
-			"  transfer_buffer=0x%08lx[%d], actual_length=%d, "
-			"setup_packet=0x%08lx,",
+			"  transfer_buffer=0x%08lx[%d], actual_length=%d,
+			setup_packet=0x%08lx,",
 			(unsigned long) urb->transfer_buffer,
 			urb->transfer_buffer_length, urb->actual_length,
 			(unsigned long) urb->setup_packet);
 		gig_dbg(level,
-			"  start_frame=%d, number_of_packets=%d, interval=%d, "
-			"error_count=%d,",
+			"  start_frame=%d, number_of_packets=%d, interval=%d,
+			error_count=%d,",
 			urb->start_frame, urb->number_of_packets, urb->interval,
 			urb->error_count);
 		gig_dbg(level,
-			"  context=0x%08lx, complete=0x%08lx, "
-			"iso_frame_desc[]={",
+			"  context=0x%08lx, complete=0x%08lx,
+			iso_frame_desc[]={",
 			(unsigned long) urb->context,
 			(unsigned long) urb->complete);
 		for (i = 0; i < urb->number_of_packets; i++) {
 			struct usb_iso_packet_descriptor *pifd
 				= &urb->iso_frame_desc[i];
 			gig_dbg(level,
-				"    {offset=%u, length=%u, actual_length=%u, "
-				"status=%u}",
+				"    {offset=%u, length=%u, actual_length=%u, status=%u}",
 				pifd->offset, pifd->length, pifd->actual_length,
 				pifd->status);
 		}
@@ -566,8 +566,8 @@ static int atread_submit(struct cardstate *cs, int timeout)
 
 	if (basstate & BS_SUSPEND) {
 		dev_notice(cs->dev,
-			   "HD_READ_ATMESSAGE not submitted, "
-			   "suspend in progress\n");
+			   "HD_READ_ATMESSAGE not submitted,\
+			   suspend in progress\n");
 		update_basstate(ucs, 0, BS_ATRDPEND);
 		/* treat like disconnect */
 		return -ENODEV;
@@ -1331,8 +1331,8 @@ static void read_iso_tasklet(unsigned long data)
 
 		if (unlikely(!(ubc->running))) {
 			gig_dbg(DEBUG_ISO,
-				"%s: channel not running, "
-				"dropped URB with status: %s",
+				"%s: channel not running,
+				dropped URB with status: %s",
 				__func__, get_usb_statmsg(status));
 			return;
 		}
@@ -1602,8 +1602,8 @@ static int req_submit(struct bc_state *bcs, int req, int val, int timeout)
 	if (ucs->pending) {
 		spin_unlock_irqrestore(&ucs->lock, flags);
 		dev_err(bcs->cs->dev,
-			"submission of request 0x%02x failed: "
-			"request 0x%02x still pending\n",
+			"submission of request 0x%02x failed:\
+			request 0x%02x still pending\n",
 			req, ucs->pending);
 		return -EBUSY;
 	}
@@ -1797,23 +1797,23 @@ static void write_command_callback(struct urb *urb)
 	default:				/* any failure */
 		if (++ucs->retry_cmd_out > BAS_RETRY) {
 			dev_warn(cs->dev,
-				 "command write: %s, "
-				 "giving up after %d retries\n",
+				 "command write: %s,\
+				 giving up after %d retries\n",
 				 get_usb_statmsg(status),
 				 ucs->retry_cmd_out);
 			break;
 		}
 		if (ucs->basstate & BS_SUSPEND) {
 			dev_warn(cs->dev,
-				 "command write: %s, "
-				 "won't retry - suspend requested\n",
+				 "command write: %s,\
+				 won't retry - suspend requested\n",
 				 get_usb_statmsg(status));
 			break;
 		}
 		if (cs->cmdbuf == NULL) {
 			dev_warn(cs->dev,
-				 "command write: %s, "
-				 "cannot retry - cmdbuf gone\n",
+				 "command write: %s,\
+				 cannot retry - cmdbuf gone\n",
 				 get_usb_statmsg(status));
 			break;
 		}
@@ -2200,7 +2200,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 {
 	struct bas_cardstate *ucs;
 
-	cs->hw.bas = ucs = kmalloc(sizeof *ucs, GFP_KERNEL);
+	cs->hw.bas = ucs = kmalloc(sizeof(*ucs), GFP_KERNEL);
 	if (!ucs) {
 		pr_err("out of memory\n");
 		return -ENOMEM;
@@ -2300,8 +2300,8 @@ static int gigaset_probe(struct usb_interface *interface,
 			__func__, hostif->desc.bAlternateSetting);
 		if (usb_set_interface(udev, hostif->desc.bInterfaceNumber, 3)
 		    < 0) {
-			dev_warn(&udev->dev, "usb_set_interface failed, "
-				 "device %d interface %d altsetting %d\n",
+			dev_warn(&udev->dev, "usb_set_interface failed,\
+					device %d interface %d altsetting %d\n",
 				 udev->devnum, hostif->desc.bInterfaceNumber,
 				 hostif->desc.bAlternateSetting);
 			return -ENODEV;
@@ -2312,13 +2312,13 @@ static int gigaset_probe(struct usb_interface *interface,
 	/* Reject application specific interfaces
 	 */
 	if (hostif->desc.bInterfaceClass != 255) {
-		dev_warn(&udev->dev, "%s: bInterfaceClass == %d\n",
+		dev_warn(&udev->dev, "%s: bInterfaceClass == %d\n",\
 			 __func__, hostif->desc.bInterfaceClass);
 		return -ENODEV;
 	}
 
 	dev_info(&udev->dev,
-		 "%s: Device matched (Vendor: 0x%x, Product: 0x%x)\n",
+		 "%s: Device matched (Vendor: 0x%x, Product: 0x%x)\n",\
 		 __func__, le16_to_cpu(udev->descriptor.idVendor),
 		 le16_to_cpu(udev->descriptor.idProduct));
 
@@ -2340,22 +2340,28 @@ static int gigaset_probe(struct usb_interface *interface,
 	 * - three for the different uses of the default control pipe
 	 * - three for each isochronous pipe
 	 */
-	if (!(ucs->urb_int_in = usb_alloc_urb(0, GFP_KERNEL)) ||
-	    !(ucs->urb_cmd_in = usb_alloc_urb(0, GFP_KERNEL)) ||
-	    !(ucs->urb_cmd_out = usb_alloc_urb(0, GFP_KERNEL)) ||
-	    !(ucs->urb_ctrl = usb_alloc_urb(0, GFP_KERNEL)))
+	ucs->urb_int_in = usb_alloc_urb(0, GFP_KERNEL);
+	ucs->urb_cmd_in = usb_alloc_urb(0, GFP_KERNEL);
+	ucs->urb_cmd_out = usb_alloc_urb(0, GFP_KERNEL);
+	ucs->urb_ctrl = usb_alloc_urb(0, GFP_KERNEL);
+
+	if (!ucs->urb_int_in || !ucs->urb_cmd_in
+			|| !ucs->urb_cmd_out || !ucs->urb_ctrl)
 		goto allocerr;
 
 	for (j = 0; j < BAS_CHANNELS; ++j) {
 		ubc = cs->bcs[j].hw.bas;
-		for (i = 0; i < BAS_OUTURBS; ++i)
-			if (!(ubc->isoouturbs[i].urb =
-			      usb_alloc_urb(BAS_NUMFRAMES, GFP_KERNEL)))
+		for (i = 0; i < BAS_OUTURBS; ++i) {
+			ubc->isoouturbs[i].urb = usb_alloc_urb(BAS_NUMFRAMES, GFP_KERNEL);
+			if (!ubc->isoouturbs[i].urb)
 				goto allocerr;
-		for (i = 0; i < BAS_INURBS; ++i)
-			if (!(ubc->isoinurbs[i] =
-			      usb_alloc_urb(BAS_NUMFRAMES, GFP_KERNEL)))
+		}
+
+		for (i = 0; i < BAS_INURBS; ++i) {
+			ubc->isoinurbs[i] = usb_alloc_urb(BAS_NUMFRAMES, GFP_KERNEL);
+			if (!ubc->isoinurbs[i])
 				goto allocerr;
+		}
 	}
 
 	ucs->rcvbuf = NULL;
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index ccec777..2503d02 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -164,6 +164,7 @@ static inline void ignore_cstruct_param(struct cardstate *cs, _cstruct param,
 static int encode_ie(char *in, u8 *out, int maxlen)
 {
 	int l = 0;
+
 	while (*in) {
 		if (!isxdigit(in[0]) || !isxdigit(in[1]) || l >= maxlen)
 			return -1;
@@ -181,6 +182,7 @@ static int encode_ie(char *in, u8 *out, int maxlen)
 static void decode_ie(u8 *in, char *out)
 {
 	int i = *in;
+
 	while (i-- > 0) {
 		/* ToDo: conversion to upper case necessary? */
 		*out++ = toupper(hex_asc_hi(*++in));
@@ -983,6 +985,7 @@ void gigaset_isdn_start(struct cardstate *cs)
 void gigaset_isdn_stop(struct cardstate *cs)
 {
 	struct gigaset_capi_ctr *iif = cs->iif;
+
 	capi_ctr_down(&iif->ctr);
 }
 
@@ -1370,7 +1373,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	cmsg->adr.adrPLCI |= (bcs->channel + 1) << 8;
 
 	/* build command table */
-	commands = kzalloc(AT_NUM * (sizeof *commands), GFP_KERNEL);
+	commands = kzalloc(AT_NUM * (sizeof(*commands)), GFP_KERNEL);
 	if (!commands)
 		goto oom;
 
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 7c78144..f6ee247 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 {
 	unsigned char outbuf[80];
 	unsigned char c;
-	size_t space = sizeof outbuf - 1;
+	size_t space = sizeof(outbuf - 1);
 	unsigned char *out = outbuf;
 	size_t numin = len;
 
@@ -434,6 +434,7 @@ static void make_valid(struct cardstate *cs, unsigned mask)
 {
 	unsigned long flags;
 	struct gigaset_driver *drv = cs->driver;
+
 	spin_lock_irqsave(&drv->lock, flags);
 	cs->flags |= mask;
 	spin_unlock_irqrestore(&drv->lock, flags);
@@ -443,6 +444,7 @@ static void make_invalid(struct cardstate *cs, unsigned mask)
 {
 	unsigned long flags;
 	struct gigaset_driver *drv = cs->driver;
+
 	spin_lock_irqsave(&drv->lock, flags);
 	cs->flags &= ~mask;
 	spin_unlock_irqrestore(&drv->lock, flags);
@@ -1077,7 +1079,7 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
 	unsigned long flags;
 	unsigned i;
 
-	drv = kmalloc(sizeof *drv, GFP_KERNEL);
+	drv = kmalloc(sizeof(*drv), GFP_KERNEL);
 	if (!drv)
 		return NULL;
 
@@ -1090,7 +1092,7 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
 	drv->owner = owner;
 	INIT_LIST_HEAD(&drv->list);
 
-	drv->cs = kmalloc(minors * sizeof *drv->cs, GFP_KERNEL);
+	drv->cs = kmalloc(minors * sizeof(*drv->cs), GFP_KERNEL);
 	if (!drv->cs)
 		goto error;
 
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index c8ced12..84b1700 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -147,8 +147,7 @@
 
 /* 100: init, 200: dle0, 250:dle1, 300: get cid (dial), 350: "hup" (no cid),
  * 400: hup, 500: reset, 600: dial, 700: ring */
-struct reply_t gigaset_tab_nocid[] =
-{
+struct reply_t gigaset_tab_nocid[] = {
 /* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout,
  * action, command */
 
@@ -256,8 +255,7 @@ struct reply_t gigaset_tab_nocid[] =
 
 /* 600: start dialing, 650: dial in progress, 800: connection is up, 700: ring,
  * 400: hup, 750: accepted icall */
-struct reply_t gigaset_tab_cid[] =
-{
+struct reply_t gigaset_tab_cid[] = {
 /* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout,
  * action, command */
 
@@ -355,8 +353,7 @@ static const struct resp_type_t {
 	int	resp_code;
 	int	type;
 }
-resp_type[] =
-{
+resp_type[] = {
 	{"OK",		RSP_OK,		RT_NOTHING},
 	{"ERROR",	RSP_ERROR,	RT_NOTHING},
 	{"ZSAU",	RSP_ZSAU,	RT_ZSAU},
@@ -378,8 +375,7 @@ static const struct zsau_resp_t {
 	char	*str;
 	int	code;
 }
-zsau_resp[] =
-{
+zsau_resp[] = {
 	{"OUTGOING_CALL_PROCEEDING",	ZSAU_PROCEEDING},
 	{"CALL_DELIVERED",		ZSAU_CALL_DELIVERED},
 	{"ACTIVE",			ZSAU_ACTIVE},
@@ -1083,7 +1079,7 @@ static void do_action(int action, struct cardstate *cs,
 
 	int channel;
 
-	unsigned char *s, *e;
+	unsigned char *s;
 	int i;
 	unsigned long val;
 
@@ -1355,8 +1351,20 @@ static void do_action(int action, struct cardstate *cs,
 		}
 
 		for (i = 0; i < 4; ++i) {
-			val = simple_strtoul(s, (char **) &e, 10);
-			if (val > INT_MAX || e == s)
+			unsigned long *e;
+
+			val = kstrtoul(s, 10, e);
+			if (val == -EINVAL) {
+				dev_err(cs->dev, "Parsing error on converting string to\
+						 unsigned long\n");
+				break;
+			}
+			if (val == -ERANGE) {
+				dev_err(cs->dev, "Overflow error converting string to\
+						 unsigned long\n");
+				break;
+			}
+			if (val > INT_MAX || *e == s)
 				break;
 			if (i == 3) {
 				if (*e)
@@ -1364,7 +1372,7 @@ static void do_action(int action, struct cardstate *cs,
 			} else if (*e != '.')
 				break;
 			else
-				s = e + 1;
+				s = *e + 1;
 			cs->fwver[i] = val;
 		}
 		if (i != 4) {
@@ -1447,7 +1455,7 @@ static void do_action(int action, struct cardstate *cs,
 		else if (cs->gotfwver != 1) {
 			cs->cmd_result = -ENOENT;
 		} else {
-			memcpy(ev->arg, cs->fwver, sizeof cs->fwver);
+			memcpy(ev->arg, cs->fwver, sizeof(cs->fwver));
 			cs->cmd_result = 0;
 		}
 		cs->waiting = 0;
@@ -1576,8 +1584,8 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 		rcode = rep->resp_code;
 		if (rcode == RSP_LAST) {
 			/* found nothing...*/
-			dev_warn(cs->dev, "%s: rcode=RSP_LAST: "
-				 "resp_code %d in ConState %d!\n",
+			dev_warn(cs->dev, "%s: rcode=RSP_LAST:\
+					 resp_code %d in ConState %d!\n",
 				 __func__, ev->type, at_state->ConState);
 			return;
 		}
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index eb63a0f..e5c6c98 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -94,8 +94,7 @@ enum debuglevel {
 #define gig_dbg(level, format, arg...)					\
 	do {								\
 		if (unlikely(((enum debuglevel)gigaset_debuglevel) & (level))) \
-			printk(KERN_DEBUG KBUILD_MODNAME ": " format "\n", \
-			       ## arg);					\
+			dev_dbg(cs->dev, KBUILD_MODNAME ": " format "\n")\
 	} while (0)
 #define DEBUG_DEFAULT (DEBUG_TRANSCMD | DEBUG_CMD | DEBUG_USBREQ)
 
@@ -769,6 +768,7 @@ int gigaset_enterconfigmode(struct cardstate *cs);
 static inline void gigaset_schedule_event(struct cardstate *cs)
 {
 	unsigned long flags;
+
 	spin_lock_irqsave(&cs->lock, flags);
 	if (cs->running)
 		tasklet_schedule(&cs->event_tasklet);
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 2d75329..57b7827 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -243,7 +243,7 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		dev_kfree_skb(bcs->rx_skb);
 		gigaset_new_rx_skb(bcs);
 
-		commands = kzalloc(AT_NUM * (sizeof *commands), GFP_ATOMIC);
+		commands = kzalloc(AT_NUM * (sizeof(*commands)), GFP_ATOMIC);
 		if (!commands) {
 			gigaset_free_channel(bcs);
 			dev_err(cs->dev, "ISDN_CMD_DIAL: out of memory\n");
@@ -487,12 +487,12 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 	}
 	if (at_state->str_var[STR_NMBR]) {
 		strlcpy(response.parm.setup.phone, at_state->str_var[STR_NMBR],
-			sizeof response.parm.setup.phone);
+			sizeof(response.parm.setup.phone));
 	} else
 		response.parm.setup.phone[0] = 0;
 	if (at_state->str_var[STR_ZCPN]) {
 		strlcpy(response.parm.setup.eazmsn, at_state->str_var[STR_ZCPN],
-			sizeof response.parm.setup.eazmsn);
+			sizeof(response.parm.setup.eazmsn));
 	} else
 		response.parm.setup.eazmsn[0] = 0;
 
@@ -624,14 +624,14 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
 	isdn_if *iif;
 
-	iif = kmalloc(sizeof *iif, GFP_KERNEL);
+	iif = kmalloc(sizeof(*iif, GFP_KERNEL));
 	if (!iif) {
 		pr_err("out of memory\n");
 		return -ENOMEM;
 	}
 
-	if (snprintf(iif->id, sizeof iif->id, "%s_%u", isdnid, cs->minor_index)
-	    >= sizeof iif->id) {
+	if (snprintf(iif->id, sizeof(iif->id, "%s_%u", isdnid, cs->minor_index))
+	    >= sizeof(iif->id)) {
 		pr_err("ID too long: %s\n", isdnid);
 		kfree(iif);
 		return -EINVAL;
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 600c79b..6da5d1c 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -67,10 +67,10 @@ static int if_version(struct cardstate *cs, unsigned arg[4])
 
 	switch (cmd) {
 	case GIGVER_DRIVER:
-		memcpy(arg, version, sizeof version);
+		memcpy(arg, version, sizeof(version));
 		return 0;
 	case GIGVER_COMPAT:
-		memcpy(arg, compat, sizeof compat);
+		memcpy(arg, compat, sizeof(compat));
 		return 0;
 	case GIGVER_FWBASE:
 		cs->waiting = 1;
@@ -212,13 +212,13 @@ static int if_ioctl(struct tty_struct *tty,
 			break;
 		case GIGASET_VERSION:
 			retval = copy_from_user(version,
-						(unsigned __user *) arg, sizeof version)
+						(unsigned __user *) arg, sizeof(version))
 				? -EFAULT : 0;
 			if (retval >= 0)
 				retval = if_version(cs, version);
 			if (retval >= 0)
 				retval = copy_to_user((unsigned __user *) arg,
-						      version, sizeof version)
+						      version, sizeof(version))
 					? -EFAULT : 0;
 			break;
 		default:
@@ -510,7 +510,7 @@ void gigaset_if_init(struct cardstate *cs)
 	if (!IS_ERR(cs->tty_dev))
 		dev_set_drvdata(cs->tty_dev, cs);
 	else {
-		pr_warning("could not register device to the tty subsystem\n");
+		pr_warn("could not register device to the tty subsystem\n");
 		cs->tty_dev = NULL;
 	}
 	mutex_unlock(&cs->mutex);
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index bc29f1d..32ed9c5 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -79,6 +79,7 @@ static inline int isowbuf_startwrite(struct isowbuf_t *iwb)
 static inline int isowbuf_donewrite(struct isowbuf_t *iwb)
 {
 	int write = iwb->write;
+
 	atomic_inc(&iwb->writesem);
 	return write;
 }
@@ -93,6 +94,7 @@ static inline int isowbuf_donewrite(struct isowbuf_t *iwb)
 static inline void isowbuf_putbits(struct isowbuf_t *iwb, u32 data, int nbits)
 {
 	int write = iwb->write;
+
 	data <<= iwb->wbits;
 	data |= iwb->data[write];
 	nbits += iwb->wbits;
@@ -770,6 +772,7 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 					/* stuff bit at position lead1,
 					 * no interior stuffing */
 					unsigned char mask = (1 << lead1) - 1;
+
 					c = (c & mask) | ((c & ~mask) >> 1);
 					inbyte |= c << inbits;
 					inbits += 7;
diff --git a/drivers/isdn/gigaset/proc.c b/drivers/isdn/gigaset/proc.c
index e3f9d0f..10368a7 100644
--- a/drivers/isdn/gigaset/proc.c
+++ b/drivers/isdn/gigaset/proc.c
@@ -27,13 +27,18 @@ static ssize_t set_cidmode(struct device *dev, struct device_attribute *attr,
 			   const char *buf, size_t count)
 {
 	struct cardstate *cs = dev_get_drvdata(dev);
-	long int value;
-	char *end;
+	long int *value;
+	int result;
 
-	value = simple_strtol(buf, &end, 0);
-	while (*end)
-		if (!isspace(*end++))
-			return -EINVAL;
+	result = kstrtol(buf, 0, &value);
+	if (result == -ERANGE)
+		/* Overflow error */
+		dev_err(cs->dev, "Overflow error on conversion from string to\
+				 long\n");
+	if (result == -EINVAL)
+		/* Parsing error  */
+		dev_err(cs->dev, "Parsing error on conversion from string to\
+				 long\n");
 	if (value < 0 || value > 1)
 		return -EINVAL;
 
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index a8e652d..5f56511 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -216,20 +216,40 @@ static int gigaset_baud_rate(struct cardstate *cs, unsigned cflag)
 	cflag &= CBAUD;
 
 	switch (cflag) {
-	case    B300: rate =     300; break;
-	case    B600: rate =     600; break;
-	case   B1200: rate =    1200; break;
-	case   B2400: rate =    2400; break;
-	case   B4800: rate =    4800; break;
-	case   B9600: rate =    9600; break;
-	case  B19200: rate =   19200; break;
-	case  B38400: rate =   38400; break;
-	case  B57600: rate =   57600; break;
-	case B115200: rate =  115200; break;
+	case    B300:
+		rate =     300;
+		break;
+	case    B600:
+		rate =     600;
+		break;
+	case   B1200:
+		rate =    1200;
+		break;
+	case   B2400:
+		rate =    2400;
+		break;
+	case   B4800:
+		rate =    4800;
+		break;
+	case   B9600:
+		rate =    9600;
+		break;
+	case  B19200:
+		rate =   19200;
+		break;
+	case  B38400:
+		rate =   38400;
+		break;
+	case  B57600:
+		rate =   57600;
+		break;
+	case B115200:
+		rate =  115200;
+		break;
 	default:
 		rate =  9600;
-		dev_err(cs->dev, "unsupported baudrate request 0x%x,"
-			" using default of B9600\n", cflag);
+		dev_err(cs->dev, "unsupported baudrate request 0x%x,\
+				 using default of B9600\n", cflag);
 	}
 
 	val = 0x383fff / rate + 1;
@@ -619,7 +639,7 @@ static int write_modem(struct cardstate *cs)
 	}
 
 	/* Copy data to bulk out buffer and transmit data */
-	count = min(bcs->tx_skb->len, (unsigned) ucs->bulk_out_size);
+	count = min_t(unsigned, bcs->tx_skb->len, ucs->bulk_out_size);
 	skb_copy_from_linear_data(bcs->tx_skb, ucs->bulk_out_buffer, count);
 	skb_pull(bcs->tx_skb, count);
 	ucs->busy = 1;
-- 
1.8.4.5
