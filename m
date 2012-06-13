From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix netpoll_send_udp() bugs
Date: Wed, 13 Jun 2012 07:18:54 -0400
Message-ID: <20120613111854.GA14339@hmsreliant.think-freely.org>
References: <1339565421.22704.310.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Bogdan Hamciuc <bogdan.hamciuc@freescale.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58032 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558Ab2FMLTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 07:19:09 -0400
Content-Disposition: inline
In-Reply-To: <1339565421.22704.310.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 07:30:21AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Bogdan Hamciuc diagnosed and fixed following bug in netpoll_send_udp() :
> 
> "skb->len += len;" instead of "skb_put(skb, len);"
> 
> Meaning that _if_ a network driver needs to call skb_realloc_headroom(),
> only packet headers would be copied, leaving garbage in the payload.
> 
> However the skb_realloc_headroom() must be avoided as much as possible
> since it requires memory and netpoll tries hard to work even if memory
> is exhausted (using a pool of preallocated skbs)
> 
> It appears netpoll_send_udp() reserved 16 bytes for the ethernet header,
> which happens to work for typicall drivers but not all.
> 
> Right thing is to use LL_RESERVED_SPACE(dev)
> (And also add dev->needed_tailroom of tailroom)
> 
> This patch combines both fixes.
> 
> Many thanks to Bogdan for raising this issue.
> 
> Reported-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Neil Horman <nhorman@tuxdriver.com>
Reviewed-by: Neil Horman <nhorman@tuxdriver.com>

> 
