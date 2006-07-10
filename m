From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] workaround zd1201 interference problem
Date: Mon, 10 Jul 2006 14:31:07 -0400
Message-ID: <20060710183102.GE13775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavel@ucw.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:521 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965188AbWGJSbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 14:31:21 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Forwarded message from Pavel Machek <pavel@ucw.cz> -----

> zd1201 has nasty tendency to emit magicall anti-wifi cloud when it is
> inserted into slot, but not used.
> 
> Signed-off-by: Pavel Machek <pavel@suse.cz>
> 
> --- linux-good/drivers/usb/net/zd1201.c	2006-03-30 13:51:58.000000000 +0200
> +++ linux/drivers/net/wireless/zd1201.c	2006-06-15 23:28:04.000000000 +0200
> @@ -1835,6 +1835,8 @@
>  	    zd->dev->name);
>  	
>  	usb_set_intfdata(interface, zd);
> +	zd1201_enable(zd);	/* zd1201 likes to startup enabled, interfering */
> +	zd1201_disable(zd); 	/* with all the wifis in range */
>  	return 0;
>  
>  err_net:

Pavel's patch is still the best thing proposed so far to resolve this
issue, ugly as it may be.

It does seem to fix a real issue.  Is anyone gonna puke if a merge
this?  If so, where is your patch?

John
-- 
John W. Linville
linville@tuxdriver.com
