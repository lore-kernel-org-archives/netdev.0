From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock after info soft-safe -> soft-unsafe lock order detected
Date: Wed, 07 Jan 2009 23:17:59 +1100
Message-ID: <E1LKXMF-0006fe-DK@gondolin.me.apana.org.au>
References: <20090105201811.00242be7.akpm@linux-foundation.org>
Cc: zdenek.kabelac@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, dada1@cosmosbay.com
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59059 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755453AbZAGMSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:18:07 -0500
In-Reply-To: <20090105201811.00242be7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> I'd be suspecting the percpu counter work in TCP?

This is the bogus lockdep output which is fixed by

commit ea319518ba3de282c13ae1cf4bf2215c5e03e67e
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Fri Dec 26 15:08:55 2008 +0100

    locking, percpu counters: introduce separate lock classes
    
    Impact: fix lockdep false positives
    
    Classify percpu_counter instances similar to regular lock objects --
    that is, per instantiation site.
    
    The networking code has increased its use of percpu_counters, which
    leads to false positives if they are treated as a single class.
    
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

It was only pulled very recently despite the Dec 26 date.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
