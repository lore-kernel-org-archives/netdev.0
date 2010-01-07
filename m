From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] net: consolidate netif_needs_gso() checks
Date: Thu, 7 Jan 2010 16:07:21 +1100
Message-ID: <20100107050721.GA2282@gondor.apana.org.au>
References: <20100104102153.11639.48828.stgit@localhost.localdomain> <20100106.203423.58447620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44628 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932796Ab0AGFHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 00:07:31 -0500
Content-Disposition: inline
In-Reply-To: <20100106.203423.58447620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 08:34:23PM -0800, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Mon, 04 Jan 2010 10:21:53 +0000
> 
> > netif_needs_gso() is checked twice in the TX path once,
> > before submitting the skb to the qdisc and once after
> > it is dequeued from the qdisc just before calling
> > ndo_hard_start().  This opens a window for a user to
> > change the gso/tso or tx checksum settings that can
> > cause netif_needs_gso to be true in one check and false
> > in the other.
> > 
> > Specifically, changing TX checksum setting may cause
> > the warning in skb_gso_segment() to be triggered if
> > the checksum is calculated earlier.
> > 
> > This consolidates the netif_needs_gso() calls so that
> > the stack only checks if gso is needed after the skb
> > is dequeued from the qdisc.  Or if the device has no
> > queue then before dev_hard_start_xmit() in dev_queue_xmit().
> > 
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Herbert, please review.

Looks fine to me.  I have just one suggestion.  The queueless
case also calls dev_hard_start_xmit so we should be able to
remove the existing !need_gso code from dev_queue_xmit completely.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
