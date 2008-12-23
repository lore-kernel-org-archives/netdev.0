From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/2] gigaset: ifdef cleanup
Date: Tue, 23 Dec 2008 10:27:24 +0100
Message-ID: <200812230927.mBN9ROEn028596@mail.pxnet.com>
References: <20081223-patch-00.tilman@imap.cc>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:41259 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbYLWJhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 04:37:09 -0500
In-Reply-To: <20081223-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary #ifdef-s and #if-0-ed code sections.

Impact: source code cleanup, no functional change

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/asyncdata.c |   18 +++------------
 drivers/isdn/gigaset/ev-layer.c  |   42 +------------------------------------
 drivers/isdn/gigaset/interface.c |   26 -----------------------
 drivers/isdn/gigaset/isocdata.c  |    2 -
 4 files changed, 6 insertions(+), 82 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index c2bd97d..2a4ce96 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -17,8 +17,6 @@
 #include <linux/crc-ccitt.h>
 #include <linux/bitrev.h>
 
-//#define GIG_M10x_STUFF_VOICE_DATA
-
 /* check if byte must be stuffed/escaped
  * I'm not sure which data should be encoded.
  * Therefore I will go the hard way and decode every value
@@ -147,19 +145,17 @@ static inline int hdlc_loop(unsigned char c, unsigned char *src, int numbytes,
 			}
 byte_stuff:
 			c ^= PPP_TRANS;
-#ifdef CONFIG_GIGASET_DEBUG
 			if (unlikely(!muststuff(c)))
 				gig_dbg(DEBUG_HDLC, "byte stuffed: 0x%02x", c);
-#endif
 		} else if (unlikely(c == PPP_FLAG)) {
 			if (unlikely(inputstate & INS_skip_frame)) {
-				if (!(inputstate & INS_have_data)) { /* 7E 7E */
 #ifdef CONFIG_GIGASET_DEBUG
+				if (!(inputstate & INS_have_data)) { /* 7E 7E */
 					++bcs->emptycount;
-#endif
 				} else
 					gig_dbg(DEBUG_HDLC,
 					    "7e----------------------------");
+#endif
 
 				/* end of frame */
 				error = 1;
@@ -226,11 +222,9 @@ byte_stuff:
 			}
 
 			break;
-#ifdef CONFIG_GIGASET_DEBUG
 		} else if (unlikely(muststuff(c))) {
 			/* Should not happen. Possible after ZDLE=1<CR><LF>. */
 			gig_dbg(DEBUG_HDLC, "not byte stuffed: 0x%02x", c);
-#endif
 		}
 
 		/* add character */
@@ -394,20 +388,16 @@ void gigaset_m10x_input(struct inbuf_t *inbuf)
 					inbuf->inputstate &= ~INS_DLE_char;
 					switch (c) {
 					case 'X': /*begin of command*/
-#ifdef CONFIG_GIGASET_DEBUG
 						if (inbuf->inputstate & INS_command)
-							dev_err(cs->dev,
+							dev_warn(cs->dev,
 					"received <DLE> 'X' in command mode\n");
-#endif
 						inbuf->inputstate |=
 							INS_command | INS_DLE_command;
 						break;
 					case '.': /*end of command*/
-#ifdef CONFIG_GIGASET_DEBUG
 						if (!(inbuf->inputstate & INS_command))
-							dev_err(cs->dev,
+							dev_warn(cs->dev,
 					"received <DLE> '.' in hdlc mode\n");
-#endif
 						inbuf->inputstate &= cs->dle ?
 							~(INS_DLE_command|INS_command)
 							: ~INS_DLE_command;
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 5cbf64d..e582a48 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -203,15 +203,6 @@ struct reply_t gigaset_tab_nocid_m10x[]= /* with dle mode */
 	{EV_TIMEOUT,  120,121, -1,                  0, 0, {ACT_FAILVER, ACT_INIT}},
 	{RSP_ERROR,   120,121, -1,                  0, 0, {ACT_FAILVER, ACT_INIT}},
 	{RSP_OK,      121,121, -1,                  0, 0, {ACT_GOTVER,  ACT_INIT}},
-#if 0
-	{EV_TIMEOUT,  120,121, -1,                130, 5, {ACT_FAILVER},   "^SGCI=1\r"},
-	{RSP_ERROR,   120,121, -1,                130, 5, {ACT_FAILVER},   "^SGCI=1\r"},
-	{RSP_OK,      121,121, -1,                130, 5, {ACT_GOTVER},    "^SGCI=1\r"},
-
-	{RSP_OK,      130,130, -1,                  0, 0, {ACT_INIT}},
-	{RSP_ERROR,   130,130, -1,                  0, 0, {ACT_FAILINIT}},
-	{EV_TIMEOUT,  130,130, -1,                  0, 0, {ACT_FAILINIT}},
-#endif
 
 	/* leave dle mode */
 	{RSP_INIT,      0,  0,SEQ_DLE0,           201, 5, {0},             "^SDLE=0\r"},
@@ -260,10 +251,6 @@ struct reply_t gigaset_tab_nocid_m10x[]= /* with dle mode */
 	{RSP_INIT,      0,  0,SEQ_NOCID,            0, 0, {ACT_ABORTCID}},
 
 	/* reset */
-#if 0
-	{RSP_INIT,      0,  0,SEQ_SHUTDOWN,       503, 5, {0},             "^SGCI=0\r"},
-	{RSP_OK,      503,503, -1,                504, 5, {0},             "Z\r"},
-#endif
 	{RSP_INIT,      0,  0,SEQ_SHUTDOWN,       504, 5, {0},             "Z\r"},
 	{RSP_OK,      504,504, -1,                  0, 0, {ACT_SDOWN}},
 	{RSP_ERROR,   501,599, -1,                  0, 0, {ACT_FAILSDOWN}},
@@ -391,24 +378,6 @@ struct reply_t gigaset_tab_cid_m10x[] = /* for M10x */
 };
 
 
-#if 0
-static struct reply_t tab_nocid[]= /* no dle mode */ //FIXME
-{
-	/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout, action, command */
-
-	{RSP_ANY,      -1, -1, -1,                 -1,-1, ACT_WARN,         NULL},
-	{RSP_LAST,0,0,0,0,0,0}
-};
-
-static struct reply_t tab_cid[] = /* no dle mode */ //FIXME
-{
-	/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout, action, command */
-
-	{RSP_ANY,      -1, -1, -1,                 -1,-1, ACT_WARN,         NULL},
-	{RSP_LAST,0,0,0,0,0,0}
-};
-#endif
-
 static const struct resp_type_t resp_type[] =
 {
 	/*{"",		RSP_EMPTY,	RT_NOTHING},*/
@@ -665,13 +634,8 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 					dev_err(cs->dev, "out of memory\n");
 				++curarg;
 			}
-#ifdef CONFIG_GIGASET_DEBUG
-			if (!event->ptr)
-				gig_dbg(DEBUG_CMD, "string==NULL");
-			else
-				gig_dbg(DEBUG_CMD, "string==%s",
-					(char *) event->ptr);
-#endif
+			gig_dbg(DEBUG_CMD, "string==%s",
+				event->ptr ? (char *) event->ptr : "NULL");
 			break;
 		case RT_ZCAU:
 			event->parameter = -1;
@@ -697,9 +661,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				++curarg;
 			} else
 				event->parameter = -1;
-#ifdef CONFIG_GIGASET_DEBUG
 			gig_dbg(DEBUG_CMD, "parameter==%d", event->parameter);
-#endif
 			break;
 		}
 
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 94fa84b..311e7ca 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -143,9 +143,6 @@ static const struct tty_operations if_ops = {
 	.set_termios =		if_set_termios,
 	.throttle =		if_throttle,
 	.unthrottle =		if_unthrottle,
-#if 0
-	.break_ctl =		serial_break,
-#endif
 	.tiocmget =		if_tiocmget,
 	.tiocmset =		if_tiocmset,
 };
@@ -565,29 +562,6 @@ static void if_set_termios(struct tty_struct *tty, struct ktermios *old)
 
 	cs->ops->set_line_ctrl(cs, cflag);
 
-#if 0
-	//FIXME this hangs M101 [ts 2005-03-09]
-	//FIXME do we need this?
-	/*
-	 * Set flow control: well, I do not really now how to handle DTR/RTS.
-	 * Just do what we have seen with SniffUSB on Win98.
-	 */
-	/* Drop DTR/RTS if no flow control otherwise assert */
-	gig_dbg(DEBUG_IF, "%u: control_state %x",
-		cs->minor_index, control_state);
-	new_state = control_state;
-	if ((iflag & IXOFF) || (iflag & IXON) || (cflag & CRTSCTS))
-		new_state |= TIOCM_DTR | TIOCM_RTS;
-	else
-		new_state &= ~(TIOCM_DTR | TIOCM_RTS);
-	if (new_state != control_state) {
-		gig_dbg(DEBUG_IF, "%u: new_state %x",
-			cs->minor_index, new_state);
-		gigaset_set_modem_ctrl(cs, control_state, new_state);
-		control_state = new_state;
-	}
-#endif
-
 	/* save off the modified port settings */
 	cs->control_state = control_state;
 
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index 4b8b585..b171e75 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -88,11 +88,9 @@ static inline int isowbuf_startwrite(struct isowbuf_t *iwb)
 			__func__);
 		return 0;
 	}
-#ifdef CONFIG_GIGASET_DEBUG
 	gig_dbg(DEBUG_ISO,
 		"%s: acquired iso write semaphore, data[write]=%02x, nbits=%d",
 		__func__, iwb->data[iwb->write], iwb->wbits);
-#endif
 	return 1;
 }
 
-- 
1.6.1.rc2

