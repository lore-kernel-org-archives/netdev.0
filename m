From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 15:20:59 +1000
Message-ID: <20100520052059.GC7443@gondor.apana.org.au>
References: <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:60764 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752630Ab0ETFVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 01:21:19 -0400
Content-Disposition: inline
In-Reply-To: <1274332507.2658.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 07:15:07AM +0200, Eric Dumazet wrote:
> 
> I find this very biased, sorry.
> 
> In fact, fd passing is just fine today, if we consider that we classify
> packets using the identity of the process *using* the fd, not the one
> that *created* it.
> 
> Now your patch changes this, to the reverse, and you justify the caching
> effect on socket. Sorry, this must be too convoluted for me.

I'm sorry you find this convoluted, but using the sending process's
classid is inherently broken.

Here is why: consider a TCP socket shared by two processes with
different classids both writing data to it.  Now suppose further
that each writes just one byte, which is then coalesced into a
single skb.

Whose classid should we use on the resulting skb?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
