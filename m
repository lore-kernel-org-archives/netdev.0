From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable] inet: fix possible memory corruption with
 UDP_CORK and UFO
Date: Mon, 21 Oct 2013 18:25:26 -0400 (EDT)
Message-ID: <20131021.182526.71647778047356987.davem@davemloft.net>
References: <20131021220747.GC24158@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab3JUWZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:25:28 -0400
In-Reply-To: <20131021220747.GC24158@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 22 Oct 2013 00:07:47 +0200

> This is a replacement patch only for stable which does fix the problems
> handled by the following two commits in -net:
> 
> "ip_output: do skb ufo init for peeked non ufo skb as well" (e93b7d748be887cd7639b113ba7d7ef792a7efb9)
> "ip6_output: do skb ufo init for peeked non ufo skb as well" (c547dbf55d5f8cf615ccc0e7265e98db27d3fb8b)
> 
> Three frames are written on a corked udp socket for which the output
> netdevice has UFO enabled.  If the first and third frame are smaller than
> the mtu and the second one is bigger, we enqueue the second frame with
> skb_append_datato_frags without initializing the gso fields. This leads
> to the third frame appended regulary and thus constructing an invalid skb.
> 
> This fixes the problem by always using skb_append_datato_frags as soon
> as the first frag got enqueued to the skb without marking the packet
> as SKB_GSO_UDP.
> 
> The problem with only two frames for ipv6 was fixed by "ipv6: udp
> packets following an UFO enqueued packet need also be handled by UFO"
> (2811ebac2521ceac84f2bdae402455baa6a7fb47).
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Queued up for -stable, thanks Hannes.
