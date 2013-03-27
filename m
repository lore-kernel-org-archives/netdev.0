From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] yam: avoid null pointer dereference error
Date: Wed, 27 Mar 2013 18:12:33 +0000
Message-ID: <1364407953.2922.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1364383174-17708-1-git-send-email-colin.king@canonical.com>
	 <1364406257.2922.11.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130327.134651.702432728001011428.davem@davemloft.net>
	 <5153358A.5010505@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <jpr@f6fbb.org>,
	<linux-hams@vger.kernel.org>, <netdev@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42437 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab3C0SMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:12:37 -0400
In-Reply-To: <5153358A.5010505@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 18:08 +0000, Colin Ian King wrote:
> On 27/03/13 17:46, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Wed, 27 Mar 2013 17:44:17 +0000
> >
> >> On Wed, 2013-03-27 at 11:19 +0000, Colin King wrote:
> >>> From: Colin Ian King <colin.king@canonical.com>
> >>>
> >>> yam_open checks if dev is null, however, before that check it
> >>> accesses some of the fields from dev in a proceeding printk which
> >>> will cause a null pointer dereference error if dev is nul. Move
> >>> the printk to after the null check.
> >>
> >> This function will never be called with dev == NULL.
> >
> > Then let's remove at least that part of the check.
> >
> Good point. How about the following..

> From 564f111f196d9d7293e922a68ba973210d191129 Mon Sep 17 00:00:00 2001
> From: Colin Ian King <colin.king@canonical.com>
> Date: Wed, 27 Mar 2013 13:59:05 -0400
> Subject: [PATCH] yam: remove redundant null check on dev
> 
> yam_open has a redundant null check on null,  it will
> never be called with dev == NULL. Remove this redundant check.
> This also cleans up a smatch warning:
> 
> drivers/net/hamradio/yam.c:869 yam_open() warn: variable
>   dereferenced before check 'dev' (see line 867)
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

(for what it's worth)

> ---
>  drivers/net/hamradio/yam.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
> index 4cf8f10..b2d863f 100644
> --- a/drivers/net/hamradio/yam.c
> +++ b/drivers/net/hamradio/yam.c
> @@ -866,7 +866,7 @@ static int yam_open(struct net_device *dev)
>  
>         printk(KERN_INFO "Trying %s at iobase 0x%lx irq %u\n",
> dev->name, dev->base_addr, dev->irq);
>  
> -       if (!dev || !yp->bitrate)
> +       if (!yp->bitrate)
>                 return -ENXIO;
>         if (!dev->base_addr || dev->base_addr > 0x1000 - YAM_EXTENT ||
>                 dev->irq < 2 || dev->irq > 15) {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
