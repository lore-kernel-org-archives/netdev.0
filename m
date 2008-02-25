From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] de2104x: remove BUG_ON() when changing media type
Date: Mon, 25 Feb 2008 12:52:17 -0500
Message-ID: <47C30051.3020909@pobox.com>
References: <200801262158.12016.linux@rainbow-software.org> <200802181740.44196.linux@rainbow-software.org> <20080225071505.GC26674@colo.lackof.org> <200802251845.51562.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48046 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbYBYRwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 12:52:22 -0500
In-Reply-To: <200802251845.51562.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ondrej Zary wrote:
> When the chip dies (probably because of a bug somewhere in the driver), 
> de_stop_rxtx() fails and changing the media type crashes the whole machine. 
> Replace BUG_ON() in de_set_media() with a warning.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> 
> --- linux-2.6.24-orig/drivers/net/tulip/de2104x.c	2008-02-25 18:27:34.000000000 +0100
> +++ linux-2.6.24-pentium/drivers/net/tulip/de2104x.c	2008-02-25 18:34:56.000000000 +0100
> @@ -910,7 +910,8 @@
>  	unsigned media = de->media_type;
>  	u32 macmode = dr32(MacMode);
>  
> -	BUG_ON(de_is_running(de));
> +	if (de_is_running(de))
> +		printk(KERN_WARNING "%s: chip is running while changing media!\n", de->dev->name);

Certainly a sane improvement...


