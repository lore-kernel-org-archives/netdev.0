From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 3/3] rhashtable: Add nested tables
Date: Tue, 7 Feb 2017 14:17:28 +0100
Message-ID: <20170207131728.GA11584@breakpoint.cc>
References: <20170207123827.GA14678@gondor.apana.org.au>
 <E1cb53h-0003qD-No@gondobar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56466 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753378AbdBGNS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:18:27 -0500
Content-Disposition: inline
In-Reply-To: <E1cb53h-0003qD-No@gondobar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> This patch adds code that handles GFP_ATOMIC kmalloc failure on
> insertion.  As we cannot use vmalloc, we solve it by making our
> hash table nested.  That is, we allocate single pages at each level
> and reach our desired table size by nesting them.
> 
> When a nested table is created, only a single page is allocated
> at the top-level.  Lower levels are allocated on demand during
> insertion.  Therefore for each insertion to succeed, only two
> (non-consecutive) pages are needed.
> 
> After a nested table is created, a rehash will be scheduled in
> order to switch to a vmalloced table as soon as possible.  Also,
> the rehash code will never rehash into a nested table.  If we
> detect a nested table during a rehash, the rehash will be aborted
> and a new rehash will be scheduled.

Ok, but why?

It seems to add a whole lot of complexity...

What users can't handle the insert failure case until resize
has completed?

Would relaxing the max chain length (until rehash is done) be an
alternative?
