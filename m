From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 2/2] usbnet: Convert dbg to dev_dbg and neatening
Date: Wed, 04 May 2011 15:35:55 +0400
Message-ID: <4DC13A1B.8020004@ru.mvista.com>
References: <cover.1304445019.git.joe@perches.com> <f86364fbdc335fadad003081d010843579e95765.1304445019.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum@suse.de>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f86364fbdc335fadad003081d010843579e95765.1304445019.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03-05-2011 22:17, Joe Perches wrote:

> Use the more standard logging form.
> Add a bit more tidying style.

    Style changes look rather doubtful to me...

> Signed-off-by: Joe Perches<joe@perches.com>
> ---
>   drivers/net/usb/usbnet.c |   23 +++++++++++------------
>   1 files changed, 11 insertions(+), 12 deletions(-)

> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 28aecbb..b803085 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -192,8 +192,8 @@ static int init_status(struct usbnet *dev, struct usb_interface *intf)
>   		return 0;
>
>   	pipe = usb_rcvintpipe(dev->udev,
> -			      dev->status->desc.bEndpointAddress
> -			& USB_ENDPOINT_NUMBER_MASK);
> +			      (dev->status->desc.bEndpointAddress
> +			& USB_ENDPOINT_NUMBER_MASK));

    Why add parens?

> @@ -1345,8 +1346,9 @@ usbnet_probe(struct usb_interface *udev, const struct usb_device_id *prod)
>   	dev->intf = udev;
>   	dev->driver_info = info;
>   	dev->driver_name = name;
> -	dev->msg_enable = netif_msg_init(msg_level, NETIF_MSG_DRV
> -					 | NETIF_MSG_PROBE | NETIF_MSG_LINK);
> +	dev->msg_enable = netif_msg_init(msg_level, (NETIF_MSG_DRV |
> +						     NETIF_MSG_PROBE |
> +						     NETIF_MSG_LINK));

    Why add parens?

> @@ -1466,8 +1468,7 @@ EXPORT_SYMBOL_GPL(usbnet_probe);
>
>   /*-------------------------------------------------------------------------*/
>
> -/*
> - * suspend the whole driver as soon as the first interface is suspended
> +/* suspend the whole driver as soon as the first interface is suspended

    Why? This already corresponded to the preferred multi-line comment style...

>    * resume only when the last interface is resumed
>    */
>
> @@ -1485,16 +1486,14 @@ int usbnet_suspend(struct usb_interface *intf, pm_message_t message)
>   			set_bit(EVENT_DEV_ASLEEP,&dev->flags);
>   			spin_unlock_irq(&dev->txq.lock);
>   		}
> -		/*
> -		 * accelerate emptying of the rx and queues, to avoid
> +		/* accelerate emptying of the rx and queues, to avoid

    Why?

>   		 * having everything error out.
>   		 */
>   		netif_device_detach(dev->net);
>   		usbnet_terminate_urbs(dev);
>   		usb_kill_urb(dev->interrupt);
>
> -		/*
> -		 * reattach so runtime management can use and
> +		/* reattach so runtime management can use and

    Why?

WBR, Sergei
