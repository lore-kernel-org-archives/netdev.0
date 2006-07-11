From: David Miller <davem@davemloft.net>
Subject: Re: [IPCOMP]: Fix truesize after decompression
Date: Tue, 11 Jul 2006 16:22:17 -0700 (PDT)
Message-ID: <20060711.162217.101672676.davem@davemloft.net>
References: <20060711114544.GA11396@gondor.apana.org.au>
	<20060711.135553.106801039.davem@davemloft.net>
	<20060711231251.GA6725@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Daniel.Beschorner@facton.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32973
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932230AbWGKXVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 19:21:32 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060711231251.GA6725@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Jul 2006 09:12:51 +1000

> On Tue, Jul 11, 2006 at 01:55:53PM -0700, David Miller wrote:
> > 
> > I think it is possible cover a certain class of these situations
> > from within pskb_expand_head.  For example, if skb->sk is NULL
> > we can prove that updating skb->truesize is safe since no
> > socket's buffer accounting can possible depend upon the truesize
> > value of this skb.
> 
> Yes that's certainly possible.  However, we'll need to audit the few
> spots (e.g., ATM) that use truesize without setting skb->sk.

Yuck, I'd forgotten about that usage....

What ATM is doing here is charging the SKB to the virtual circuit
sockets.  At least in the few cases I've looked at just now, the
skb is some private ATM level signalling message, and not part of
a normal transmit/receive packet from the normal networking stack.

Therefore, there seems to be no reason why ATM can't use the
destructor callback of the SKB to manage this accounting just like the
rest of the kernel does.
