From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch v2 01/11] DM9000: Remove the 2 resources probe scheme.
Date: Sun, 22 Jun 2008 21:34:18 +0100
Message-ID: <20080622203417.GA4050@solarflare.com>
References: <20080622201645.041001353@fluff.org.uk> <20080622201904.535586386@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:53726 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754634AbYFVUea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:34:30 -0400
Content-Disposition: inline
In-Reply-To: <20080622201904.535586386@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> From: Laurent Pinchart <laurentp@cse-semaphore.com>
> 
> The dm9000 driver accepts either 2 or 3 resources to describe the platform
> devices. The 2 resources case abuses the ioresource mechanism by passing
> ioremap()ed memory through the platform device resources. This patch removes
> that case and converts boards that were using it to the 3 resources scheme.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 6bc8924..fca7831 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -528,7 +528,6 @@ dm9000_probe(struct platform_device *pdev)
>  	struct board_info *db;	/* Point a board information structure */
>  	struct net_device *ndev;
>  	const unsigned char *mac_src;
> -	unsigned long base;
>  	int ret = 0;
>  	int iosize;
>  	int i;
> @@ -561,78 +560,61 @@ dm9000_probe(struct platform_device *pdev)
>  	if (pdev->num_resources < 2) {
>  		ret = -ENODEV;
>  		goto out;
[...]

So shouldn't "< 2" be changed to "!= 3"?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
