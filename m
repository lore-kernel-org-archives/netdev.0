From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: ems_usb: fix urb leaks on failure paths
Date: Sat, 07 Dec 2013 12:42:54 +0100
Message-ID: <52A309BE.7000602@hartkopp.net>
References: <1386371435-17597-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Sebastian Haas <dev@sebastianhaas.info>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1386371435-17597-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alexey,

looks better :-)

I added the author of this driver to double check the patch and for his
Acked-by ...

@Sebastian: Would you like to update your e-mail address too?

Best regards,
Oliver


On 07.12.2013 00:10, Alexey Khoroshilov wrote:
> There are a couple failure paths where urb leaks.
> Is spare code within ems_usb_start_xmit(),
> usb_free_urb() should be used to deallocate urb instead of usb_unanchor_urb().
> In ems_usb_start() there is no usb_free_urb() if usb_submit_urb() fails.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/can/usb/ems_usb.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
> index 5f9a7ad9b964..8aeec0b4601a 100644
> --- a/drivers/net/can/usb/ems_usb.c
> +++ b/drivers/net/can/usb/ems_usb.c
> @@ -625,6 +625,7 @@ static int ems_usb_start(struct ems_usb *dev)
>  			usb_unanchor_urb(urb);
>  			usb_free_coherent(dev->udev, RX_BUFFER_SIZE, buf,
>  					  urb->transfer_dma);
> +			usb_free_urb(urb);
>  			break;
>  		}
>  
> @@ -798,8 +799,8 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
>  	 * allowed (MAX_TX_URBS).
>  	 */
>  	if (!context) {
> -		usb_unanchor_urb(urb);
>  		usb_free_coherent(dev->udev, size, buf, urb->transfer_dma);
> +		usb_free_urb(urb);
>  
>  		netdev_warn(netdev, "couldn't find free context\n");
>  
> 
