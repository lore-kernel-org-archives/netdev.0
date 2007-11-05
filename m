From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dn_route.c momentarily exiting RCU read-side critical section
Date: Mon, 05 Nov 2007 19:53:04 +0800
Message-ID: <E1Ip0Vs-0002zP-00@gondolin.me.apana.org.au>
References: <20071030151254.GA8285@linux.vnet.ibm.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, SteveW@acm.org, dipankar@in.ibm.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3134 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750887AbXKELyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 06:54:09 -0500
In-Reply-To: <20071030151254.GA8285@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>> 
>> > net/decnet/dn_route.c in dn_rt_cache_get_next() is as follows:
>> > 
>> > static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_route *rt)
>> > {
>> >     struct dn_rt_cache_iter_state *s = rcu_dereference(seq->private);
>> > 
>> >     rt = rt->u.dst.dn_next;
>> >     while(!rt) {
>> >             rcu_read_unlock_bh();
>> >             if (--s->bucket < 0)
>> >                     break;
>
> OK, for my next stupid question: why is the rcu_dereference(seq->private)
> required, as opposed to simply seq->private?

It was put there by someone who went through the code converting
all occurances of smp_read_barrier_depends to rcu_dereference.
In this instance the rcu_dereference conversion doesn't make much
sense so we should probably just revert it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
