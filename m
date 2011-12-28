From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Wed, 28 Dec 2011 09:27:14 -0800
Message-ID: <20111228092714.0a6d5f80@nehalam.linuxnetplumber.net>
References: <20111225081833.GC3088@florz.florz.dyndns.org>
	<20111226.151754.417402855307646295.davem@davemloft.net>
	<20111227095635.19087752@nehalam.linuxnetplumber.net>
	<20111228074143.GA8041@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Zumbiehl <florz@florz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36068 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab1L1R1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 12:27:18 -0500
In-Reply-To: <20111228074143.GA8041@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Dec 2011 08:41:43 +0100
Florian Zumbiehl <florz@florz.de> wrote:

> Hi,
> 
> > > > diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> > > > index f4be5c7..cd968e5 100644
> > > > --- a/drivers/net/skge.c
> > > > +++ b/drivers/net/skge.c
> > > > @@ -4046,6 +4046,7 @@ static int skge_resume(struct device *dev)
> > > >  				dev_close(dev);
> > > >  				goto out;
> > > >  			}
> > > > +			skge_set_multicast(dev);
> > > >  		}
> > > >  	}
> > > >  out:
> > 
> > Right idea, but it needs to be done in a different spot to catch
> > all the other device restart cases like changing settings.
> 
> Roughly like this maybe? (Successfully tested with an MTU change ...)
> 
> Florian
> 
> ---------------------------------------------------------------------------
> skge: restore rx multicast filter on resume
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>
> 
> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index f4be5c7..8f985a8 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -2587,6 +2587,9 @@ static int skge_up(struct net_device *dev)
>  	spin_unlock_irq(&hw->hw_lock);
>  
>  	napi_enable(&skge->napi);
> +
> +	skge_set_multicast(dev);
> +
>  	return 0;
>  
>   free_rx_ring:

Looks good. That is (basically) the same as the patch I was testing.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
