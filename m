From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] ip multicast, kernel 2.4.2*, 2.6.*
Date: Wed, 14 Apr 2004 02:06:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF0F96BFF9.CF0962DF-ON88256E76.0030A322-88256E76.003206F4@us.ibm.com>
References: <20040414041731.GA2010@safenet-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040414041731.GA2010@safenet-inc.com>
To: Lauri Tarkkala <ltarkkala@safenet-inc.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lauri Tarkkala wrote on 04/13/2004 09:17:31 PM:

> The reason for this processing (my guess), is that the inbound
> (duplicate) packet will not be sent, unless the original
> passes the netfilter hooks. This has the side-effect that netfilter
> hooks have no way of detecting whether packets are intended to or are
> going to be looped back. The looped-back packet will of course still go
> through the inbound hooks.

If a packet doesn't pass the outbound hooks, won't your patch still
deliver it locally? Isn't that wrong?

I think the reason it creates a duplicate is because there are two
cases-- one to be sent to the interface and one to be delivered
locally. The one going out the interface should pass the outbound
checks (only) and the one delivered locally should pass (I think)
first the outbound filter and then the inbound filter. Right?

Whether a particular multicast packet should be looped back or not
is not static-- it's determined by the sender (and different senders
may have different IP_MULTICAST_LOOP settings for the same group on
the same machine). So, there is no answer for netfilter that applies
to all multicast packets or even for all for a particular <group,intf>.

Under what circumstances does netfilter need to "detect whether packets
are intended to or are going to be looped back?"

> This is quite error-prone, both in terms of configuring policy for
> netfilter modules, not to mention optimization and implementation. There
> are also some cases that just can not be handled correctly.

What does it break? Can you give an example?

I'm not saying I disagree (or agree) with your patch yet-- haven't looked
at it enough. Just trying to understand what it fixes.

                                                +-DLS
