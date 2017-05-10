From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 16/17] tty: serdev-ttyport: return actual baudrate from ttyport_set_baudrate
Date: Wed, 10 May 2017 10:53:27 +0200
Message-ID: <1494406408-31760-17-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of returning the requested baudrate, we better return the
actual one because it isn't always the same.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 drivers/tty/serdev/serdev-ttyport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/tty/serdev/serdev-ttyport.c b/drivers/tty/serdev/serdev-ttyport.c
index 487c88f..2cfdf34 100644
--- a/drivers/tty/serdev/serdev-ttyport.c
+++ b/drivers/tty/serdev/serdev-ttyport.c
@@ -151,7 +151,7 @@ static unsigned int ttyport_set_baudrate(struct serdev_controller *ctrl, unsigne
 
 	/* tty_set_termios() return not checked as it is always 0 */
 	tty_set_termios(tty, &ktermios);
-	return speed;
+	return ktermios.c_ospeed;
 }
 
 static void ttyport_set_flow_control(struct serdev_controller *ctrl, bool enable)
-- 
2.1.4
