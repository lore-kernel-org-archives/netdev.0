From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Fri, 19 Apr 2013 21:44:24 +0200
Message-ID: <20130419194424.GI27889@order.stressinduktion.org>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213732.14296.36026.stgit@dragon> <1366366287.3205.98.camel@edumazet-glaptop> <1366373950.26911.134.camel@localhost> <20130419124528.GF27889@order.stressinduktion.org> <1366381742.26911.166.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52982 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab3DSToZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 15:44:25 -0400
Content-Disposition: inline
In-Reply-To: <1366381742.26911.166.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 04:29:02PM +0200, Jesper Dangaard Brouer wrote:
> Well, I don't know.  But we do need some solution, to the current code.

In <http://article.gmane.org/gmane.linux.network/261361> I said that we could
actually have a list lengt of about 370. At this time this number was stable,
perhaps you could verify?

I tried to flood the cache with very minimal packets so this was actually
the hint that I should have resized the hash back then. With the current
fragmentation cache design we could reach optimal behaviour as soon
as the memory limits kicks in and lru eviction starts before we limit the
fragments queues in the hash chains. The only way to achieve this is to
increase the hash table slots and lower the maximum length limit. I would
propose a limit of about 25-32 and as Eric said, a hash size of 1024. We could
test if we are limited of accepting new fragments by memory limit (which would
be fine because lru eviction kicks in) or by chain length (we could recheck
the numbers then).

So the chain limit would only kick in if someone tries to exploit the fragment
cache by using the method I demonstrated before (which was the reason I
introduced this limit).

Thanks,

  Hannes
