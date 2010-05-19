From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 18:20:47 +1000
Message-ID: <20100519082047.GA24331@gondor.apana.org.au>
References: <20100519075721.GA23926@gondor.apana.org.au> <1274256582.2766.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48481 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751568Ab0ESIUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 04:20:54 -0400
Content-Disposition: inline
In-Reply-To: <1274256582.2766.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 10:09:42AM +0200, Eric Dumazet wrote:
> 
> 6) netif_rx() pro is that packet processing is done while stack usage is
> guaranteed to be low (from process_backlog, using a special softirq
> stack, instead of current stack)
> 
> After your patch, tun will use more stack. Is it safe on all contexts ?

Dave also raised this but I believe nothing changes with regards
to the stack.  We currently call do_softirq which does not switch
stacks.

Only a real interrupt would switch stacks.

> Another concern I have is about RPS.
> 
> netif_receive_skb() must be called from process_backlog() context, or
> there is no guarantee the IPI will be sent if this skb is enqueued for
> another cpu.

Can you explain this a bit more?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
