From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Wed, 28 Dec 2011 08:41:43 +0100
Message-ID: <20111228074143.GA8041@florz.florz.dyndns.org>
References: <20111225081833.GC3088@florz.florz.dyndns.org>
 <20111226.151754.417402855307646295.davem@davemloft.net>
 <20111227095635.19087752@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rain.florz.de ([62.216.164.86]:45720 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751252Ab1L1Hlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 02:41:52 -0500
Content-Disposition: inline
In-Reply-To: <20111227095635.19087752@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > > diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> > > index f4be5c7..cd968e5 100644
> > > --- a/drivers/net/skge.c
> > > +++ b/drivers/net/skge.c
> > > @@ -4046,6 +4046,7 @@ static int skge_resume(struct device *dev)
> > >  				dev_close(dev);
> > >  				goto out;
> > >  			}
> > > +			skge_set_multicast(dev);
> > >  		}
> > >  	}
> > >  out:
> 
> Right idea, but it needs to be done in a different spot to catch
> all the other device restart cases like changing settings.

Roughly like this maybe? (Successfully tested with an MTU change ...)

Florian

---------------------------------------------------------------------------
skge: restore rx multicast filter on resume

Signed-off-by: Florian Zumbiehl <florz@florz.de>

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index f4be5c7..8f985a8 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2587,6 +2587,9 @@ static int skge_up(struct net_device *dev)
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
+
+	skge_set_multicast(dev);
+
 	return 0;
 
  free_rx_ring:
