From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 11:30:08 +0200
Message-ID: <4A24F120.8060706@dev.6wind.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc> <4A240681.2010300@6wind.com> <20090601171340.GB29745@Chamillionaire.breakpoint.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:4817 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbZFBKDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 06:03:30 -0400
In-Reply-To: <20090601171340.GB29745@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal wrote:
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>> Whats wrong with the checks in ip(6)_forward?
>> It's on forward, not on input. Router must not process it.
>> For example, if you try to ping (with ttl set to 0) the router, you will 
>> receive a reply.
> 
> Ah.  That makes more sense.
> However, I'd argue that this is sane behaviour.
> 
> The datagram did reach its intended destination and the TTL did not
> "exceed in transit" (if it had, the datagram would not have been
> received).  Why discard an otherwise perfectly legal packet?
Because RFC requires this:

RFC792 Page 6:
   If the gateway processing a datagram finds the time to live field
   is zero it must discard the datagram.  The gateway may also notify
   the source host via the time exceeded message.

RFC4443 Section 3.3:
    If a router receives a packet with a Hop Limit of zero, or if a
    router decrements a packet's Hop Limit to zero, it MUST discard the
    packet and originate an ICMPv6 Time Exceeded message with Code 0 to
    the source of the packet.

Nicolas

