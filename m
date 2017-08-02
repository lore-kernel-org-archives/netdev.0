From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] net: l3mdev: Support for sockets bound
 to enslaved device
Date: Tue, 01 Aug 2017 17:41:59 -0700 (PDT)
Message-ID: <20170801.174159.2041906157460737035.davem@davemloft.net>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdHBAmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 20:42:02 -0400
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 31 Jul 2017 20:13:16 -0700

> Existing code for socket lookups already pass in 6+ arguments. Rather
> than add another for the enslaved device index, the existing lookups
> are converted to use a new sk_lookup struct. From there, the enslaved
> device index becomes another element of the struct.

Sorry, not gonna happen :-)

I know it's difficult, but maybe we should think about why we're
passing so much crap into each lookup.

And perhaps, why it can't (for example) be constituted in the lookup
function itself given sufficient (relevant) context.

I think passing a big struct into the lookups, by reference, is a big
step backwards.

For one thing, if you pass it by pointer then the compiler can't
potentially pass parts in registers even if it could.  However
if you pass it by value, that's actually a possibility.

But I'd like to avoid this on-stack blob altogether if possible.

Thanks.
