From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/2] ip6_tunnel: Clear IP6CB in ip6tunnel_xmit()
Date: Wed, 02 Nov 2016 15:19:21 -0400 (EDT)
Message-ID: <20161102.151921.396879850539537934.davem@davemloft.net>
References: <20161101154513.30347-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@gmail.com,
        tom@herbertland.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756595AbcKBTTX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:19:23 -0400
In-Reply-To: <20161101154513.30347-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Tue,  1 Nov 2016 23:45:12 +0800

> skb->cb may contain data from previous layers. In the observed scenario,
> the garbage data were misinterpreted as IP6CB(skb)->frag_max_size, so
> that small packets sent through the tunnel are mistakenly fragmented.
> 
> This patch unconditionally clears the control buffer in ip6tunnel_xmit(),
> which affects ip6_tunnel, ip6_udp_tunnel and ip6_gre. Currently none of
> these tunnels set IP6CB(skb)->flags, otherwise it needs to be done earlier.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> ---
> v3: moves to ip6tunnel_xmit() and clears IP6CB unconditionally
> v2: clears the whole IP6CB altogether and does it after encapsulation

Applied and queued up for -stable.
