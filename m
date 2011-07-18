From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH 0/4] More work towards neigh-less dsts.
Date: Mon, 18 Jul 2011 10:11:28 +0100
Message-ID: <1310980288.2691.2.camel@menhir>
References: <20110718.012453.560423538801097033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015Ab1GRJJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 05:09:08 -0400
In-Reply-To: <20110718.012453.560423538801097033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2011-07-18 at 01:24 -0700, David Miller wrote:
> This continues the effort to divorce neighbour from dst_entry as
> much as possible.
> 
> When we remove the routing cache, route entries will be fully generic
> and not specific to any particular keyed destination.  Therefore we'll
> need to lookup neigh entries dynamically, and quickly, at packet
> output time.
> 
> To that end, this series:
> 
> 1) Passes an explicit neighbour to packet out neigh_ops.
> 
> 2) Abstracts all dst->neighbour behind helpers to ease the
>    transition process.
> 
> 3) Adds a new dst_ops entry, ->neigh_lookup(), to provide a transition
>    scheme for dst->neighbour uses outside of the packet output path.
> 
> The next set of patches after this one will deal with all of
> the dst_get_neighbour() code paths, converting them over to
> dst_neigh_lookup()/neigh_release() sequences.
> 
> Then there will be a little bit of fiddling around in decnet since
> it's usage of dst->neighbour is still too tight in the packet output
> path.
> 
I've not actually tested the decnet changes, but I've read through them
all and I think it looks good. Likewise the neigh simplification patch
set.

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

> Finally, we can kill dst->neighbour and do RCU neigh lookups in the
> packet output paths for all the protocols using the neighbour cache
> (ipv4, ipv6, decnet).
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


