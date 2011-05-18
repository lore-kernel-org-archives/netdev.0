From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v2] CDC NCM: release interfaces fix in unbind()
Date: Wed, 18 May 2011 10:54:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1105181053110.2131-100000@iolanthe.rowland.org>
References: <1305662344-28355-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <davem@davemloft.net>, <oliver@neukum.org>,
	<linux-usb@vger.kernel.org>, <gregkh@suse.de>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:56949 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752758Ab1EROyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 10:54:38 -0400
In-Reply-To: <1305662344-28355-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 May 2011, Alexey Orishko wrote:

> Changes:
> - claim slave/data interface during bind() and release in
>  unbind() unconditionally
> - in case of error during bind(), release claimed data
>  interface in the same function
> - remove obsolited "*_claimed" entries from driver context

...

> @@ -572,42 +559,32 @@ advance:
>  		goto error;
>  
>  	/* claim interfaces, if any */
> -	if (ctx->data != intf) {
> -		temp = usb_driver_claim_interface(driver, ctx->data, dev);
> -		if (temp)
> -			goto error;
> -		ctx->data_claimed = 1;
> -	}
> -
> -	if (ctx->control != intf) {
> -		temp = usb_driver_claim_interface(driver, ctx->control, dev);
> -		if (temp)
> -			goto error;
> -		ctx->control_claimed = 1;
> -	}
> +	temp = usb_driver_claim_interface(driver, ctx->data, dev);
> +	if (temp)
> +		goto error;

Here and later on, the patch seems to have forgotten about the control 
interface.  Is this deliberate or an oversight?

Alan Stern

