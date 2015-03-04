From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 2/5] TTY: bfin_jtag_comm: remove incorrect wait_until_sent operation
Date: Wed,  4 Mar 2015 10:39:04 +0100
Message-ID: <1425461947-15888-3-git-send-email-johan@kernel.org>
References: <1425461947-15888-1-git-send-email-johan@kernel.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>,
	Johan Hovold <johan@kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425461947-15888-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove incorrect and redundant wait_until_sent operation, which waits
for the driver buffer rather than any hardware buffers to drain,
something which is already taken care of by the tty layer (and
chars_in_buffer).

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/tty/bfin_jtag_comm.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/tty/bfin_jtag_comm.c b/drivers/tty/bfin_jtag_comm.c
index d7b198c400c7..ce24182f8514 100644
--- a/drivers/tty/bfin_jtag_comm.c
+++ b/drivers/tty/bfin_jtag_comm.c
@@ -210,18 +210,6 @@ bfin_jc_chars_in_buffer(struct tty_struct *tty)
 	return circ_cnt(&bfin_jc_write_buf);
 }
 
-static void
-bfin_jc_wait_until_sent(struct tty_struct *tty, int timeout)
-{
-	unsigned long expire = jiffies + timeout;
-	while (!circ_empty(&bfin_jc_write_buf)) {
-		if (signal_pending(current))
-			break;
-		if (time_after(jiffies, expire))
-			break;
-	}
-}
-
 static const struct tty_operations bfin_jc_ops = {
 	.open            = bfin_jc_open,
 	.close           = bfin_jc_close,
@@ -230,7 +218,6 @@ static const struct tty_operations bfin_jc_ops = {
 	.flush_chars     = bfin_jc_flush_chars,
 	.write_room      = bfin_jc_write_room,
 	.chars_in_buffer = bfin_jc_chars_in_buffer,
-	.wait_until_sent = bfin_jc_wait_until_sent,
 };
 
 static int __init bfin_jc_init(void)
-- 
2.0.5
