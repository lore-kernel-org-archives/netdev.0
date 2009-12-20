From: Simon Horman <horms@verge.net.au>
Subject: Re: [net-next PATCH 5/6] enic: feature add: add ethtool -c/C
 support
Date: Sun, 20 Dec 2009 12:15:27 +1100
Message-ID: <20091220011526.GB12578@verge.net.au>
References: <20091219101050.GA20743@verge.net.au>
 <C7526AA2.1AFF9%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60920 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887AbZLTBP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 20:15:28 -0500
Content-Disposition: inline
In-Reply-To: <C7526AA2.1AFF9%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 19, 2009 at 11:33:54AM -0800, Scott Feldman wrote:
> Thanks for the review comments Simon.
> 
> On 12/19/09 2:10 AM, "Simon Horman" <horms@verge.net.au> wrote:
> 
> > On Fri, Dec 18, 2009 at 06:10:02PM -0800, Scott Feldman wrote:
> >> + /* Only rx-usecs and tx-usecs can be set */
> >> + if (ecmd->rx_max_coalesced_frames || ecmd->rx_coalesce_usecs_irq ||
> >> +     ecmd->rx_max_coalesced_frames_irq ||
> >> +     ecmd->tx_max_coalesced_frames || ecmd->tx_coalesce_usecs_irq ||
> >> +     ecmd->tx_max_coalesced_frames_irq ||
> >> +     ecmd->stats_block_coalesce_usecs ||
> >> +     ecmd->use_adaptive_rx_coalesce || ecmd->use_adaptive_tx_coalesce ||
> >> +     ecmd->pkt_rate_low ||
> >> +     ecmd->rx_coalesce_usecs_low || ecmd->rx_max_coalesced_frames_low ||
> >> +     ecmd->tx_coalesce_usecs_low || ecmd->tx_max_coalesced_frames_low ||
> >> +     ecmd->pkt_rate_high ||
> >> +     ecmd->rx_coalesce_usecs_high ||
> >> +     ecmd->rx_max_coalesced_frames_high ||
> >> +     ecmd->tx_coalesce_usecs_high ||
> >> +     ecmd->tx_max_coalesced_frames_high ||
> >> +     ecmd->rate_sample_interval)
> >> +  return -EINVAL;
> > 
> > This seems rather verbose.  Does it really matter if there is junk in other
> > ecmd fields?  They seem to be otherwise ignored. Removing the check above
> > would seem to be consistent with other enic_set_*() functions.
> 
> Ya, we can do that.
>  
> >> if (mtu && mtu != enic->port_mtu) {
> >> +  enic->port_mtu = mtu;
> >> if (mtu < enic->netdev->mtu)
> >> printk(KERN_WARNING PFX
> >> "%s: interface MTU (%d) set higher "
> >> "than switch port MTU (%d)\n",
> >> enic->netdev->name, enic->netdev->mtu, mtu);
> >> -  enic->port_mtu = mtu;
> >> }
> >>  }
> > 
> > This hunk seems unrelated to the rest of the patch.
> > Am I missing something?
> 
> Oops, that change snuck in there.  That line got moved due to some backward
> compat changes, which have been stripped away, so it looks like that line is
> moving for no reason.  It's a benign change so let's make the change to be
> consistent with our internal code base.

Sure, it doesn't seem to be doing any harm.

> >> + enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
> >> + enic->rx_coalesce_usecs =  enic->tx_coalesce_usecs;
> >> +
> > 
> > It looks like there is an space after =
> 
> Got it.
> 
> -scott
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
