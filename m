From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: reuse ip6_frag_id from ip6_ufo_append_data
Date: Wed, 26 Feb 2014 14:42:45 +0100
Message-ID: <20140226134245.GC24855@order.stressinduktion.org>
References: <20140221015535.GB28822@order.stressinduktion.org> <20140222.002855.2055879239461145413.davem@davemloft.net> <20140222055231.GA6598@order.stressinduktion.org> <20140225.140911.2000856357656473477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54075 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaBZNmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 08:42:46 -0500
Content-Disposition: inline
In-Reply-To: <20140225.140911.2000856357656473477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 25, 2014 at 02:09:11PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sat, 22 Feb 2014 06:52:31 +0100
> 
> > Hi David!
> > 
> > On Sat, Feb 22, 2014 at 12:28:55AM -0500, David Miller wrote:
> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> Date: Fri, 21 Feb 2014 02:55:35 +0100
> >> 
> >> > Currently we generate a new fragmentation id on UFO segmentation. It
> >> > is pretty hairy to identify the correct net namespace and dst there.
> >> > Especially tunnels use IFF_XMIT_DST_RELEASE and thus have no skb_dst
> >> > available at all.
> >> > 
> >> > This causes unreliable or very predictable ipv6 fragmentation id
> >> > generation while segmentation.
> >> > 
> >> > Luckily we already have pregenerated the ip6_frag_id in
> >> > ip6_ufo_append_data and can use it here.
> >> > 
> >> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> 
> >> Applied, thanks Hannes.
> > 
> > Could you also get this at least into 3.13, as sit tunnels enable gso
> > by default there?
> 
> Queueud up for -stable, thanks Hannes.

Just FYI:

While doing some more code review on this part (and in the history), it
seemes we can actually call ipv6_select_ident with ipv4 dsts from time
to time thus using just the random memory available there to generate an
ipv6 address. So this fix is appropriate for all kernels from v2.6.32 on.

We can now remove DST_NOPEER in net-next which was just introduced
because of a bug in this logic and simplify ipv6_select_ident in net-next
(patches coming after net merge to net-next).

Thanks,

  Hannes
