From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: Fix possible NULL pointer dereference in ems_usb.c
Date: Wed, 21 Apr 2010 12:27:50 +0200
Message-ID: <4BCED326.3060000@grandegger.com>
References: <20100420135538.GA1994@bluebox.local>	<4BCE04D9.2030601@grandegger.com>	<20100420.180501.08643239.davem@davemloft.net>
	<20100421101805.GA1995@bluebox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100421101805.GA1995-hikPBsva6T+Nj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hans J. Koch wrote:
> On Tue, Apr 20, 2010 at 06:05:01PM -0700, David Miller wrote:
>> From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>> I think "dev_err(&intf->dev, ...)" should be used before
>>> SET_NETDEV_DEV(netdev, &intf->dev) is called. I see two "dev_err()"
>>> calls which need to be fixed.
>> Agreed.
> 
> Then it should probably look like this:

There are even more dev_err's to be fixed...

> From: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> 	Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
> Subject: [PATCH] can: Fix possible NULL pointer dereference in ems_usb.c
> 
> In ems_usb_probe(), a pointer is dereferenced after making sure it is NULL...
> 
> This patch replaces netdev->dev.parent with &intf->dev in dev_err() calls to
> avoid this.
> 
> Signed-off-by: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> ---
>  drivers/net/can/usb/ems_usb.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> Index: net-next-2.6/drivers/net/can/usb/ems_usb.c
> ===================================================================
> --- net-next-2.6.orig/drivers/net/can/usb/ems_usb.c	2010-04-13 11:27:33.000000000 +0200
> +++ net-next-2.6/drivers/net/can/usb/ems_usb.c	2010-04-21 11:59:04.000000000 +0200
> @@ -1006,7 +1006,7 @@
>  
>  	netdev = alloc_candev(sizeof(struct ems_usb), MAX_TX_URBS);
>  	if (!netdev) {
> -		dev_err(netdev->dev.parent, "Couldn't alloc candev\n");
> +		dev_err(&intf->dev, "ems_usb: Couldn't alloc candev\n");
>  		return -ENOMEM;
>  	}
>  
> @@ -1036,20 +1036,20 @@
>  
>  	dev->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
>  	if (!dev->intr_urb) {
> -		dev_err(netdev->dev.parent, "Couldn't alloc intr URB\n");
> +		dev_err(&intf->dev, "Couldn't alloc intr URB\n");
>  		goto cleanup_candev;
>  	}
>  
>  	dev->intr_in_buffer = kzalloc(INTR_IN_BUFFER_SIZE, GFP_KERNEL);
>  	if (!dev->intr_in_buffer) {
> -		dev_err(netdev->dev.parent, "Couldn't alloc Intr buffer\n");
> +		dev_err(&intf->dev, "Couldn't alloc Intr buffer\n");
>  		goto cleanup_intr_urb;
>  	}
>  
>  	dev->tx_msg_buffer = kzalloc(CPC_HEADER_SIZE +
>  				     sizeof(struct ems_cpc_msg), GFP_KERNEL);
>  	if (!dev->tx_msg_buffer) {
> -		dev_err(netdev->dev.parent, "Couldn't alloc Tx buffer\n");
> +		dev_err(&intf->dev, "Couldn't alloc Tx buffer\n");
>  		goto cleanup_intr_in_buffer;
>  	}

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
