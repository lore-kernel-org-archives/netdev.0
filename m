From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: ems_usb: fix a leak in ems_usb_start_xmit()
Date: Fri, 06 Dec 2013 23:28:12 +0100
Message-ID: <6e046a57-0383-41ae-bc8c-8eaaa4709a4c@email.android.com>
References: <1386363082-15144-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386363082-15144-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org





Alexey Khoroshilov <khoroshilov@ispras.ru> schrieb:
>There is spare code with obvious misprint in ems_usb_start_xmit():
>usb_free_urb() should be used to deallocate urb instead of
>usb_unanchor_urb().
>
>Found by Linux Driver Verification project (linuxtesting.org).
>
>Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
>---
> drivers/net/can/usb/ems_usb.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/can/usb/ems_usb.c
>b/drivers/net/can/usb/ems_usb.c
>index 5f9a7ad9b964..beae1ec255f4 100644
>--- a/drivers/net/can/usb/ems_usb.c
>+++ b/drivers/net/can/usb/ems_usb.c
>@@ -798,7 +798,7 @@ static netdev_tx_t ems_usb_start_xmit(struct
>sk_buff *skb, struct net_device *ne
> 	 * allowed (MAX_TX_URBS).
> 	 */
> 	if (!context) {
>-		usb_unanchor_urb(urb);
>+		usb_free_urb(urb);
> 		usb_free_coherent(dev->udev, size, buf, urb->transfer_dma);
> 

looks like you are introducing a new use after free problem here ...

> 		netdev_warn(netdev, "couldn't find free context\n");

-- 
Diese Nachricht wurde von meinem Android-Mobiltelefon mit K-9 Mail gesendet.
