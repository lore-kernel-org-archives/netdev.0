From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 02 Mar 2015 15:05:56 -0500 (EST)
Message-ID: <20150302.150556.807426896557970379.davem@davemloft.net>
References: <20150302132925.GB7418@breakpoint.cc>
	<CAHsH6Gu+ZHSdnnritKk5cjTg4NuKppYjffXjNpou2i+uVeykYA@mail.gmail.com>
	<20150302143647.GC7418@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eyal.birger@gmail.com, willemb@google.com, edumazet@google.com,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484AbbCBUF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:05:59 -0500
In-Reply-To: <20150302143647.GC7418@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 2 Mar 2015 15:36:47 +0100

> Eyal Birger <eyal.birger@gmail.com> wrote:
>> On Mon, Mar 2, 2015 at 3:29 PM, Florian Westphal <fw@strlen.de> wrote:
>> > Eyal Birger <eyal.birger@gmail.com> wrote:
>> >> This patch set introduces a new socket option for fetching the mark
>> >> of skbs passed to sockets as ancillary data.
>> >>
>> >> A userspace program may wish to receive the mark of packets it
>> >> receives, for example for distinguishing between different TPROXY
>> >> diversion rules to the same userspace proxy socket.
>> >
>> > Hmm... Whats the use case?
>> > Even if you cannot use multiple sockets for every divert rule,
>> > TPROXY doesn't mangle payload; applications could use sockaddrs
>> > returned by accept, getpeername, getsockname etc.  to figure out
>> > which original port/address the packet was sent to?
>> 
>> Right. But that would mean the criteria for traffic diversion would need to
>> be known to the application receiving the traffic.
> 
> For your solution to work the application needs to know about the TPROXY
> rule set and how that is structured, no?
> 
> I don't see how that is 'better' than e.g. looking at dst port number.
 ...
>> For example, a user space daemon can receive traffic from multiple
>> applications using a single socket and distinguish between different traffic groups
>> according to the packet mark.
> 
> Right, but it might as well use SO_PEERCRED to identify the other pid, right?

Also, this points out that this socket option if accepted probably needs to
be privileged.

I can see administrators not being happy with applications being able to see
the marks used by their rulesets.

I'm backing out this series, Florian makes a lot of good points.
