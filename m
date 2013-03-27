From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] yam: avoid null pointer dereference error
Date: Wed, 27 Mar 2013 17:44:17 +0000
Message-ID: <1364406257.2922.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1364383174-17708-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jean-Paul Roubelat <jpr@f6fbb.org>, <linux-hams@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59274 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590Ab3C0RoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:44:21 -0400
In-Reply-To: <1364383174-17708-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 11:19 +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> yam_open checks if dev is null, however, before that check it
> accesses some of the fields from dev in a proceeding printk which
> will cause a null pointer dereference error if dev is nul. Move
> the printk to after the null check.

This function will never be called with dev == NULL.

Ben.

> Smatch analysis:
> 
> drivers/net/hamradio/yam.c:869 yam_open() warn: variable
>   dereferenced before check 'dev' (see line 867)
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/hamradio/yam.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
> index 4cf8f10..e021e51 100644
> --- a/drivers/net/hamradio/yam.c
> +++ b/drivers/net/hamradio/yam.c
> @@ -864,10 +864,11 @@ static int yam_open(struct net_device *dev)
>  	int i;
>  	int ret=0;
>  
> -	printk(KERN_INFO "Trying %s at iobase 0x%lx irq %u\n", dev->name, dev->base_addr, dev->irq);
> -
>  	if (!dev || !yp->bitrate)
>  		return -ENXIO;
> +
> +	printk(KERN_INFO "Trying %s at iobase 0x%lx irq %u\n", dev->name, dev->base_addr, dev->irq);
> +
>  	if (!dev->base_addr || dev->base_addr > 0x1000 - YAM_EXTENT ||
>  		dev->irq < 2 || dev->irq > 15) {
>  		return -ENXIO;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
