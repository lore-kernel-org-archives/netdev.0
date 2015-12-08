From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2 2/5] rhashtable: add function to replace an
 element
Date: Tue, 8 Dec 2015 17:39:41 +0800
Message-ID: <20151208093941.GA17795@gondor.apana.org.au>
References: <20151203.144558.1956397517705186998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34216 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933266AbbLHJkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 04:40:18 -0500
Content-Disposition: inline
In-Reply-To: <20151203.144558.1956397517705186998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 1 Dec 2015 15:11:09 -0800
> 
>> +     lock = rht_bucket_lock(tbl, hash);
>> +
>> +     spin_lock_bh(lock);
>> +
>> +     pprev = &tbl->buckets[hash];
>> +     rht_for_each(he, tbl, hash) {
>> +             if (he != obj_old) {
>> +                     pprev = &he->next;
>> +                     continue;
>> +             }
>> +
>> +             rcu_assign_pointer(obj_new->next, obj_old->next);
>> +             rcu_assign_pointer(*pprev, obj_new);
>> +             err = 0;
>> +             break;
> 
> Are you sure this works fine in the presence of both parallel readers and
> table expansion passes?

Good question.

What's more this is something that can be easily implemented
outside of rhashtable, i.e., by hashing a pointer to the actual
object rather than the object itself.  So I'd like to see some
pretty good reasons for penny-pinching on memory and adding more
complexity to rhashtable.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
