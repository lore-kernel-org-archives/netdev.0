From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Tue, 23 Apr 2013 11:30:41 +0800
Message-ID: <1366687841.21136.6.camel@cr0>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
	 <20130422.160834.1941810644323096368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754190Ab3DWDay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 23:30:54 -0400
In-Reply-To: <20130422.160834.1941810644323096368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 16:08 -0400, David Miller wrote:
> This is broken.  Every time I see someone export new things from IPV6
> and then try to use those symbols in some other unrelated module, it
> is a huge red flag.
> 
> You can't call into IPV6 protected symbols unless VXLAN and IPV6 are
> configured identically.
> 
> So with your changes, with VXLAN=y and IPV6=m, you'll get link errors.
> I could see this just by looking at your patch, I didn't have to even
> try to build it.

Yeah, the IPv6 multicast API's we export indeed have such problem.

> 
> Please do not fix this by adding Kconfig dependencies, you have to
> find another way.  In bonding and bridging, we've made it such that
> you can configure them in any combination whatsoever with ipv6 and
> everything works properly.  Most of them time this can be accomplished
> by moving things into the explicit "obj-y" objects in
> net/ipv6/Makefile

One quick solution is just linking mcast.o statically, because it is not
easy to separate core functions from mcast.c like addrconf_core.c.

> 
> If you are adding stateful dependencies upon ipv6 (you want to inspect
> the ipv6 routes or something like that), I'm sorry but I really don't
> want any hard dependies on ipv6's internal state, we can't export that
> properly.

I don't think we need that.

Thanks!
