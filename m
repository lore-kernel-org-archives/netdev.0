From: jamal <hadi@cyberus.ca>
Subject: Re: Re[2]: [leo@yuriev.ru: [PATCH] ethernet-bridge: update
	skb->priority in case forwarded frame has VLAN-header]
Date: 10 Mar 2005 09:42:27 -0500
Message-ID: <1110465746.1076.29.camel@jzny.localdomain>
References: <20050305141225.GA5180@xi.wantstofly.org>
	 <4229D98F.9010008@trash.net>  <422A0C21.3050709@candelatech.com>
	 <1110199696.1094.1299.camel@jzny.localdomain>
	 <1391080646.20050310162628@yuriev.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	shemminger@osdl.org, netdev@oss.sgi.com
To: "leo.yuriev.ru" <leo@yuriev.ru>
In-Reply-To: <1391080646.20050310162628@yuriev.ru>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-10 at 08:26, Leo Yuriev wrote:
> >>From looking at the patch:
> j> ------
> j> +               /*
> j> +                *   We map VLAN_TCI priority (0..7) to skb->priority (0..15)
> j> +                *   most similarly e.g. 0->0, 1->1, .., 7->7
> j> +                */
> j> +               skb->priority = (vlan_TCI >> 13) & 7;
> j> ------
> 
> j> This is wrong. IEEE priorities are opposite of IETF priorities (as used by
> skb->>prio).
> j> Unless you install a prio qdisc and rewrite the priomap, you are screwed.
> j> So you should do opposite mapping, i.e something along the lines of
> j> VLAN_TCI priority (0..7) to skb->priority (15..8) i,e skb->priority = 15 - vlan_TCI;
> j> cheers,
> j> jamal
> 
> 
> Jamal, you are wrong!

But i am not, Leo ;->

> 802.1p defines priority as "linear" from 0 to 7,
> the 0 is lowest priority and 7 is highest.
> 

Yes of course this is true for IEEE (I never said this wasnt the case).
 
The issue is this: _which_  queue gets processed first?
In strict priority (default for Linux), queue 0 is always high
priority and will always be processed first even if queue 1 has work
(to use other terms queue 1 will be "starved" by queue 0).
So you need to make sure that "highest" priority(7 in your case) always 
goes to queue 0. As was pointed out in the thread discussion - priority
map in Linux actually doesnt quiet map to a true reverse as i had put
it. 
So you need to change your equation to map to the default map in Linux
in which the  result is always to make sure 802.1p priority 7 is
processed first.
If you have any problems figuring it out email me privately and i can
help.

cheers,
jamal

