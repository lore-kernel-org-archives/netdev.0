From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [PPP] pppoe: Fix data clobbering in __pppoe_xmit
 and return value
Date: Sun, 16 Sep 2007 16:20:04 -0700 (PDT)
Message-ID: <20070916.162004.18302485.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2Uy-0007Ms-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753721AbXIPXUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:20:04 -0400
In-Reply-To: <E1IR2Uy-0007Ms-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:09:04 +0800

> [PPP] pppoe: Fix data clobbering in __pppoe_xmit and return value
> 
> The function __pppoe_xmit modifies the skb data and therefore it needs
> to copy and skb data if it's cloned.
> 
> In fact, it currently allocates a new skb so that it can return 0 in
> case of error without freeing the original skb.  This is totally wrong
> because returning zero is meant to indicate congestion whereupon pppoe
> is supposed to wake up the upper layer once the congestion subsides.
> 
> This makes sense for ppp_async and ppp_sync but is out-of-place for
> pppoe.  This patch makes it always return 1 and free the skb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
