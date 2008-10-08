From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing (resend)
Date: Wed, 8 Oct 2008 04:38:20 +0200
Message-ID: <20081008023820.GB6499@wotan.suse.de>
References: <20081007070225.GB5959@wotan.suse.de> <48EB11BB.2060704@cosmosbay.com> <20081007080656.GB16143@wotan.suse.de> <20081007.140509.48442086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, paulmck@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:36726 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbYJHCiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 22:38:21 -0400
Content-Disposition: inline
In-Reply-To: <20081007.140509.48442086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 02:05:09PM -0700, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Tue, 7 Oct 2008 10:06:56 +0200
> 
> > Hmm, that is interesting. What are the exact semantics of this rt_cache
> > file?
> 
> It dumps the whole set of elements in the routing cache hash table.

Right, so I guess importantly, it must not miss a route that remains in
the cache for the duration of the read(2)s. Obviously routes concurrently
entering and leaving the cache will not have any guarantees, including
causality (if we dump route A, we may still miss route B added before A).

Duplicates? I guess in a sense it could be possible to read route A, then
it gets deleted and reinserted? Oh, looking at the code it seems like
actually it is possible to miss entries anyway if they get moved to the
front of the chain while we're traversing it. Hmm, so if it just has "best
effort" kind of semantics, then we don't have to be too worried.
