From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.17-mm3 -- BUG: illegal lock usage -- illegal {softirq-on-W} -> {in-softirq-R} usage.
Date: Fri, 30 Jun 2006 12:57:32 +1000
Message-ID: <E1Fw9CG-0007e6-00@gondolin.me.apana.org.au>
References: <20060629125640.d828a0b3.akpm@osdl.org>
Cc: arjan@infradead.org, miles.lane@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:37894 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S964931AbWF3C7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 22:59:46 -0400
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20060629125640.d828a0b3.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
>> >     inet_bind()
>> >     ->sk_dst_get
>> >       ->read_lock(&sk->sk_dst_lock)

We are still holding the sock lock when doing sk_dst_get.

>> > > 1 lock held by java_vm/4418:
>> > >  #0:  (af_family_keys + (sk)->sk_family#4){-+..}, at: [<f93c9281>]
>> > > tcp_v6_rcv+0x308/0x7b7 [ipv6]
>> > 
>> >     softirq
>> >     ->ip6_dst_lookup
>> >       ->sk_dst_check
>> >         ->sk_dst_reset
>> >           ->write_lock(&sk->sk_dst_lock);

The sock lock prevents this path from being entered.  Instead the
received TCP packet is queued and replayed when the sock lock is
released.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
