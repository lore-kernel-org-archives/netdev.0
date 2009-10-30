From: Brandon Philips <bphilips@suse.de>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Thu, 29 Oct 2009 20:51:28 -0700
Message-ID: <20091030035128.GA3380@jenkins.home.ifup.org>
References: <20091029235807.GF3228@jenkins.home.ifup.org>
 <20091029200905.00f4c13d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56701 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754AbZJ3Dva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 23:51:30 -0400
Content-Disposition: inline
In-Reply-To: <20091029200905.00f4c13d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20:09 Thu 29 Oct 2009, Stephen Hemminger wrote:
> On Thu, 29 Oct 2009 16:58:07 -0700
> Brandon Philips <bphilips@suse.de> wrote:
> 
> > Before bringing up a sky2 interface up ethtool reports 
> > "Link detected: yes". Do as ixgbe does and netif_carrier_off() on
> > probe().
> > 
> > Signed-off-by: Brandon Philips <bphilips@suse.de>
> > 
> > ---
> >  drivers/net/sky2.c |    2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > Index: linux-2.6/drivers/net/sky2.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/sky2.c
> > +++ linux-2.6/drivers/net/sky2.c
> > @@ -4538,6 +4538,8 @@ static int __devinit sky2_probe(struct p
> >  		goto err_out_free_netdev;
> >  	}
> >  
> > +	netif_carrier_off(dev);
> > +
> >  	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
> >  
> >  	err = request_irq(pdev->irq, sky2_intr,
> 
> IMHO carrier is meaningless until device is up? What software
> cares?

A customer had a script that was testing for ethtool reporting "Link
detected: yes" and taking some sort of action. They found other
drivers reported "Link detected: No" until the first interface up.

The right thing to do is up the interface first before looking at the
the Link state, and I told them to do that, but I figured that this
patch made sense too to fix the initial buglet.

Cheers,

	Brandon
