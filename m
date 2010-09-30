From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/9] isdn/gigaset: drop obsolete debug option
Date: Fri,  1 Oct 2010 01:35:01 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-04.tilman@imap.cc>
References: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the debug flag DEBUG_DRIVER and associated code.
It doesn't serve any useful purpose anymore.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c  |   26 --------------------------
 drivers/isdn/gigaset/gigaset.h |    3 +--
 drivers/isdn/gigaset/i4l.c     |    2 --
 3 files changed, 1 insertions(+), 30 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 3ca561e..db621db 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -1026,32 +1026,6 @@ struct cardstate *gigaset_get_cs_by_id(int id)
 	return ret;
 }
 
-void gigaset_debugdrivers(void)
-{
-	unsigned long flags;
-	static struct cardstate *cs;
-	struct gigaset_driver *drv;
-	unsigned i;
-
-	spin_lock_irqsave(&driver_lock, flags);
-	list_for_each_entry(drv, &drivers, list) {
-		gig_dbg(DEBUG_DRIVER, "driver %p", drv);
-		spin_lock(&drv->lock);
-		for (i = 0; i < drv->minors; ++i) {
-			gig_dbg(DEBUG_DRIVER, "  index %u", i);
-			cs = drv->cs + i;
-			gig_dbg(DEBUG_DRIVER, "    cardstate %p", cs);
-			gig_dbg(DEBUG_DRIVER, "    flags 0x%02x", cs->flags);
-			gig_dbg(DEBUG_DRIVER, "    minor_index %u",
-				cs->minor_index);
-			gig_dbg(DEBUG_DRIVER, "    driver %p", cs->driver);
-			gig_dbg(DEBUG_DRIVER, "    i4l id %d", cs->myid);
-		}
-		spin_unlock(&drv->lock);
-	}
-	spin_unlock_irqrestore(&driver_lock, flags);
-}
-
 static struct cardstate *gigaset_get_cs_by_minor(unsigned minor)
 {
 	unsigned long flags;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index a69512f..6dd3607 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -70,7 +70,6 @@ enum debuglevel {
 	DEBUG_STREAM_DUMP = 0x00080, /* application data stream content */
 	DEBUG_LLDATA	  = 0x00100, /* sent/received LL data */
 	DEBUG_EVENT	  = 0x00200, /* event processing */
-	DEBUG_DRIVER	  = 0x00400, /* driver structure */
 	DEBUG_HDLC	  = 0x00800, /* M10x HDLC processing */
 	DEBUG_CHANNEL	  = 0x01000, /* channel allocation/deallocation */
 	DEBUG_TRANSCMD	  = 0x02000, /* AT-COMMANDS+RESPONSES */
@@ -727,7 +726,7 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
 
 /* Deallocate driver structure. */
 void gigaset_freedriver(struct gigaset_driver *drv);
-void gigaset_debugdrivers(void);
+
 struct cardstate *gigaset_get_cs_by_tty(struct tty_struct *tty);
 struct cardstate *gigaset_get_cs_by_id(int id);
 void gigaset_blockdriver(struct gigaset_driver *drv);
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 34bca37..9bec8b9 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -201,8 +201,6 @@ static int command_from_LL(isdn_ctrl *cntrl)
 	int i;
 	size_t l;
 
-	gigaset_debugdrivers();
-
 	gig_dbg(DEBUG_CMD, "driver: %d, command: %d, arg: 0x%lx",
 		cntrl->driver, cntrl->command, cntrl->arg);
 
-- 
1.7.3.15.g442cb
