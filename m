From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 2/5] rhashtable: add function to replace an element
Date: Tue, 8 Dec 2015 09:14:24 -0800
Message-ID: <CALx6S35sG4+5UT87Yrwa1a=O-Mq09SucXw7=xyxnrJVwXY6fkw@mail.gmail.com>
References: <20151203.144558.1956397517705186998.davem@davemloft.net>
	<20151208093941.GA17795@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36404 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbLHROZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:14:25 -0500
Received: by igcph11 with SMTP id ph11so100157788igc.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 09:14:24 -0800 (PST)
In-Reply-To: <20151208093941.GA17795@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 1:39 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Tue, 1 Dec 2015 15:11:09 -0800
>>
>>> +     lock = rht_bucket_lock(tbl, hash);
>>> +
>>> +     spin_lock_bh(lock);
>>> +
>>> +     pprev = &tbl->buckets[hash];
>>> +     rht_for_each(he, tbl, hash) {
>>> +             if (he != obj_old) {
>>> +                     pprev = &he->next;
>>> +                     continue;
>>> +             }
>>> +
>>> +             rcu_assign_pointer(obj_new->next, obj_old->next);
>>> +             rcu_assign_pointer(*pprev, obj_new);
>>> +             err = 0;
>>> +             break;
>>
>> Are you sure this works fine in the presence of both parallel readers and
>> table expansion passes?
>
> Good question.
>
> What's more this is something that can be easily implemented
> outside of rhashtable, i.e., by hashing a pointer to the actual
> object rather than the object itself.  So I'd like to see some
> pretty good reasons for penny-pinching on memory and adding more
> complexity to rhashtable.

That creates one more level of indirection. I don't see how add an
atomic replace operation adds any complexity to the rhashtable, none
of the semantics for rhashtable need to be changed.

>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
