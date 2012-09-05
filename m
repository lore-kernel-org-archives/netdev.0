From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Wed, 5 Sep 2012 23:53:14 +0100
Message-ID: <1346885594.5325.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120904.123740.1915830868205918256.davem@davemloft.net>
	 <20120905.125016.2259674613767082102.davem@davemloft.net>
	 <1346883275.5325.28.camel@bwh-desktop.uk.solarflarecom.com>
	 <2059099.RnKXUv0tR1@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7687 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759772Ab2IEWxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 18:53:18 -0400
In-Reply-To: <2059099.RnKXUv0tR1@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 00:34 +0200, Oliver Neukum wrote:
> On Wednesday 05 September 2012 23:14:35 Ben Hutchings wrote:
> > cdc-ncm is aggregating skbs into jumbo USB packets and then, because the
> > netdev is not signalled when the qdisc stops transmitting, flushing them
> > after one scheduler tick.  Flushing is done by calling
> > usbnet_start_xmit() with a null skb pointer and then substituting a real
> > skb in the tx_fixup callback.
> > 
> > Perhaps the skb_tx_timestamp() call should be moved below the
> > 'if (info->tx_fixup)' block, at which point skb is definitely non-null.
> > It doesn't look like cdc-ncm will provide useful timestamps either way.
> > 
> > cdc-ncm's aggregation could be improved by either (1) implementing some
> > type of GSO with appropriate gso_max_size and gso_max_segs limits (2)
> > adding an explicit transmit flushing operation, similar to that
> > Alexander Duyck proposed.
> 
> Actually, I thought about changing it. This is the current version. What do you think?
> It lacks a bit of logic in the completion handler still.
[...]

I'm not familiar with the USB net framework (or USB in general), so I
don't know whether this would work.  But it looks like you're trying to
use the TX completions to trigger flushing of the aggregated USB packet,
and flushing immediately if there are no packets currently outstanding.
That seems like a reasonable approach.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
