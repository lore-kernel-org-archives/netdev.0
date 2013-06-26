From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 26 Jun 2013 15:07:48 +0200
Message-ID: <20130626130748.GC20081@order.stressinduktion.org>
References: <1364865839.5113.165.camel@edumazet-glaptop> <20130417010213.GA9027@redhat.com> <1366164132.3205.21.camel@edumazet-glaptop> <20130417141138.GA17648@redhat.com> <1366208856.3205.23.camel@edumazet-glaptop> <1366214751.3205.29.camel@edumazet-glaptop> <20130625212851.GA20081@order.stressinduktion.org> <1372238557.3301.145.camel@edumazet-glaptop> <1372238996.3301.149.camel@edumazet-glaptop> <1372245307.3301.171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39007 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab3FZNHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 09:07:49 -0400
Content-Disposition: inline
In-Reply-To: <1372245307.3301.171.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 04:15:07AM -0700, Eric Dumazet wrote:
> Following patch fixes the problem for me :

Cool, thanks Eric!

> [PATCH] ipv6: ip6_sk_dst_check() must not assume ipv6 dst
> 
> It's possible to use AF_INET6 sockets and to connect to an IPv4
> destination. After this, socket dst cache is a pointer to a rtable,
> not rt6_info.

That was my hunch, too. I was unsure where we should destroy the lingering dst.

> ip6_sk_dst_check() should check the socket dst cache is IPv6, or else
> various corruptions/crashes can happen.
> 
> Dave Jones can reproduce immediate crash with 
> trinity -q -l off -n -c sendmsg -c connect
> 
> With help from Hannes Frederic Sowa
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Patch looks good. It also fixes some panics I have seen down lower in
the netfilter ipv6 code I saw while testing, which I thought may be a
different issue.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
