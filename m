From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 13:14:48 -0700 (PDT)
Message-ID: <20100519.131448.200085502.davem@davemloft.net>
References: <20100519075721.GA23926@gondor.apana.org.au>
	<1274256582.2766.5.camel@edumazet-laptop>
	<20100519082047.GA24331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752895Ab0ESUOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 16:14:39 -0400
In-Reply-To: <20100519082047.GA24331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 19 May 2010 18:20:47 +1000

> On Wed, May 19, 2010 at 10:09:42AM +0200, Eric Dumazet wrote:
>> 
>> 6) netif_rx() pro is that packet processing is done while stack usage is
>> guaranteed to be low (from process_backlog, using a special softirq
>> stack, instead of current stack)
>> 
>> After your patch, tun will use more stack. Is it safe on all contexts ?
> 
> Dave also raised this but I believe nothing changes with regards
> to the stack.  We currently call do_softirq which does not switch
> stacks.

do_softirq() _does_ switch stacks, it's a per-arch function that
does the stack switch and calls __do_softirq() on the softirq
stack.
