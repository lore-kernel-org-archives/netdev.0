From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Mon, 7 Apr 2014 22:23:34 +0800
Message-ID: <20140407142334.GA28814@gondor.apana.org.au>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
 <1396879662.12330.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33156 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760AbaDGOXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 10:23:37 -0400
Content-Disposition: inline
In-Reply-To: <1396879662.12330.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 07, 2014 at 07:07:42AM -0700, Eric Dumazet wrote:
>
> I suppose its a net-next material ?

Oh yes absolutely.

> Memory allocations (one incoming message -> ~4096 duplications) probably
> should use GFP_KERNEL. This might need a change from rcu to simple mutex
> for macvlan_broadcast() scan of all macvlans.

Good point.  However, as this change will be non-trivial we can
do this as a follow-up.

> cond_resched() could help macvlan_process_broadcast() to not hog cpu.
> 
> Anyway, 4.000 incoming messages are duplicated into 16.000.000 messages,
> it takes half a minute to process on a single cpu. You might need
> multiple workqueue to split the load on all online cpus ;)

You're welcome to add further improvements :)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
