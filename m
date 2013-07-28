From: Bernd Krumboeck <krumboeck@universalnet.at>
Subject: Re: [PATCH] can: usb_8dev: fix urb leak on failure path in usb_8dev_start()
Date: Sun, 28 Jul 2013 09:45:28 +0200
Message-ID: <51F4CC18.4090109@universalnet.at>
References: <1374096033-28981-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1374096033-28981-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks!

Added to repository on github: https://github.com/krumboeck/usb2can

regards,
Bernd


Am 2013-07-17 23:20, schrieb Alexey Khoroshilov:
> If usb_8dev_start() fails to submit urb,
> it unanchors the urb but forgets to free it.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>   drivers/net/can/usb/usb_8dev.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
> index cbd388e..8becd3d 100644
> --- a/drivers/net/can/usb/usb_8dev.c
> +++ b/drivers/net/can/usb/usb_8dev.c
> @@ -779,6 +779,7 @@ static int usb_8dev_start(struct usb_8dev_priv *priv)
>   			usb_unanchor_urb(urb);
>   			usb_free_coherent(priv->udev, RX_BUFFER_SIZE, buf,
>   					  urb->transfer_dma);
> +			usb_free_urb(urb);
>   			break;
>   		}
>
>

