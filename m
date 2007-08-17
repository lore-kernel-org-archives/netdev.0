From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable and friendly ?
Date: Fri, 17 Aug 2007 16:15:22 +0800
Message-ID: <20070817081522.GA16720@gondor.apana.org.au>
References: <20070816153619.2c699e21.dada1@cosmosbay.com> <E1ILft1-0001Db-00@gondolin.me.apana.org.au> <20070816174044.43c90ff4.dada1@cosmosbay.com> <20070816233339.GA11594@gondor.apana.org.au> <20070817101030.cc64467a.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3882 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750796AbXHQIPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 04:15:30 -0400
Content-Disposition: inline
In-Reply-To: <20070817101030.cc64467a.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2007 at 10:10:30AM +0200, Eric Dumazet wrote:
>
> Will a workqueue react the same in case of a DDOS situation, 
> where softirq could use all CPU cycles to handle incoming
> packets and feed the GC list, and GC would never
> have a chance to scan and free some items ?

Well when that happens the softirqs will be deferred to
ksoftirqd which should share the CPU fairly with the
workqueue.

> About chunk processing, I did it on purpose, to not throw away
> all CPU cache. Goal is to process entries, but not all of them
> in a row, especially if we find many yet referenced entries
> (and thus not candidates to freeing)

I agree that chunks are desirable for a timer since you'd
be hogging the CPU otherwise.  However, if you went to a
workqueue then it's less of a concern and would simplify
things.  In particular, you won't have to pick a good
chunk size :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
