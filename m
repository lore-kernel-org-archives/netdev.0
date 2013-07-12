From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v3] ipv6: only static routes qualify for equal cost
 multipathing
Date: Fri, 12 Jul 2013 16:30:53 -0700 (PDT)
Message-ID: <20130712.163053.1149528998452445963.davem@redhat.com>
References: <20130712214633.GQ12611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351Ab3GLXa7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 19:30:59 -0400
In-Reply-To: <20130712214633.GQ12611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 12 Jul 2013 23:46:33 +0200

> Static routes in this case are non-expiring routes which did not get
> configured by autoconf or by icmpv6 redirects.
> 
> To make sure we actually get an ecmp route while searching for the first
> one in this fib6_node's leafs, also make sure it matches the ecmp route
> assumptions.
> 
> v2:
> a) Removed RTF_EXPIRE check in dst.from chain. The check of RTF_ADDRCONF
>    already ensures that this route, even if added again without
>    RTF_EXPIRES (in case of a RA announcement with infinite timeout),
>    does not cause the rt6i_nsiblings logic to go wrong if a later RA
>    updates the expiration time later.
> 
> v3:
> a) Allow RTF_EXPIRES routes to enter the ecmp route set. We have to do so,
>    because an pmtu event could update the RTF_EXPIRES flag and we would
>    not count this route, if another route joins this set. We now filter
>    only for RTF_GATEWAY|RTF_ADDRCONF|RTF_DYNAMIC, which are flags that
>    don't get changed after rt6_info construction.
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
