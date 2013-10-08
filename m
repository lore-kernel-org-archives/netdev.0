From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] net: gro: allow to build full sized skb
Date: Tue, 08 Oct 2013 09:14:47 -0700
Message-ID: <52542F77.2050308@candelatech.com>
References: <1381248143.12191.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52267 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3JHQOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 12:14:50 -0400
In-Reply-To: <1381248143.12191.53.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2013 09:02 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> skb_gro_receive() is currently limited to 16 or 17 MSS per GRO skb,
> typically 24616 bytes, because it fills up to MAX_SKB_FRAGS frags.
>
> It's relatively easy to extend the skb using frag_list to allow
> more frags to be appended into the last sk_buff.
>
> This still builds very efficient skbs, and allows reaching 45 MSS per
> skb.
>
> (45 MSS GRO packet uses one skb plus a frag_list containing 2 additional
> sk_buff)
>
> High speed TCP flows benefit from this extension by lowering TCP stack
> cpu usage (less packets stored in receive queue, less ACK packets
> processed)
>
> Forwarding setups could be hurt, as such skbs will need to be
> linearized, although its not a new problem, as GRO could already
> provide skbs with a frag_list.
>
> We could make the 65536 bytes threshold a tunable to mitigate this.
>
> (First time we need to linearize skb in skb_needs_linearize(), we could
> lower the tunable to ~16*1460 so that following skb_gro_receive() calls
> build smaller skbs)

On multi-homed boxes you could easily have paths that would never need linearize
and other paths that always need it, for whatever reason.

Maybe a per-netdev check for needs linearize instead of something global
would be better...and maybe let users over-ride the default behaviour
regardless?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
