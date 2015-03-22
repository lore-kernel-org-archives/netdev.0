From: David Miller <davem@davemloft.net>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 19:50:03 -0400 (EDT)
Message-ID: <20150322.195003.654000183854114521.davem@davemloft.net>
References: <20150322215612.GA8274@gondor.apana.org.au>
	<20150322.185850.927485035002538859.davem@davemloft.net>
	<20150322230848.GA8989@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	roland@purestorage.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbbCVXuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 19:50:07 -0400
In-Reply-To: <20150322230848.GA8989@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 23 Mar 2015 10:08:48 +1100

> On Sun, Mar 22, 2015 at 06:58:50PM -0400, David Miller wrote:
>>
>> But I do not agree with the idea that it is in any way possible to
>> stop someone with root access on the physical network from crudding up
>> our ARP hash tables.
> 
> But you don't need root access to exploit the neighbour hash
> table.  You just need a sufficiently large (e.g., /16) route
> to a network and anybody on the system can then generate traffic
> to it.
> 
> Granted these days hardly anybody on IPv4 would have such a route
> but if you do then the hash table makes you exposed.
> 
> And for IPv6 everybody is potentially exposed.

BTW I asked for feedback when I posted the patches which created this
situation, and the multiply with the random input was believed to have
sufficient entropy and not create a situation any worse,
asymptotically, than what we had beforehand.

Perhaps the ipv6 case can be improved, by using a u32 random input
for each u32 of the address being hashed.
