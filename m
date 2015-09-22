From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 23:18:55 +0800
Message-ID: <20150922151855.GA13218@gondor.apana.org.au>
References: <1442876618.29850.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, dvyukov@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442876618.29850.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> What I said is :
> 
> In @head you already have the correct nulls value, from hash table.
> 
> You do not need to recompute this value, and/or test if hash table chain
> is empty.
> 
> If hash bucket is empty, it contains the appropriate NULLS value.
> 
> If you are paranoiac add this debugging check :
> 
> if (rht_is_a_nulls(head))
>    BUG_ON(head != (struct rhash_head *)rht_marker(ht, new_hash));
> 
> 
> Therefore, simply fix the bug and unnecessary code with :

Ack.  I remember seeing this when I was working on it but never
got around to removing this bogosity.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
