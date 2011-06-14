From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH] TTY: define TTY_MAX_RECEIVE_ROOM to 65536
Date: Tue, 14 Jun 2011 15:26:25 +0200
Message-ID: <1308057986-11472-1-git-send-email-ffainelli@freebox.fr>
Cc: Florian Fainelli <ffainelli@freebox.fr>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andreas Koensgen <ajk@comnets.uni-bremen.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Mikael Starvik <starvik@axis.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Alan Cox <alan@linux.intel.com>,
	Pavan Savoy <pavan_savoy@ti.com>, Felipe Balbi <balbi@ti.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Jiri Slaby <jslaby@suse.cz>, linux-bluetooth@vger.kernel.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
	linux-cris-kerne
To: linux-kernel@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A lot of TTY drivers are setting their receive_room value to 65536
so let's define a constant for this.

Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
---
 drivers/bluetooth/hci_ldisc.c |    2 +-
 drivers/misc/ti-st/st_core.c  |    2 +-
 drivers/net/can/slcan.c       |    2 +-
 drivers/net/hamradio/6pack.c  |    2 +-
 drivers/net/hamradio/mkiss.c  |    2 +-
 drivers/net/irda/irtty-sir.c  |    2 +-
 drivers/net/ppp_async.c       |    2 +-
 drivers/net/ppp_synctty.c     |    2 +-
 drivers/net/slip.c            |    2 +-
 drivers/net/wan/x25_asy.c     |    2 +-
 drivers/tty/n_gsm.c           |    2 +-
 drivers/tty/n_hdlc.c          |    2 +-
 drivers/tty/n_r3964.c         |    2 +-
 drivers/tty/n_tracerouter.c   |    3 +--
 drivers/tty/n_tracesink.c     |    1 -
 drivers/tty/serial/crisv10.c  |    2 +-
 drivers/tty/tty_buffer.c      |    2 +-
 drivers/tty/tty_io.c          |    2 +-
 include/linux/tty.h           |    2 +-
 19 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 48ad2a7..052e418 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -273,7 +273,7 @@ static int hci_uart_tty_open(struct tty_struct *tty)
 
 	tty->disc_data = hu;
 	hu->tty = tty;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 
 	spin_lock_init(&hu->rx_lock);
 
diff --git a/drivers/misc/ti-st/st_core.c b/drivers/misc/ti-st/st_core.c
index f91f82e..b3bde88 100644
--- a/drivers/misc/ti-st/st_core.c
+++ b/drivers/misc/ti-st/st_core.c
@@ -690,7 +690,7 @@ static int st_tty_open(struct tty_struct *tty)
 
 	/* mem already allocated
 	 */
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 	/* Flush any pending characters in the driver and discipline. */
 	tty_ldisc_flush(tty);
 	tty_driver_flush_buffer(tty);
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 1b49df6..50b4052 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -582,7 +582,7 @@ static int slcan_open(struct tty_struct *tty)
 
 	/* Done.  We have linked the TTY line to a channel. */
 	rtnl_unlock();
-	tty->receive_room = 65536;	/* We don't flow control */
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;	/* We don't flow control */
 
 	/* TTY layer expects 0 on success */
 	return 0;
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 3e5d0b6..e3b735d 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -660,7 +660,7 @@ static int sixpack_open(struct tty_struct *tty)
 
 	/* Done.  We have linked the TTY line to a channel. */
 	tty->disc_data = sp;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 
 	/* Now we're ready to register. */
 	if (register_netdev(dev))
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 4c62839..8cb597d 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -751,7 +751,7 @@ static int mkiss_open(struct tty_struct *tty)
 
 	ax->tty = tty;
 	tty->disc_data = ax;
-	tty->receive_room = 65535;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 
 	tty_driver_flush_buffer(tty);
 
diff --git a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
index 3352b24..306cf56 100644
--- a/drivers/net/irda/irtty-sir.c
+++ b/drivers/net/irda/irtty-sir.c
@@ -471,7 +471,7 @@ static int irtty_open(struct tty_struct *tty)
 
 	dev->priv = priv;
 	tty->disc_data = priv;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 
 	mutex_unlock(&irtty_mutex);
 
diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index a1b82c9..a75d11a 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -197,7 +197,7 @@ ppp_asynctty_open(struct tty_struct *tty)
 		goto out_free;
 
 	tty->disc_data = ap;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 	return 0;
 
  out_free:
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index 2573f52..d4ae9ce 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -244,7 +244,7 @@ ppp_sync_open(struct tty_struct *tty)
 		goto out_free;
 
 	tty->disc_data = ap;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 	return 0;
 
  out_free:
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 8ec1a9a..f448d1f 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -852,7 +852,7 @@ static int slip_open(struct tty_struct *tty)
 
 	/* Done.  We have linked the TTY line to a channel. */
 	rtnl_unlock();
-	tty->receive_room = 65536;	/* We don't flow control */
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;	/* We don't flow control */
 
 	/* TTY layer expects 0 on success */
 	return 0;
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 24297b2..920b79d 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -565,7 +565,7 @@ static int x25_asy_open_tty(struct tty_struct *tty)
 
 	sl->tty = tty;
 	tty->disc_data = sl;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 	tty_driver_flush_buffer(tty);
 	tty_ldisc_flush(tty);
 
diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
index 09e8c7d..74d8d29 100644
--- a/drivers/tty/n_gsm.c
+++ b/drivers/tty/n_gsm.c
@@ -2236,7 +2236,7 @@ static int gsmld_open(struct tty_struct *tty)
 		return -ENOMEM;
 
 	tty->disc_data = gsm;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 
 	/* Attach the initial passive connection */
 	gsm->encoding = 1;
diff --git a/drivers/tty/n_hdlc.c b/drivers/tty/n_hdlc.c
index cea5603..217186f 100644
--- a/drivers/tty/n_hdlc.c
+++ b/drivers/tty/n_hdlc.c
@@ -358,7 +358,7 @@ static int n_hdlc_tty_open (struct tty_struct *tty)
 		
 	tty->disc_data = n_hdlc;
 	n_hdlc->tty    = tty;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 	
 #if defined(TTY_NO_WRITE_SPLIT)
 	/* change tty_io write() to not split large writes into 8K chunks */
diff --git a/drivers/tty/n_r3964.c b/drivers/tty/n_r3964.c
index 5c6c314..5d4797a 100644
--- a/drivers/tty/n_r3964.c
+++ b/drivers/tty/n_r3964.c
@@ -993,7 +993,7 @@ static int r3964_open(struct tty_struct *tty)
 	pInfo->nRetry = 0;
 
 	tty->disc_data = pInfo;
-	tty->receive_room = 65536;
+	tty->receive_room = TTY_MAX_RECEIVE_ROOM;
 
 	setup_timer(&pInfo->tmr, on_timeout, (unsigned long)pInfo);
 
diff --git a/drivers/tty/n_tracerouter.c b/drivers/tty/n_tracerouter.c
index 1f063d3..25934df 100644
--- a/drivers/tty/n_tracerouter.c
+++ b/drivers/tty/n_tracerouter.c
@@ -42,7 +42,6 @@
  * 'I can always accept 64k' and flow control is off.
  * This number is deemed appropriate for this driver.
  */
-#define RECEIVE_ROOM	65536
 #define DRIVERNAME	"n_tracerouter"
 
 /*
@@ -81,7 +80,7 @@ static int n_tracerouter_open(struct tty_struct *tty)
 		} else {
 			tr_data->opencalled = 1;
 			tty->disc_data      = tr_data;
-			tty->receive_room   = RECEIVE_ROOM;
+			tty->receive_room   = TTY_MAX_RECEIVE_ROOM;
 			tty_driver_flush_buffer(tty);
 			retval = 0;
 		}
diff --git a/drivers/tty/n_tracesink.c b/drivers/tty/n_tracesink.c
index ddce58b..ff065ba 100644
--- a/drivers/tty/n_tracesink.c
+++ b/drivers/tty/n_tracesink.c
@@ -42,7 +42,6 @@
  * 'I can always accept 64k' and flow control is off.
  * This number is deemed appropriate for this driver.
  */
-#define RECEIVE_ROOM	65536
 #define DRIVERNAME	"n_tracesink"
 
 /*
diff --git a/drivers/tty/serial/crisv10.c b/drivers/tty/serial/crisv10.c
index 225123b..695a4617 100644
--- a/drivers/tty/serial/crisv10.c
+++ b/drivers/tty/serial/crisv10.c
@@ -1787,7 +1787,7 @@ static unsigned int handle_descr_data(struct e100_serial *info,
 {
 	struct etrax_recv_buffer *buffer = phys_to_virt(descr->buf) - sizeof *buffer;
 
-	if (info->recv_cnt + recvl > 65536) {
+	if (info->recv_cnt + recvl > TTY_MAX_RECEIVE_ROOM) {
 		printk(KERN_CRIT
 		       "%s: Too much pending incoming serial data! Dropping %u bytes.\n", __func__, recvl);
 		return 0;
diff --git a/drivers/tty/tty_buffer.c b/drivers/tty/tty_buffer.c
index f1a7918..e166b3a 100644
--- a/drivers/tty/tty_buffer.c
+++ b/drivers/tty/tty_buffer.c
@@ -58,7 +58,7 @@ static struct tty_buffer *tty_buffer_alloc(struct tty_struct *tty, size_t size)
 {
 	struct tty_buffer *p;
 
-	if (tty->buf.memory_used + size > 65536)
+	if (tty->buf.memory_used + size > TTY_MAX_RECEIVE_ROOM)
 		return NULL;
 	p = kmalloc(sizeof(struct tty_buffer) + 2 * size, GFP_ATOMIC);
 	if (p == NULL)
diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
index 6556f74..df5f8f2 100644
--- a/drivers/tty/tty_io.c
+++ b/drivers/tty/tty_io.c
@@ -1016,7 +1016,7 @@ static inline ssize_t do_tty_write(
 	 */
 	chunk = 2048;
 	if (test_bit(TTY_NO_WRITE_SPLIT, &tty->flags))
-		chunk = 65536;
+		chunk = TTY_MAX_RECEIVE_ROOM;
 	if (count < chunk)
 		chunk = count;
 
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 44bc0c5..ba074a0 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -46,7 +46,6 @@
 
 #include <asm/system.h>
 
-
 /*
  * (Note: the *_driver.minor_start values 1, 64, 128, 192 are
  * hardcoded at present.)
@@ -296,6 +295,7 @@ struct tty_struct {
 	struct list_head tty_files;
 
 #define N_TTY_BUF_SIZE 4096
+#define TTY_MAX_RECEIVE_ROOM	(65536)
 
 	/*
 	 * The following is data for the N_TTY line discipline.  For
-- 
1.7.4.1

