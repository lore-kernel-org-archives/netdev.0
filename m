From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Fri, 27 Aug 2010 10:00:50 -0700
Message-ID: <4C77EF42.6020600@candelatech.com>
References: <4C774B8F.2030805@candelatech.com>	 <20100826.223604.48516081.davem@davemloft.net>	 <4C775411.1000302@candelatech.com>	 <20100826.231110.260096663.davem@davemloft.net>	 <4C77D939.2050807@candelatech.com> <1282924797.5208.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57737 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab0H0RAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 13:00:54 -0400
In-Reply-To: <1282924797.5208.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2010 08:59 AM, Eric Dumazet wrote:
> Le vendredi 27 ao=C3=BBt 2010 =C3=A0 08:26 -0700, Ben Greear a =C3=A9=
crit :
>
>> For the trivial case, I can just kfree_skb when BUSY is returned, fo=
r the
>> same overall behaviour as today.  For something like UDP, I might be=
 able
>> to poke the SKB back into the queue instead of freeing it.
>
> Its not trivial at all. Actually I bet this is not possible.

Ughh, I'll quit bothering with higher level protocols then.

Dave:  Is there any reason to pursue the qdisc BUSY return code
so that it can be used for macvlans, vlans, bonding, etc, or
is that idea just DOA.

There are calls to dev_queue_xmit all over, and many don't
check return codes at all.  I could still fix those up to
free the skb when BUSY is returned.

Or, I could stay with adding a new try_dev_queue_xmit method
so that the few callers that care can deal with error codes
properly.

Based on my slightly improved understanding of how UDP and others
do queue backoff, I don't see how the changes to macvlan that
I posted could cause any additional opportunities for queue
deadlock.

If someone manages to add a qdisc to a macvlan, there could
be issues since there is no way to wake up a macvlan queue,
but that issue exists with or without my patch.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

