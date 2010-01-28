From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] [PATCH] net: Add support for ndo_select_queue()
	functions to cache the queue mapping
Date: Thu, 28 Jan 2010 18:10:24 +0000
Message-ID: <1264702224.2783.18.camel@achroite.uk.solarflarecom.com>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
	 <OF2C36A392.08814AE1-ON652576B9.00617C98-652576B9.0062AE8B@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50113 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab0A1SK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:10:27 -0500
In-Reply-To: <OF2C36A392.08814AE1-ON652576B9.00617C98-652576B9.0062AE8B@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-28 at 23:39 +0530, Krishna Kumar2 wrote:
> > Ben Hutchings <bhutchings@solarflare.com>
> >
> > We think it's worth matching up RX and TX queue selection for a socket
> > when the queues share an interrupt.  Currently the default TX queue
> > selection is unlikely to match RX queue selection.  TX queue selectionc
> > can be overridden by the driver to match RX queue selection, but at the
> > expense of caching.  We found that without caching the cost of
> > recalculating the the hash in software for each packet outweighed the
> > benefit of good queue selection.
> >
> > This adds two simple helper functions: sk_may_set_tx_queue() reports
> > whether the queue mapping should be cacheable for a socket, and
> > netif_sk_tx_queue_set() sets it after validating the queue index.  This
> > will allow drivers to evalulate expensive queue selection functions
> > (such as Toeplitz hash functions) only once for connected sockets, and
> > to avoid doing so for other skbs.
[...]
> I am confused about this - isn't the txq# and rxq# already
> matched due to the check for skb_rx_queue_recorded?

When forwarding, yes.

> sk_dst_cache is also not set for these routing/forwarding
> workloads, this can be relied only for locally connected
> xmits.

Correct, that's exactly what it's for.

> Other than that, I saw netif_sk_tx_queue_set is not called.
> And dev_pick_tx has already capped automatically, you probably
> don't need another here?

Only the return value of ndo_select_queue() is capped; the cached value
is assumed to be valid.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

