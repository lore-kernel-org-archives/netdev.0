From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v4 09/10] tty: serdev-ttyport: return actual baudrate from ttyport_set_baudrate
Date: Mon, 27 Mar 2017 15:37:27 +0200
Message-ID: <1490621848-24828-10-git-send-email-stefan.wahren@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of returning the requested baudrate, we better return the
actual one because it isn't always the same.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/tty/serdev/serdev-ttyport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/tty/serdev/serdev-ttyport.c b/drivers/tty/serdev/serdev-ttyport.c
index d053935..8a30abe 100644
--- a/drivers/tty/serdev/serdev-ttyport.c
+++ b/drivers/tty/serdev/serdev-ttyport.c
@@ -150,7 +150,7 @@ static unsigned int ttyport_set_baudrate(struct serdev_controller *ctrl, unsigne
 
 	/* tty_set_termios() return not checked as it is always 0 */
 	tty_set_termios(tty, &ktermios);
-	return speed;
+	return ktermios.c_ospeed;
 }
 
 static void ttyport_set_flow_control(struct serdev_controller *ctrl, bool enable)
-- 
2.1.4
