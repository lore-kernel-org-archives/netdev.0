From: jamal <hadi@cyberus.ca>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
	in case forwarded frame has VLAN-header]
Date: 07 Mar 2005 19:19:50 -0500
Message-ID: <1110241190.1043.100.camel@jzny.localdomain>
References: <20050305141225.GA5180@xi.wantstofly.org>
	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>
	 <1110199696.1094.1299.camel@jzny.localdomain>
	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>
	 <1110238537.1043.62.camel@jzny.localdomain>  <422CE983.7060305@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <422CE983.7060305@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 18:53, Patrick McHardy wrote:
> jamal wrote:
> >>
> >>The priority should still start at 0. You don't want to create a 16-band
> >>queue just to have 8 bands unused.
> > 
> > 
> > say what?;-> Nothing has to start at 0. 16 priorities does not equate to
> > 16 queues. 
> 
> Right. But the default pfifo_fast/prio mapping maps the upper 8 values
> to queue 1, which seems to make this effort kind of useless. 
> I don't know if the default-mapping of the lower 8 values is useable 
> in this context, 

Indeed that looks bad. But wouldnt have helped if we started at 0
either. You need monotonically increasing values to make proper
sense. So i suppose to do proper qos with L2, one must install the prio
qdisc and rewrite the priomap.

The mapping used in pfifo_fast is derived from RFC1349 4 bit TOS which
is really considered toast these days. We need to revamp things - but
this would require some surgery in the route code as well (so maybe safe
to leave as is).

> I need to inform myself more on this subject (thanks for the
> IEEE vs. IETF pointers).
> 

Has bitten me a few times when trying to do Qos between switches and
routers.

cheers,
jamal
