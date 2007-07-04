From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] Cleanup usbnet_probe() return value handling
Date: Tue, 3 Jul 2007 21:34:13 -0700
Message-ID: <200707032134.13339.david-b@pacbell.net>
References: <87lkdyx19a.fsf@nanv.dk> <200707020914.38479.david-b@pacbell.net> <87sl86juel.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:45027 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751900AbXGDEeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 00:34:15 -0400
In-Reply-To: <87sl86juel.fsf@p4.be.48ers.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 July 2007, Peter Korsgaard wrote:

> usbnet_probe() handles a positive return value from the driver bind()
> function as success, but will later only setup the status handler if the
> return value was zero, leading to confusion. Patch adjusts this to accept
> positive values as success in both checks.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

... though I'd adjust comments to say "non-negative" rather
than "positive".  Most folks won't say that zero is positive.


> ---
>  drivers/net/usb/usbnet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.22-rc7/drivers/net/usb/usbnet.c
> ===================================================================
> --- linux-2.6.22-rc7.orig/drivers/net/usb/usbnet.c
> +++ linux-2.6.22-rc7/drivers/net/usb/usbnet.c
> @@ -1208,7 +1208,7 @@
>  			status = 0;
>  
>  	}
> -	if (status == 0 && dev->status)
> +	if (status >= 0 && dev->status)
>  		status = init_status (dev, udev);
>  	if (status < 0)
>  		goto out3;
> 
> -- 
> Bye, Peter Korsgaard
> 


