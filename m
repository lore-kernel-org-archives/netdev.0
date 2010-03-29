From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP path MTU discovery
Date: Mon, 29 Mar 2010 13:25:20 -0700
Message-ID: <4BB10CB0.5090702@hp.com>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org>	<4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Glen Turner <gdt@gdt.id.au>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:13703 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab0C2UZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 16:25:22 -0400
In-Reply-To: <20100329201431.GH20695@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Mon, Mar 29, 2010 at 10:01:42AM -0700, Rick Jones wrote:

>>But which of the last N datagrams sent by the application should be 
>>retained for retransmission?  It could be scores if not hundreds of 
>>datagrams depending on the behaviour of the application and the latency to 
>>the narrow part of the network.
> 
> 
> Yes, if there's a large window you lose. I guess it would make protocols
> like DHCP work at least ("transactional UDP" as the original poster called it)
> 
> I don't know if it would fix enough applications to be worth 
> implementing. The only way to find out would be to try I guess.
> I don't have any better ideas.

I don't think there are any good solutions that do not require either 
application involvement, or a modification to IPv6.

How about allowing an application to request that (copies of) ICMP(v6) messages 
be made available through the socket?  In that way, the application, which 
ostensibly already has to be keeping track of its sends for its own nefarious 
retransmission porpoises can receive the "signal" just like TCP does and perhaps 
there will be enough in the ICMPv6 message for the application to know which 
message(s) need to be retransmitted.

rick jones
