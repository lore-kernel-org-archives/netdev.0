From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems
 when source address undefined.
Date: Tue, 17 Oct 2006 23:11:02 +0300
Message-ID: <453538D6.1000808@tcs.hut.fi>
References: <4534237B.9090205@tcs.hut.fi> <20061017101402.GM12964@postel.suug.ch> <20061017.200005.70903049.yoshfuji@linux-ipv6.org> <20061017113511.GN12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:9483 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1751253AbWJQULE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 16:11:04 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061017113511.GN12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/06 14:35, Thomas Graf wrote:

Hi Thomas,

> Because otherwise a rule containing only a source prefix match is
> equivalent to a catch-all rule for all lookups not providing a
> source address. An example: Someone adding the rule
> 
> 	ip rule add from 2001::1/128 unreachable
> 
> results in _all_ lookups not providing a source address to
> resolve to unreachable which means that all source address
> lookups will fail.

one quick but ugly hack would be to handle FR_ACT_TO_TBL rules
differently than the others in fib6_rule_match(). I don't necessarily
recommend this approach, but it could work. What do you say?

> The problem starts that both the routing decision and source address
> selection is both a routing decision sharing the same logic which
> are now conflicting as the behaviour for a "from ANY" requires
> different logic. In order to solve this, rules must be restricted to
> one of these paths, i.e. a rule intending to make certain prefixes
> unreachable may not apply to the source selection logic. This can be
> achieved using the 'reason' field I proposed in my netconf slides, it
> would allow turning the first rule example into
> 
> 	rule add from 2001::1/128 for INPUT unreachable
> 
> which would no longer apply when looking up the source address or
> deciding the outgoing route.

Is there any reason we couldn't implement this?

BTW I will not really able to participate in this discussion until
Thursday, but please continue! Hopefully someone has a working solution
that everyone is ok with by then ;-)

I'm currently cooking something up, but I'm not yet sure what will
become of it. It might not work at all. It will also change quite a lot
of things, so there might be less invasive and cleaner solutions. Let's
just say rt6_lookup(), which appears to cause most of these problems,
will not be the same...

Regards,
Ville
