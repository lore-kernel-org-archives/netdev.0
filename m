From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/4] bluetooth: hci_uart: remove unused hci_uart_init_tty
Date: Wed,  5 Apr 2017 13:30:03 -0500
Message-ID: <20170405183005.20570-3-robh@kernel.org>
References: <20170405183005.20570-1-robh@kernel.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170405183005.20570-1-robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There are no users of hci_uart_init_tty, so remove it.

Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/bluetooth/hci_ldisc.c | 19 -------------------
 drivers/bluetooth/hci_uart.h  |  1 -
 2 files changed, 20 deletions(-)

diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 17bcbc13623f..cec4438ede01 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -319,25 +319,6 @@ void hci_uart_set_speeds(struct hci_uart *hu, unsigned int init_speed,
 	hu->oper_speed = oper_speed;
 }
 
-void hci_uart_init_tty(struct hci_uart *hu)
-{
-	struct tty_struct *tty = hu->tty;
-	struct ktermios ktermios;
-
-	/* Bring the UART into a known 8 bits no parity hw fc state */
-	ktermios = tty->termios;
-	ktermios.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP |
-			      INLCR | IGNCR | ICRNL | IXON);
-	ktermios.c_oflag &= ~OPOST;
-	ktermios.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
-	ktermios.c_cflag &= ~(CSIZE | PARENB);
-	ktermios.c_cflag |= CS8;
-	ktermios.c_cflag |= CRTSCTS;
-
-	/* tty_set_termios() return not checked as it is always 0 */
-	tty_set_termios(tty, &ktermios);
-}
-
 void hci_uart_set_baudrate(struct hci_uart *hu, unsigned int speed)
 {
 	struct tty_struct *tty = hu->tty;
diff --git a/drivers/bluetooth/hci_uart.h b/drivers/bluetooth/hci_uart.h
index 1b41c661bbb8..2b05e557fad0 100644
--- a/drivers/bluetooth/hci_uart.h
+++ b/drivers/bluetooth/hci_uart.h
@@ -114,7 +114,6 @@ int hci_uart_register_device(struct hci_uart *hu, const struct hci_uart_proto *p
 
 int hci_uart_tx_wakeup(struct hci_uart *hu);
 int hci_uart_init_ready(struct hci_uart *hu);
-void hci_uart_init_tty(struct hci_uart *hu);
 void hci_uart_set_baudrate(struct hci_uart *hu, unsigned int speed);
 void hci_uart_set_flow_control(struct hci_uart *hu, bool enable);
 void hci_uart_set_speeds(struct hci_uart *hu, unsigned int init_speed,
-- 
2.10.1
