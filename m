From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net/smsc911x: Move interrupt allocation to open/stop
Date: Thu, 1 Sep 2016 21:45:10 +0200
Message-ID: <20160901194510.GB13292@lunn.ch>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
 <1472747141-15886-3-git-send-email-jeremy.linton@arm.com>
 <20160901170617.GD10951@lunn.ch>
 <8305921f-9b9a-459b-2452-7c4e63057e8f@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754700AbcIAVXu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:50 -0400
Content-Disposition: inline
In-Reply-To: <8305921f-9b9a-459b-2452-7c4e63057e8f@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 01:47:44PM -0500, Jeremy Linton wrote:
> Hi Andrew,
> 
> 	Thanks for taking a look at this!
> 
> On 09/01/2016 12:06 PM, Andrew Lunn wrote:
> >Hi Jeremy
> >
> >Please don't add forward references. Move the function earlier in the
> >file.
> 
> Ok, but I thought it was a fairly large move due to further
> dependent functions..

There are a few other options, like moving smsc911x_open() rather than
the interrupt handler.

And i would suggest what ever you do, make it a separate patch. A
patch which says: No functional changes, just move functions around as
needed by later patches, is going to be quick and easy to review.

> >>+	netif_carrier_off(dev);
> >
> >What has this change got to do with interrupt handling?
> 
> 	This is a whoops, it should be in the previous patch..

Or a patch of its own? You also needs to be careful with ordering
against the phy_connect.

> >>@@ -2479,38 +2491,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
> >> 	if (retval < 0)
> >> 		goto out_disable_resources;
> >>
> >>-	/* configure irq polarity and type before connecting isr */
> >>-	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
> >>-		intcfg |= INT_CFG_IRQ_POL_;
> >>-
> >>-	if (pdata->config.irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
> >>-		intcfg |= INT_CFG_IRQ_TYPE_;
> >>-
> >>-	smsc911x_reg_write(pdata, INT_CFG, intcfg);
> >
> >
> >I see these removes, but where are the adds?
> 
> 
> 	The functionality is duplicated in open, when the IRQ handler is tested.

Ah, it is obfusticated by SMC_SET_IRQ_CFG().

If you say it is duplicated, how about a separate patch removing it,
with a clear pointer to where the duplicate is.

     Andrew
