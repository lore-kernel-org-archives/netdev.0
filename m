From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Layer 2 acceleration vs GSO
Date: Fri, 10 Jan 2014 20:39:57 +0000
Message-ID: <1389386397.2025.100.camel@bwh-desktop.uk.level5networks.com>
References: <1389384339.2025.88.camel@bwh-desktop.uk.level5networks.com>
	 <20140110203222.GB2645@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60116 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbaAJUkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:40:01 -0500
In-Reply-To: <20140110203222.GB2645@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 15:32 -0500, Neil Horman wrote:
> On Fri, Jan 10, 2014 at 08:05:39PM +0000, Ben Hutchings wrote:
> > What happens when an skb to be sent through ndo_dfwd_start_xmit()
> > requires software GSO?
> > 
> > dev_hard_start_xmit() will segment it and then submit each segment, and
> > then:
> > 
> > > gso:
> > > 	do {
> > [...]
> > > 		if (accel_priv)
> > > 			rc = ops->ndo_dfwd_start_xmit(nskb, dev, accel_priv);
> > > 		else
> > > 			rc = ops->ndo_start_xmit(nskb, dev);
> > > 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
> > [...]
> > > 		txq_trans_update(txq);
> > 
> > Oops, txq is NULL.  And once we add the obvious condition to that,
> > 
> > > 		if (unlikely(netif_xmit_stopped(txq) && skb->next))
> > > 			return NETDEV_TX_BUSY;
> > 
> > How can we tell if the hardware transmit queue filled up?
> > 
> > It seems like this feature currently relies on the driver returning
> > NETDEV_TX_BUSY when the TX queue is already full, like ixgbe does.  But
> > that is exactly what drivers are *not* supposed to do.
> > 
> > Ben.
> > 
> > > 	} while (skb->next);
> > 
> Dave just to a fix to deal with this (among some other issues) here today:
> http://marc.info/?l=linux-kernel&m=138934276507518&w=2
> Neil

Sorry, I didn't think to check the net tree as I this feature was in
net-next only.  Good to know it's fixed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
