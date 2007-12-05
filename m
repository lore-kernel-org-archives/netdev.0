From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [UDP]: Only increment counter on first peek/recv
Date: Wed, 05 Dec 2007 01:54:09 -0800 (PST)
Message-ID: <20071205.015409.116581624.davem@davemloft.net>
References: <20071204125844.GA2750@gondor.apana.org.au>
	<20071204130109.GA3098@gondor.apana.org.au>
	<20071204130310.GB3098@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751071AbXLEJyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:54:10 -0500
In-Reply-To: <20071204130310.GB3098@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Dec 2007 00:03:10 +1100

> [UDP]: Only increment counter on first peek/recv
> 
> The previous move of the the UDP inDatagrams counter caused each
> peek of the same packet to be counted separately.  This may be
> undesirable.
> 
> This patch fixes this by adding a bit to sk_buff to record whether
> this packet has already been seen through skb_recv_datagram.  We
> then only increment the counter when the packet is seen for the
> first time.
> 
> The only dodgy part is the fact that skb_recv_datagram doesn't have
> a good way of returning this new bit of information.  So I've added
> a new function __skb_recv_datagram that does return this and made
> skb_recv_datagram a wrapper around it.
> 
> The plan is to eventually replace all uses of skb_recv_datagram with
> this new function at which time it can be renamed its proper name.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks for fixing all of this Herbert.
