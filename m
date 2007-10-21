From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 9189] New: Oops in kernel 2.6.21-rc4 through 2.6.23, page
 allocation failure
Date: Sun, 21 Oct 2007 16:28:13 -0700 (PDT)
Message-ID: <20071021.162813.15428054.davem@davemloft.net>
References: <4718C651.5040804@psc.edu>
	<E1IiuGl-000482-00@gondolin.me.apana.org.au>
	<20071021045601.GA8427@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbXJUX2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:28:00 -0400
In-Reply-To: <20071021045601.GA8427@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 21 Oct 2007 12:56:01 +0800

> [NET]: Fix SKB_WITH_OVERHEAD calculation
> 
> The calculation in SKB_WITH_OVERHEAD is incorrect in that it can cause
> an overflow across a page boundary which is what it's meant to prevent.
> In particular, the header length (X) should not be lumped together with
> skb_shared_info.  The latter needs to be aligned properly while the header
> has no choice but to sit in front of wherever the payload is.
> 
> Therefore the correct calculation is to take away the aligned size of
> skb_shared_info, and then subtract the header length.  The resulting
> quantity L satisfies the following inequality:
> 
> 	SKB_DATA_ALIGN(L + X) + sizeof(struct skb_shared_info) <= PAGE_SIZE
> 
> This is the quantity used by alloc_skb to do the actual allocation.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, I'll push this to -stable too, thanks!
