From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] rhashtable: Add nested tables
Date: Tue, 7 Feb 2017 21:29:11 +0800
Message-ID: <20170207132911.GA14888@gondor.apana.org.au>
References: <20170207123827.GA14678@gondor.apana.org.au>
 <E1cb53h-0003qD-No@gondobar>
 <20170207131728.GA11584@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49623 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753522AbdBGN3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:29:37 -0500
Content-Disposition: inline
In-Reply-To: <20170207131728.GA11584@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 02:17:28PM +0100, Florian Westphal wrote:
>
> Ok, but why?

Because people expect the hash table insertion to succeed, even
on softirq paths where you cannot vmalloc.

> It seems to add a whole lot of complexity...
> 
> What users can't handle the insert failure case until resize
> has completed?

Users that need to insert on softirq that cannot throttle the
rate.

> Would relaxing the max chain length (until rehash is done) be an
> alternative?

Considering that this is intended for users that cannot throttle
the rate of insertion, I think we'd be much better off just failing
them than sticking them on what will essentially be a linked list.

As people don't like insertion failure, I think this level of
complexity is justified.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
