From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Thu, 25 Jul 2013 10:42:49 +1000
Message-ID: <51F07489.7010404@gmail.com>
References: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mwhitehe@redhat.com, kernel-mentors@selenic.com
To: Prashant Shah <pshah.mumbai@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:56096 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753983Ab3GYAm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:42:57 -0400
In-Reply-To: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/07/13 16:09, Prashant Shah wrote:
> Signed-off-by: Prashant Shah <pshah.mumbai@gmail.com>
> ---
>  drivers/net/ethernet/8390/wd.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/8390/wd.c b/drivers/net/ethernet/8390/wd.c
> index 03eb3ee..b43a63f 100644
> --- a/drivers/net/ethernet/8390/wd.c
> +++ b/drivers/net/ethernet/8390/wd.c
> @@ -308,7 +308,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
>  
>  	/* Snarf the interrupt now.  There's no point in waiting since we cannot
>  	   share and the board will usually be enabled. */
> -	i = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
> +	i = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);

You should also remove the definition of DRV_NAME, since it is no longer
used. The changelog should probably mention that this will change the
interrupt name (which appears in /proc/interrupts for example) from "wd"
to "eth%d".

~Ryan
