From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next-2.6] net: optimize INET input path further
Date: Wed, 01 Dec 2010 13:00:21 -0500
Message-ID: <4CF68D35.8020701@hp.com>
References: <1291179847.2856.452.camel@edumazet-laptop>	 <4CF687F3.7030107@hp.com> <1291225358.2856.1035.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:12750 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab0LASAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:00:24 -0500
In-Reply-To: <1291225358.2856.1035.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2010 12:42 PM, Eric Dumazet wrote:
>> Putting IPv4 addresses in sock_common doesn't make it so common anymore :)
>>
>> Is it possible to make this a union so other address families like IPv6
>> can benefit from this as well, or will that blow the whole cache line
>> effect you were trying to achieve?
> 
> This might be OK, depending on cache line size and/or arch.
> 
> On x86_32 for example, that might even be a good thing, because refcnt
> might still be in the first 64bytes of socket.
> 
> By the way, ipv6 sock includes inet, so includes ipv4 addresses too, I
> only moved them in the 'whole structure'

Yes, all that IPv4 address baggage is still there in an IPv6 sock, even
if not used.  I haven't even looked close enough to see if it is possible
to move the IPv6 addresses since I think there are times when both are
in-use.

-Brian
