From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 2/2] net: ip, ipv6: handle gso skbs in forwarding
 path
Date: Thu, 13 Feb 2014 17:17:57 -0500 (EST)
Message-ID: <20140213.171757.1460052863443832827.davem@davemloft.net>
References: <1392329352-31606-1-git-send-email-fw@strlen.de>
	<1392329352-31606-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaBMWR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:17:58 -0500
In-Reply-To: <1392329352-31606-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 13 Feb 2014 23:09:12 +0100

> Marcelo Ricardo Leitner reported problems when the forwarding link path
> has a lower mtu than the incoming one if the inbound interface supports GRO.
 ...
> However it turns out that skb_segment() assumes skb nr_frags is related
> to mss size so we would BUG there.  I don't want to mess with it considering
> Herbert and Eric disagree on what the correct behavior should be.
> 
> Hannes Frederic Sowa notes that when we would shrink gso_size
> skb_segment would then also need to deal with the case where
> SKB_MAX_FRAGS would be exceeded.
> 
> This uses sofware segmentation in the forward path when we hit ipv4
> non-DF packets and the outgoing link mtu is too small.  Its not perfect,
> but given the lack of bug reports wrt. GRO fwd being broken this is a
> rare case anyway.  Also its not like this could not be improved later
> once the dust settles.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Reported-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Also applied and queued up for -stable, thanks.
