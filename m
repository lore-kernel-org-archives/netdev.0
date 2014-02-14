From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv4: use daddr to get inet_peer
Date: Fri, 14 Feb 2014 10:41:51 +0100
Message-ID: <20140214094151.GA12549@order.stressinduktion.org>
References: <52FDE10F.5010903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54383 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaBNJlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:41:52 -0500
Content-Disposition: inline
In-Reply-To: <52FDE10F.5010903@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 05:25:35PM +0800, Duan Jiong wrote:
> 
> since commit 1d861aa4("inet: Minimize use of cached route inetpeer"),
> ip_error() uses saddr to get inet_peer, so ip_error() and icmpv4_xrlim_allow()
> use the same inet_peer to limit icmp error message twice.
> 
> In ip_error(), peer->rate_tokens is set to ip_rt_error_burst, but in
> inet_peer_xrlim_allow() peer->rate_tokens is set to XRLIM_BURST_FACTOR.
> XRLIM_BURST_FACTOR is defined to 6, so user seting ip_rt_error_burst makes
> no sense.
> 
> In my opinion, the ip_rt_error_burst is used to limit icmp error messages
> for daddr instead of saddr.

Hmmm...

ip_error is a dst_input function, as such it gets called with the incoming
packet. saddr is the address we send the reply back (see
icmp_send->icmp_route_lookup).

Sorry, I don't think the patch is correct.

Bye,

  Hannes
