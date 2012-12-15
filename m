From: Dave Wiltshire <dunlucky1@gmail.com>
Subject: Re: Dealing nicely with PM failure
Date: Sat, 15 Dec 2012 22:14:56 +0800
Message-ID: <20121215141456.GA1341@linux-rbgc.site>
References: <3581886.3cmiB2PA1J@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ming Lei <ming.lei@canonical.com>,
	Steve Glendinning <steve@shawell.net>, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:46752 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab2LOOKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 09:10:34 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so3076306pad.19
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2012 06:10:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <3581886.3cmiB2PA1J@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 03:56:26PM +0100, Oliver Neukum wrote:
> @@ -793,15 +794,15 @@ int usbnet_open (struct net_device *net)
>  	// delay posting reads until we're fully open
>  	tasklet_schedule (&dev->bh);
>  	if (info->manage_power) {
> -		retval = info->manage_power(dev, 1);
> -		if (retval < 0)
> -			goto done_manage_power_error;
> -		usb_autopm_put_interface(dev->intf);
> +		int r;
> +
> +		r = info->manage_power(dev, 1);
> +		if (r < 0)
> +			set_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
> +		else
> +			usb_autopm_put_interface(dev->intf);
>  	}
>  	return retval;

Did you mean to change the return value in the successful case? This
used to return 0 on a successful call to info->manage_power(dev, 1).
This patch changes that - perhaps it's still the same (if retval is set
above).

Dave
