From: jamal <hadi@cyberus.ca>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
	in case forwarded frame has VLAN-header]
Date: 07 Mar 2005 07:48:16 -0500
Message-ID: <1110199696.1094.1299.camel@jzny.localdomain>
References: <20050305141225.GA5180@xi.wantstofly.org>
	 <4229D98F.9010008@trash.net>  <422A0C21.3050709@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com, leo@yuriev.ru
To: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru
In-Reply-To: <422A0C21.3050709@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-05 at 14:44, Ben Greear wrote:
> Patrick McHardy wrote:
> > Lennert Buytenhek wrote:

>From looking at the patch:
------
+               /*
+                *   We map VLAN_TCI priority (0..7) to skb->priority (0..15) 
+                *   most similarly e.g. 0->0, 1->1, .., 7->7
+                */
+               skb->priority = (vlan_TCI >> 13) & 7;
------

This is wrong. IEEE priorities are opposite of IETF priorities (as used by
skb->prio).
Unless you install a prio qdisc and rewrite the priomap, you are screwed.
So you should do opposite mapping, i.e something along the lines of
VLAN_TCI priority (0..7) to skb->priority (15..8) i,e

skb->priority = 15 - vlan_TCI;

cheers,
jamal
