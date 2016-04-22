From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Fri, 22 Apr 2016 11:13:28 +0200
Message-ID: <20160422091328.GK3347@gauss.secunet.com>
References: <20160421074042.GF3347@gauss.secunet.com>
 <1461243546.7627.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38521 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754124AbcDVJNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:13:32 -0400
Content-Disposition: inline
In-Reply-To: <1461243546.7627.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 05:59:06AM -0700, Eric Dumazet wrote:
> On Thu, 2016-04-21 at 09:40 +0200, Steffen Klassert wrote:
> > 
> > Hi Eric, this is a followup on our discussion at the netdev
> > conference. Would you still be ok with this revert, or do
> > you think there is a better solution in sight?
> 
> Note that some GRO enabled drivers would still generate frag_list.
> 
> (This happens if they are using skb with some TCP payload in skb->head
> and skb->head was allocated with kmalloc())
> 
> We have sysctl_max_skb_frags sysctl, we might have a sysctl
> enabling/disabling GRO from building any frag_list.
> Or simply reuse an existing one, like /proc/sys/net/ipv4/ip_forward ?)

Reusing the ipv4/ipv6 forwarding sysctls would be probably the
simplest solution, but maybe we can do the partial split in
the GSO layer that Alex proposed. Then we would not need to
change the way GRO builds the buffers.

> 
> Here at Google, we increased MAX_SKB_FRAGS, but this is a rather
> intrusive change to be upstreamed :(

I've played here with MAX_SKB_FRAGS too, but it seems to
be device specific how many page fragments it can handle.
I wonder if we could increase MAX_SKB_FRAGS at the GRO
layer and let GSO split this buffer in something that
the transmitting device can handle?
