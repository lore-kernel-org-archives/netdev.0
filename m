From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv4: ipv6: better estimate tunnel header cut
 for correct ufo handling
Date: Tue, 25 Feb 2014 18:27:46 -0500 (EST)
Message-ID: <20140225.182746.1170300275583266483.davem@davemloft.net>
References: <20140223210509.GC6598@order.stressinduktion.org>
	<20140223212427.GD6598@order.stressinduktion.org>
	<20140223234805.GE6598@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux@stwm.de, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, therbert@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbaBYX1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 18:27:49 -0500
In-Reply-To: <20140223234805.GE6598@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 24 Feb 2014 00:48:05 +0100

> Currently the UFO fragmentation process does not correctly handle inner
> UDP frames.
 ...
> In this case fragmentation id is incremented and offset is not updated.
> 
> First, I aligned inet_gso_segment and ipv6_gso_segment:
> * align naming of flags
> * ipv6_gso_segment: setting skb->encapsulation is unnecessary, as we
>   always ensure that the state of this flag is left untouched when
>   returning from upper gso segmenation function
> * ipv6_gso_segment: move skb_reset_inner_headers below updating the
>   fragmentation header data, we don't care for updating fragmentation
>   header data
> * remove currently unneeded comment indicating skb->encapsulation might
>   get changed by upper gso_segment callback (gre and udp-tunnel reset
>   encapsulation after segmentation on each fragment)
> 
> If we encounter an IPIP or SIT gso skb we now check for the protocol ==
> IPPROTO_UDP and that we at least have already traversed another ip(6)
> protocol header.
> 
> The reason why we have to special case GSO_IPIP and GSO_SIT is that
> we reset skb->encapsulation to 0 while skb_mac_gso_segment the inner
> protocol of GSO_UDP_TUNNEL or GSO_GRE packets.
> 
> Reported-by: Wolfgang Walter <linux@stwm.de>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
