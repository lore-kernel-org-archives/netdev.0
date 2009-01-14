From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 01/02] hso patch to fix a -EIO from opening a hso serial
 device
Date: Wed, 14 Jan 2009 11:38:28 +0000
Message-ID: <20090114113828.7b9f59ca@lxorguk.ukuu.org.uk>
References: <496DCAF7.9080906@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Serial <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496DCAF7.9080906-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2009 12:22:31 +0100
Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org> wrote:

> Hi All,
> This is an important patch the linux-2.6.29-rc1 driver with itworks much
> better than it did.

How about this. 

tty: Fix a kref leak in the HSO driver on re-open

From: Alan Cox <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


---

 drivers/net/usb/hso.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index c4918b8..9df04dd 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1297,6 +1297,7 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 	/* setup */
 	spin_lock_irq(&serial->serial_lock);
 	tty->driver_data = serial;
+	tty_kref_put(serial->tty);
 	serial->tty = tty_kref_get(tty);
 	spin_unlock_irq(&serial->serial_lock);
 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
