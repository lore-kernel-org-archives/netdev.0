From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] usbnet: Resubmit interrupt URB more often
Date: Tue, 19 Apr 2011 18:11:06 +0100
Message-ID: <1303233066.2988.14.camel@bwh-desktop>
References: <20110419164703.5A6A82052B@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29574 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606Ab1DSRLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 13:11:10 -0400
In-Reply-To: <20110419164703.5A6A82052B@glenhelen.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 09:35 -0700, Paul Stewart wrote:
[...]
> index 4342bd9..e4dbb29 100644
> --- a/drivers/usb/core/urb.c
> +++ b/drivers/usb/core/urb.c
> @@ -295,7 +295,9 @@ int usb_submit_urb(struct urb *urb, gfp_t mem_flags)
>  	struct usb_host_endpoint	*ep;
>  	int				is_out;
>  
> -	if (!urb || urb->hcpriv || !urb->complete)
> +	if (urb->hcpriv)
> +		return -EALREADY;
> +	if (!urb || !urb->complete)
>  		return -EINVAL;
[...]

The test for !urb must come before the test on urb->hcpriv.

Also, the kernel coding style does not allow '//' comments.  Please use
scripts/checkpatch.pl to check for style and other common errors.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

