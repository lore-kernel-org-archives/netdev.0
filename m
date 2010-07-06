From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 07/11] isdn/gigaset: remove obsolete compile time options
Date: Tue,  6 Jul 2010 02:19:09 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-07.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove compile time options in the Gigaset ISDN driver that aren't
going to be changed anymore, and an obsolete FIXME comment.

Impact: cleanup
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c    |    2 --
 drivers/isdn/gigaset/ev-layer.c  |    6 ------
 drivers/isdn/gigaset/gigaset.h   |    7 -------
 drivers/isdn/gigaset/i4l.c       |    2 --
 drivers/isdn/gigaset/interface.c |    1 -
 5 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 5d4befb..3ca561e 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -791,8 +791,6 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	spin_unlock_irqrestore(&cs->lock, flags);
 	setup_timer(&cs->timer, timer_tick, (unsigned long) cs);
 	cs->timer.expires = jiffies + msecs_to_jiffies(GIG_TICK);
-	/* FIXME: can jiffies increase too much until the timer is added?
-	 * Same problem(?) with mod_timer() in timer_tick(). */
 	add_timer(&cs->timer);
 
 	gig_dbg(DEBUG_INIT, "cs initialized");
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 657757b..a230ba7 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -1809,19 +1809,13 @@ static void process_command_flags(struct cardstate *cs)
 				gig_dbg(DEBUG_EVENT, "Scheduling PC_CIDMODE");
 				cs->commands_pending = 1;
 				return;
-#ifdef GIG_MAYINITONDIAL
 			case M_UNKNOWN:
 				schedule_init(cs, MS_INIT);
 				return;
-#endif
 			}
 			bcs->at_state.pending_commands &= ~PC_CID;
 			cs->curchannel = bcs->channel;
-#ifdef GIG_RETRYCID
 			cs->retry_count = 2;
-#else
-			cs->retry_count = 1;
-#endif
 			schedule_sequence(cs, &cs->at_state, SEQ_CID);
 			return;
 		}
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index ba9547b..a69512f 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -46,13 +46,6 @@
 
 #define RBUFSIZE 8192
 
-/* compile time options */
-#define GIG_MAJOR 0
-
-#define GIG_MAYINITONDIAL
-#define GIG_RETRYCID
-#define GIG_X75
-
 #define GIG_TICK 100		/* in milliseconds */
 
 /* timeout values (unit: 1 sec) */
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index f01c3c2..1d084bb 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -643,9 +643,7 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	iif->maxbufsize = MAX_BUF_SIZE;
 	iif->features = ISDN_FEATURE_L2_TRANS |
 		ISDN_FEATURE_L2_HDLC |
-#ifdef GIG_X75
 		ISDN_FEATURE_L2_X75I |
-#endif
 		ISDN_FEATURE_L3_TRANS |
 		ISDN_FEATURE_P_EURO;
 	iif->hl_hdrlen = HW_HDR_LEN;		/* Area for storing ack */
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index f45d686..bb710d1 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -677,7 +677,6 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 		goto enomem;
 
 	tty->magic =		TTY_DRIVER_MAGIC,
-	tty->major =		GIG_MAJOR,
 	tty->type =		TTY_DRIVER_TYPE_SERIAL,
 	tty->subtype =		SERIAL_TYPE_NORMAL,
 	tty->flags =		TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
-- 
1.6.5.3.298.g39add
