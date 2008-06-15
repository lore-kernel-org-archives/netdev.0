From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Sun, 15 Jun 2008 01:51:34 +0100
Message-ID: <20080615005133.GA2835@solarflare.com>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <20080501140625.GA9055@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:41727 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754193AbYFOAwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 20:52:49 -0400
Content-Disposition: inline
In-Reply-To: <20080501140625.GA9055@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, May 01, 2008 at 12:02:27PM +0100, Ben Hutchings wrote:
> >
> > My understanding is that at the points I'm adding the check, we're only
> > considering received skbs and gso_size will only be set if LRO was used.
> 
> Unfortunately that's not the case.  The forwarding path can and
> does occur for GSO packets sent from other guests.  The obvious
> case would be a GSO packet from a guest forwarded by the host
> (as opposed to bridged) to the outside world.

Can we distinguish them by testing skb->ip_summed == CHECKSUM_PARTIAL?
That is a requirement for using hardware segmentation offload (see
netif_needs_gso()) but an skb resulting from LRO should have ip_summed
set to either CHECKSUM_UNNECESSARY or CHECKSUM_NONE.

Alternately we could introduce some kind of status flag to say that a
device is bridging or forwarding, and have ethtool_op_set_flags()
block re-enabling of LRO when that's set.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
