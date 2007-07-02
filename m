From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] Cleanup usbnet_probe() return value handling
Date: Mon, 2 Jul 2007 09:14:38 -0700
Message-ID: <200707020914.38479.david-b@pacbell.net>
References: <87lkdyx19a.fsf@nanv.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:28704 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751545AbXGBQOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 12:14:41 -0400
In-Reply-To: <87lkdyx19a.fsf@nanv.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 July 2007, Peter Korsgaard wrote:
> usbnet_probe() handles a positive return value from the driver bind()
> function as success, but will later only setup the status handler if the
> return value was zero, leading to confusion. Patch adjusts this to only
> accept 0 as success in both checks.

I'd rather see the later test updated to match this one.
(Good catch!)

The return convention is "negative means error".  There's
code in USB which has multiple nonnegative success codes.

In particular usb_control_msg(), which would very naturally
used as the body of a bind() method, returns negative or
the number of bytes transferred.

- Dave


> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  drivers/net/usb/usbnet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.22-rc7/drivers/net/usb/usbnet.c
> ===================================================================
> --- linux-2.6.22-rc7.orig/drivers/net/usb/usbnet.c
> +++ linux-2.6.22-rc7/drivers/net/usb/usbnet.c
> @@ -1182,7 +1182,7 @@
>  	// NOTE net->name still not usable ...
>  	if (info->bind) {
>  		status = info->bind (dev, udev);
> -		if (status < 0)
> +		if (status != 0)
>  			goto out1;
>  
>  		// heuristic:  "usb%d" for links we know are two-host,
> 
> -- 
> Bye, Peter Korsgaard
> 


