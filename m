From: Andreas Herrmann <andreas.herrmann@calxeda.com>
Subject: Re: [PATCH] net: calxedaxgmac: Fix panic caused by MTU change of
 active interface
Date: Wed, 6 Nov 2013 20:25:53 +0100
Message-ID: <20131106192553.GH5661@alberich>
References: <20131106133126.GL22917@alberich>
 <1383765756.1520.24.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp161.dfw.emailsrvr.com ([67.192.241.161]:36558 "EHLO
	smtp161.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab3KFTZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 14:25:59 -0500
Content-Disposition: inline
In-Reply-To: <1383765756.1520.24.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 02:22:36PM -0500, Ben Hutchings wrote:
> On Wed, 2013-11-06 at 14:31 +0100, Andreas Herrmann wrote:
> [...]
> > diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
> > index 48f5288..8eb422a 100644
> > --- a/drivers/net/ethernet/calxeda/xgmac.c
> > +++ b/drivers/net/ethernet/calxeda/xgmac.c
> > @@ -1067,6 +1067,10 @@ static int xgmac_stop(struct net_device *dev)
> >  
> >  	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
> >  
> > +	netif_tx_lock_bh(dev);
> > +	netif_stop_queue(dev);
> > +	netif_tx_unlock_bh(dev);
> > +
> [...]
> 
> There is already a call to netif_stop_queue() at the beginning of this
> function, but without locking.  I think it's the wrong place because the
> NAPI poller may still call netif_wake_queue() at that point.  You're
> putting this in the *right* place, but I think you should remove the
> first call.

Ok.

> Also this sequence is also equivalent to netif_tx_disable(), except that
> that also works for multiqueue net devices.

Ok, wasn't aware of this.

I'll send a new patch.


Thanks,

Andreas
