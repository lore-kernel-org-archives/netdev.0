From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/7] flow: allocate hash table for online cpus only
Date: Wed, 31 Mar 2010 23:02:51 +1030
Message-ID: <201003312302.51683.rusty@rustcorp.com.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-4-git-send-email-timo.teras@iki.fi> <20100330121255.GC5731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36942 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932875Ab0CaMcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 08:32:55 -0400
In-Reply-To: <20100330121255.GC5731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 10:42:55 pm Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 05:12:40PM +0300, Timo Teras wrote:
> > Instead of unconditionally allocating hash table for all possible
> > cpu's, allocate it only for online cpu's and release related
> > memory if cpu goes down.
> > 
> > Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> Hmm that's where we started but then Rusty changed it back in 2004:
> 
> commit 0a32dc4d8e83c48f7535d66731eb35d1916b39a8
> Author: Rusty Russell <rusty@rustcorp.com.au>
> Date:   Wed Jan 21 18:14:37 2004 -0800
> 
>     [NET]: Simplify net/flow.c per-cpu handling.
> 
>     The cpu handling in net/core/flow.c is complex: it tries to allocate
>     flow cache as each CPU comes up.  It might as well allocate them for
>     each possible CPU at boot.
> 
> So I'd like to hear his opinion on changing it back again.

It was pretty unique at the time, it no longer is, so the arguments are less
compelling IMHO.

However, we can now use a dynamic percpu variable and get it as a real
per-cpu thing (which currently means it *will* be for every available cpu,
not just online ones).  Haven't thought about it, but that change might be
worth considering instead?

Thanks!
Rusty.
