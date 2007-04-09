From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] [NET] Do pmtu check in transport layer
Date: Mon, 09 Apr 2007 18:40:31 +0200
Message-ID: <461A6C7F.1030506@trash.net>
References: <11746948063923-git-send-email-jheffner@psc.edu> <4619FBEE.70103@trash.net> <461A6896.1050308@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39968 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609AbXDIQkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:40:37 -0400
In-Reply-To: <461A6896.1050308@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> Patrick McHardy wrote:
> 
>> This makes ping report an incorrect MTU when IPsec is used since we're
>> only accounting for the additional header_len, not the trailer_len
>> (which is not easily changeable). Additionally it will report different
>> MTUs for the first and following fragments when the socket is corked
>> because only the first fragment includes the header_len. It also can't
>> deal with things like NAT and routing by fwmark that change the route.
>> The old behaviour was that we get an ICMP frag. required with the MTU
>> of the final route, while this will always report the MTU of the
>> initially chosen route.
>>
>> For all these reasons I think it should be reverted to the old
>> behaviour.
> 
> 
> You're right, this is no good.  I think the other problems are fixable,
> but NAT really screws this.


Routing by fwmark is also unfixable and IPsec is quite hard.

> Unfortunately, there is still a real problem with ipv6, in that the
> output side does not generate a packet too big ICMP like ipv4.  Also, it
> feels kind of undesirable be rely on local ICMP instead of direct error
> message delivery.  I'll try to generate a new patch.


I think its necessary since at the transport layer we simply don't
have all the information about whats going to happen to a packet.
IPv6 now also supports routing by fwmark, so it has the same problem
if it doesn't generate packet too big messages.

