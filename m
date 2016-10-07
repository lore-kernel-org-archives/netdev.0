From: Matej Kupljen <matej.kupljen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: HSO driver patch again [2/2]
Date: Fri, 7 Oct 2016 16:45:56 +0200
Message-ID: <CAHMF36GL_6RZyhtUikM8EpS5rWp4Q+=P8g8i6huijG5vtnnwAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

second patch:
0002-Stop-also-serial-queue-when-device-is-unplugged.patch
Serial device was not stopped when the device got unplugged so
there are continues error messages that the URB cannot be submitted.

Thanks,
Matej

From: Matej Kupljen <matej.kupljen-ovEwHRmg3fY@public.gmane.org>
Date: Wed, 5 Oct 2016 13:08:31 +0200
Subject: [PATCH] Stop also serial queue when device is unplugged

We need to also stop serial port when the device is unplugged,
the network part is already stopped.

Signed-off-by: Matej Kupljen <matej.kupljen-ovEwHRmg3fY@public.gmane.org>
---
 drivers/net/usb/hso.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 16aef06..efd1fef 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -3157,6 +3157,7 @@ static void hso_free_interface(struct
usb_interface *interface)
  mutex_lock(&serial->parent->mutex);
  serial->parent->usb_gone = 1;
  mutex_unlock(&serial->parent->mutex);
+ hso_stop_serial_device(serial->parent);
  cancel_work_sync(&serial_table[i]->async_put_intf);
  cancel_work_sync(&serial_table[i]->async_get_intf);
  hso_serial_tty_unregister(serial);
-- 
2.7.4
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
