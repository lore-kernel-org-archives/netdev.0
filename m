From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_lookup lockdep bug.
Date: Tue, 01 Aug 2006 23:19:43 +1000
Message-ID: <E1G7u9v-0001mL-00@gondolin.me.apana.org.au>
References: <1154437278.3113.0.camel@laptopd505.fenrus.org>
Cc: davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4883 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751192AbWHANUD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 09:20:03 -0400
To: arjan@infradead.org (Arjan van de Ven)
In-Reply-To: <1154437278.3113.0.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@infradead.org> wrote:
> 
> we fixed lockdep to have this lock key to be per skb queue ... didn't
> you put that patch in rawhide Dave (J) ?

I've only briefly looked at the lockdep_set_class code so I might be
way off here.

It seems that for lockdep_set_class to work its second argument should
be distinct for each class of locks that you wish to distinguish.  So
shouldn't we be putting the key into struct sk_buff_head rather than
having one key (skb_queue_lock_key) for all sk_buff_head's?

Cheers
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
