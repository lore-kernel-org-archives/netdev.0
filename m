From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Sat, 24 Jul 2004 01:18:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41019CDA.9050401@trash.net>
References: <40F34740.5040100@trash.net>	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>	<20040712205037.573411c0.davem@redhat.com>	<40F4862D.3070802@trash.net>	<40F4AC8B.40706@trash.net>	<20040721143110.4ab944bf.davem@redhat.com>	<41004F76.1080807@trash.net>	<20040722171752.341d2476.davem@redhat.com>	<41006150.9000702@trash.net>	<41014788.4070301@trash.net> <20040723135459.2ee5c42c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040723135459.2ee5c42c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> We can't use this stuff on Alpha, it's cycle counter overflows after
> just 10 minutes.  It works very strangely, something like only the
> lower 32-bits are guarenteed to be continually incrementing.

The code (although racy) can handle 32-bit cycle counters. get_cycles()
on alpha returns a 32-bit value, so psched_tick calls PSCHED_GET_TIME
to adjust psched_time_base once a second. It is basically the same as
before. This is the second condition for this too work, besides
get_cycles() incrementing at >1MHz, it needs to return either a 32-bit
value and really use the full 32 bit or return something bigger, which
is assumed not to overflow. Alpha seems to satisfy both conditions.

> I'm going to apply your patch and delete the Alpha parts.
> Meanwhile, ping Richard Henderson (rth@redhat.com) or one
> of the other Alpha experts for me to get confirmation on
> this stuff.

Even better.

Regards
Patrick
