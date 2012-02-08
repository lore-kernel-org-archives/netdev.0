From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 37/50] usbnet: set addr_assign_type if random_ether_addr() used
Date: Wed, 8 Feb 2012 22:30:19 +0100
Message-ID: <201202082230.19936.oliver@neukum.org>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <1328735457-29986-38-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Danny Kukawka <dkukawka@suse.de>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-38-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 8. Februar 2012, 22:10:44 schrieb Danny Kukawka:
> Set addr_assign_type correctly to NET_ADDR_RANDOM in case
> a random MAC address was generated and assigned to the netdevice.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/usb/usbnet.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index fae0fbd..7bd07d7 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1365,6 +1365,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>  	dev->net = net;
>  	strcpy (net->name, "usb%d");
>  	memcpy (net->dev_addr, node_id, sizeof node_id);
> +	net->addr_assign_type |= NET_ADDR_RANDOM;
>  
>  	/* rx and tx sides can use different message sizes;
>  	 * bind() should set rx_urb_size in that case.

Don't you set the flag too early here? By that time we don't know
whether the device provides a real MAC, do we?

	Regards
		Oliver
