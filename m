From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: ip_queue_xmit() used illegally
Date: Fri, 06 May 2011 17:10:31 -0400
Message-ID: <4DC463C7.5030407@hp.com>
References: <20110506.122656.189696988.davem@davemloft.net> <20110506.132129.59693228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yjwei@cn.fujitsu.com, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:38433 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544Ab1EFVVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 17:21:06 -0400
In-Reply-To: <20110506.132129.59693228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2011 04:21 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 06 May 2011 12:26:56 -0700 (PDT)
> 
>> SCTP stores it's binding information using transports and assosciations
>> and does not fill in the ->inet_{daddr,saddr} values.
>>
>> It tries to work around this route issue by checking dst->obsolete
>> directly in sctp_packet_transmit(), which just makes the race smaller
>> and does not eliminate it.  ip_queue_xmit() can still end up with
>> __sk_dst_check() returning NULL and then we end up emitting a
>> potentially bogus packet.
> 
> I take this back, we added this hack where things like SCTP can
> pre-route the packet by hooking up the route to the SKB before
> calling ->queue_xmit.
> 
> And L2TP does something similar.
> 
> So false alarm, nothing to see here :-)
> 
> I still want to clean this up so that this kind of stuff can be
> handled generically inside of ->queue_xmit() by passing in the correct
> addressing information.
> 

Wow, You had me scrambling there for a while.  I was just about to send note
about the pre-hooked route, but you beat me to it.

The reason why sctp doesn't change the inet_addr, is because that address can theoretically
change on ever packet transmit due to multi-homing nature of SCTP.

I'll take a look at ->queue_xmit() to see if SCTP can convert to using that.

-vlad
