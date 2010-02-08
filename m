From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 26/41] CAPI: Drop remaining NULL checks on tty->driver_data
Date: Mon,  8 Feb 2010 21:12:30 +0100
Message-ID: <8e192d49420287aef66facf77b454a9bc8c799de.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tty_struct's driver_data cannot be NULL, no need to test for it.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   64 ++++++++++++++++++++++-----------------------
 1 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index e164a8f..acc811b 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1097,7 +1097,7 @@ static void capinc_tty_close(struct tty_struct *tty, struct file *filp)
 static int capinc_tty_write(struct tty_struct * tty,
 			    const unsigned char *buf, int count)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 	unsigned long flags;
 
@@ -1105,7 +1105,7 @@ static int capinc_tty_write(struct tty_struct * tty,
 	printk(KERN_DEBUG "capinc_tty_write(count=%d)\n", count);
 #endif
 
-	if (!mp || !mp->nccip) {
+	if (!mp->nccip) {
 #ifdef _DEBUG_TTYFUNCS
 		printk(KERN_DEBUG "capinc_tty_write: mp or mp->ncci NULL\n");
 #endif
@@ -1140,7 +1140,7 @@ static int capinc_tty_write(struct tty_struct * tty,
 
 static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 	unsigned long flags;
 	int ret = 1;
@@ -1149,7 +1149,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	printk(KERN_DEBUG "capinc_put_char(%u)\n", ch);
 #endif
 
-	if (!mp || !mp->nccip) {
+	if (!mp->nccip) {
 #ifdef _DEBUG_TTYFUNCS
 		printk(KERN_DEBUG "capinc_tty_put_char: mp or mp->ncci NULL\n");
 #endif
@@ -1184,7 +1184,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 
 static void capinc_tty_flush_chars(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 	unsigned long flags;
 
@@ -1192,7 +1192,7 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 	printk(KERN_DEBUG "capinc_tty_flush_chars\n");
 #endif
 
-	if (!mp || !mp->nccip) {
+	if (!mp->nccip) {
 #ifdef _DEBUG_TTYFUNCS
 		printk(KERN_DEBUG "capinc_tty_flush_chars: mp or mp->ncci NULL\n");
 #endif
@@ -1213,9 +1213,10 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 
 static int capinc_tty_write_room(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	int room;
-	if (!mp || !mp->nccip) {
+
+	if (!mp->nccip) {
 #ifdef _DEBUG_TTYFUNCS
 		printk(KERN_DEBUG "capinc_tty_write_room: mp or mp->ncci NULL\n");
 #endif
@@ -1231,8 +1232,9 @@ static int capinc_tty_write_room(struct tty_struct *tty)
 
 static int capinc_tty_chars_in_buffer(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
-	if (!mp || !mp->nccip) {
+	struct capiminor *mp = tty->driver_data;
+
+	if (!mp->nccip) {
 #ifdef _DEBUG_TTYFUNCS
 		printk(KERN_DEBUG "capinc_tty_chars_in_buffer: mp or mp->ncci NULL\n");
 #endif
@@ -1266,55 +1268,51 @@ static void capinc_tty_set_termios(struct tty_struct *tty, struct ktermios * old
 #endif
 }
 
-static void capinc_tty_throttle(struct tty_struct * tty)
+static void capinc_tty_throttle(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_throttle\n");
 #endif
-	if (mp)
-		mp->ttyinstop = 1;
+	mp->ttyinstop = 1;
 }
 
-static void capinc_tty_unthrottle(struct tty_struct * tty)
+static void capinc_tty_unthrottle(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	unsigned long flags;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_unthrottle\n");
 #endif
-	if (mp) {
-		spin_lock_irqsave(&workaround_lock, flags);
-		mp->ttyinstop = 0;
-		handle_minor_recv(mp);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-	}
+	spin_lock_irqsave(&workaround_lock, flags);
+	mp->ttyinstop = 0;
+	handle_minor_recv(mp);
+	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
 static void capinc_tty_stop(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_stop\n");
 #endif
-	if (mp) {
-		mp->ttyoutstop = 1;
-	}
+	mp->ttyoutstop = 1;
 }
 
 static void capinc_tty_start(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	unsigned long flags;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_start\n");
 #endif
-	if (mp) {
-		spin_lock_irqsave(&workaround_lock, flags);
-		mp->ttyoutstop = 0;
-		(void)handle_minor_send(mp);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-	}
+	spin_lock_irqsave(&workaround_lock, flags);
+	mp->ttyoutstop = 0;
+	(void)handle_minor_send(mp);
+	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
 static void capinc_tty_hangup(struct tty_struct *tty)
-- 
1.6.0.2
