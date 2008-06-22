From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [patch v2 01/11] DM9000: Remove the 2 resources probe scheme.
Date: Sun, 22 Jun 2008 22:18:11 +0100
Message-ID: <20080622211811.GC26276@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk> <20080622201904.535586386@fluff.org.uk> <20080622203417.GA4050@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	jeff@garzik.org, Laurent Pinchart <laurentp@cse-semaphore.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:57579 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755877AbYFVVSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 17:18:22 -0400
Content-Disposition: inline
In-Reply-To: <20080622203417.GA4050@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 22, 2008 at 09:34:18PM +0100, Ben Hutchings wrote:
> Ben Dooks wrote:
> > From: Laurent Pinchart <laurentp@cse-semaphore.com>
> > 
> > The dm9000 driver accepts either 2 or 3 resources to describe the platform
> > devices. The 2 resources case abuses the ioresource mechanism by passing
> > ioremap()ed memory through the platform device resources. This patch removes
> > that case and converts boards that were using it to the 3 resources scheme.
> > 
> > Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > ---
> > 
> > diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> > index 6bc8924..fca7831 100644
> > --- a/drivers/net/dm9000.c
> > +++ b/drivers/net/dm9000.c
> > @@ -528,7 +528,6 @@ dm9000_probe(struct platform_device *pdev)
> >  	struct board_info *db;	/* Point a board information structure */
> >  	struct net_device *ndev;
> >  	const unsigned char *mac_src;
> > -	unsigned long base;
> >  	int ret = 0;
> >  	int iosize;
> >  	int i;
> > @@ -561,78 +560,61 @@ dm9000_probe(struct platform_device *pdev)
> >  	if (pdev->num_resources < 2) {
> >  		ret = -ENODEV;
> >  		goto out;
> [...]
> 
> So shouldn't "< 2" be changed to "!= 3"?

Hmm, I'll edit laurent's patch and re-send, assuming it's alright with
him.
 
> Ben.

No, I'm Ben!

> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
