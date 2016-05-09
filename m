From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 2/7] net: ircomm, cleanup TIOCGSERIAL
Date: Mon,  9 May 2016 09:11:54 +0200
Message-ID: <1462777919-10367-2-git-send-email-jslaby@suse.cz>
References: <1462777919-10367-1-git-send-email-jslaby@suse.cz>
Cc: linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462777919-10367-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In ircomm_tty_get_serial_info, struct serial_struct is memset to 0 and
then some members set to 0 explicitly.

Remove the latter as it is obviously superfluous.

And remove the retinfo check against NULL. copy_to_user will take care
of that.

Part of hub6 cleanup series.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/irda/ircomm/ircomm_tty_ioctl.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index 17c49bf26313..0985588c9dec 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -246,9 +246,6 @@ static int ircomm_tty_get_serial_info(struct ircomm_tty_cb *self,
 {
 	struct serial_struct info;
 
-	if (!retinfo)
-		return -EFAULT;
-
 	memset(&info, 0, sizeof(info));
 	info.line = self->line;
 	info.flags = self->port.flags;
@@ -258,11 +255,6 @@ static int ircomm_tty_get_serial_info(struct ircomm_tty_cb *self,
 
 	/* For compatibility  */
 	info.type = PORT_16550A;
-	info.port = 0;
-	info.irq = 0;
-	info.xmit_fifo_size = 0;
-	info.hub6 = 0;
-	info.custom_divisor = 0;
 
 	if (copy_to_user(retinfo, &info, sizeof(*retinfo)))
 		return -EFAULT;
-- 
2.8.2
