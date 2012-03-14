From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] usbnet: use netif_tx_wake_queue instead of netif_start_queue
Date: Wed, 14 Mar 2012 15:00:24 +0100
Message-ID: <1331733624-23266-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If host is going to autosuspend function with two interfaces and
if IP packet has arrived in-between of two usbnet_suspend() callbacks,
i.e usbnet_resume() is called in-between, tx data flow is stopped.
When autosuspend timer expires and device is put to autosuspend
again, tx queue is waked up and data can be sent again.
This behavior might be repeated several times in a row.

Tested on Intel/ARM.

Reviewed-by: Sjur Br=C3=A6ndeland <sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Tested-by: Dmitry Tarnyagin <dmitry.tarnyagin-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 83dcc53..5394b4e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1535,7 +1535,7 @@ int usbnet_resume (struct usb_interface *intf)
=20
 		if (test_bit(EVENT_DEV_OPEN, &dev->flags)) {
 			if (!(dev->txq.qlen >=3D TX_QLEN(dev)))
-				netif_start_queue(dev->net);
+				netif_tx_wake_all_queues(dev->net);
 			tasklet_schedule (&dev->bh);
 		}
 	}
--=20
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
