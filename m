From: David Miller <davem@davemloft.net>
Subject: Re: Time to revisit LISP?
Date: Thu, 03 Nov 2016 16:37:58 -0400 (EDT)
Message-ID: <20161103.163758.1592587767905993803.davem@davemloft.net>
References: <CALx6S35cT6gn4W6iiaL5sAgTm=jJPZpyVP3pyGXfbyHHsKaciQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris@logicalelegance.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbcKCUiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:38:00 -0400
In-Reply-To: <CALx6S35cT6gn4W6iiaL5sAgTm=jJPZpyVP3pyGXfbyHHsKaciQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 3 Nov 2016 12:22:52 -0700

> For instance, one of the his questions is:
> 
> "What is to keep one from having to service a full Map-Request -->
> Map-Reply cycle for every packet received?"
> 
> This can be solved by judicious rate limiting, for instance the
> infrastructure I implemented to rate limit ILA resolver request could
> be applied here.

All of these things work great if you have tables that are either very
tiny or change infrequently.

But once you run into anything seriously dynamic, it has the same
problems that the routing cache had and OVS can have.

And for this reason things like the flow cache are on the chopping
block.  And frankly, I'd remove OVS from the kernel if I could.

Userspace resolution of paths in response to data path signalling
simply does not scale and is fundamentally an extremely poor design
choice.  We're trying to move away from, rather than towards, these
kinds of architectures.
