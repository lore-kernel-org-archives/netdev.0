From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: rt_check_expire() can take a long time, add a cond_resched()
Date: Sat, 17 Nov 2007 23:21:39 +0800
Message-ID: <E1ItPUJ-0005Ue-00@gondolin.me.apana.org.au>
References: <p73k5ohav4n.fsf@bingen.suse.de>
Cc: arjan@infradead.org, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vget.kernel.org, mingo@elte.hu
To: andi@firstfloor.org (Andi Kleen)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759222AbXKQPXN@vger.kernel.org>
In-Reply-To: <p73k5ohav4n.fsf@bingen.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> wrote:
>
>>> > With the extra check (and *much* less function calls), each run
>>> > takes 25ms
> 
> ms?!? The numbers sound wrong. Wrong unit? 

That's quite possible with a huge routing cache.  I think that's
the reason Eric is doing this in the first place.

>> however... this is likely a good argument for making cond_resched() as a
>> whole a #define (or inline) that does this test and then calls the out
>> of line code (which then doesn't need to retest, so it avoids the
>> double test)...
> 
> Disadvantage would be that might_sleep would be commonly skipped then
> (unless you actually need to reschedule) 
> But perhaps that's not a big issue.

On a related note, would it be possible for cond_resched() to
be compiled out completely if we're doing real preemption as
opposed to voluntary preemption?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
