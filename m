From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] rhashtable: Add nested tables
Date: Wed, 8 Feb 2017 09:09:33 +0800
Message-ID: <20170208010933.GA15623@gondor.apana.org.au>
References: <20170207123827.GA14678@gondor.apana.org.au>
 <E1cb53h-0003qD-No@gondobar>
 <20170207131728.GA11584@breakpoint.cc>
 <20170207132911.GA14888@gondor.apana.org.au>
 <20170207180216.GC11584@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49905 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753576AbdBHBJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 20:09:53 -0500
Content-Disposition: inline
In-Reply-To: <20170207180216.GC11584@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 07:02:16PM +0100, Florian Westphal wrote:
>
> I can't really say anything here because *I* don't expect
> it to succeed.

Think about incoming TCP connections, you can't rate-limit that
without defeating yourself.

> Even with this proposed patch things will eventually fail
> on OOM conditions.

Exactly.  That's the only case where it should fail.  Previously
it would fail if we cannot allocate a large number of consecutive
pages, which can happen even if you have lots of memory left.  With
my patch it will only fail if it cannot allocate at most two non-
consecutive pages, i.e., a real OOM.

> Also, such period should be very short until rht has reached
> peak size for the workload.

How would you know? The rate of insertions could be extremely
high.
 
> Also, given that we could easily oversubscribe a table by a factor
> of 10 or more while still keeping sane chain lengths I don't
> see why thats a problem (also, a 'rht_insert_force' or similar
> interface that doesn't do chain length checks makes it
> easy to spot places that need/want this behaviour).

But you would still have to impose a limit, whether it's 1 or
10.  IOW you will still fail insertions at some point even though
you have sufficient memory to perform the insertion.
 
> (insecure_elasticity and/or insecure_max_entries come to mind, seems
>  some of that might not even be needed anymore but I don't have time
>  right now to investigate).

Yes insecure_elasticity is now obsolete and anyone using it should
switch over to rhlist.  Once nobody uses it then it can be removed.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
