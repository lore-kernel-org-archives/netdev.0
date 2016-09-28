From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] ipsec: flow cache removal
Date: Tue, 27 Sep 2016 22:15:01 -0400 (EDT)
Message-ID: <20160927.221501.123624802268529925.davem@davemloft.net>
References: <1474992323-11327-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55978 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755279AbcI1CPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 22:15:03 -0400
In-Reply-To: <1474992323-11327-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 27 Sep 2016 18:05:20 +0200

> Please do not apply these patches.

To be honest, I really want to :-)

> These are part of tests I made for the ipsec workshop at upcoming
> netdev 1.2 and I wanted to post these before the conference.
> 
> Short version is that there appear to be no major scalability issues
> anymore without flow cache.  Performance hit can be up to 30%
> in my tests (with 64 byte packets), however without flow cache we
> also avoid some undesirable effects when flow cache is constantly
> overloaded.
> 
> Seems most of the extra cost is mainly because of extra xfrm dst
> init/destruction (and not e.g. due to policy lookup).

Yes, if you have to allocate/destroy a dst every lookup then
it will hurt a lot.  Perhaps we can have a pre-cooked dst hung
off of some existing object as a first level strategy to avoid
this.

> Lets discuss more at the workshop.

Indeed.
