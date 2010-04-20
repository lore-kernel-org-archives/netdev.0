From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: Fix possible NULL pointer dereference in ems_usb.c
Date: Tue, 20 Apr 2010 21:47:37 +0200
Message-ID: <4BCE04D9.2030601@grandegger.com>
References: <20100420135538.GA1994@bluebox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100420135538.GA1994-hikPBsva6T+Nj9Bq2fkWzw@public.gmane.org>
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
> In ems_usb_probe(), a pointer is dereferenced after making sure it is NULL...
> 
> This patch replaces dev_err() with printk() to avoid this.
> 
> Signed-off-by: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> ---
>  drivers/net/can/usb/ems_usb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.34-rc/drivers/net/can/usb/ems_usb.c
> ===================================================================
> --- linux-2.6.34-rc.orig/drivers/net/can/usb/ems_usb.c	2010-04-20 15:32:25.000000000 +0200
> +++ linux-2.6.34-rc/drivers/net/can/usb/ems_usb.c	2010-04-20 15:33:20.000000000 +0200
> @@ -1006,7 +1006,7 @@
>  
>  	netdev = alloc_candev(sizeof(struct ems_usb), MAX_TX_URBS);
>  	if (!netdev) {
> -		dev_err(netdev->dev.parent, "Couldn't alloc candev\n");
> +		printk(KERN_ERR "ems_usb: Couldn't alloc candev\n");
>  		return -ENOMEM;
>  	}

I think "dev_err(&intf->dev, ...)" should be used before
SET_NETDEV_DEV(netdev, &intf->dev) is called. I see two "dev_err()"
calls which need to be fixed.

Wolfgang.
