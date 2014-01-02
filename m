From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: distribute vxlan tunneled traffic
 across multiple TXQs
Date: Thu, 02 Jan 2014 01:36:37 -0500 (EST)
Message-ID: <20140102.013637.1024370036672354197.davem@davemloft.net>
References: <1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131231.135636.1587787263812667419.davem@davemloft.net>
	<1388642206.12212.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, sathya.perla@emulex.com,
	netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaABGgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 01:36:40 -0500
In-Reply-To: <1388642206.12212.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Jan 2014 21:56:46 -0800

> On Tue, 2013-12-31 at 13:56 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 24 Dec 2013 10:39:06 -0800
>> 
>> > On Mon, 2013-12-23 at 11:28 -0800, Stephen Hemminger wrote:
>> > 
>> >> The idea is good, but without the destructor there is nothing to keep
>> >> the UDP socket from being destroyed while packet is being sent on another
>> >> CPU.
>> > 
>> > I see no requirement of holding a reference on the vxlan UDP socket in
>> > transmit path.
>> 
>> I'm trying to figure out how leaving a dangling socket attached to
>> skb->sk, as in this original patch, can be OK.
> 
> Sorry, I lost track here (vacation time...), what patch are you
> referring to ?

http://patchwork.ozlabs.org/patch/304767/

> Once we pass the tunnel, we can either :
> 
> 1) Leave skb->sk set to the original socket sk1 (Say TCP or UDP
> producer)
> 
> 2) Assign skb->sk to the 'socket' used in vxlan (after orphaning and
> releasing reference on socket sk1)
 ...
> If we chose 1), it makes more sense, because each producer will be
> effectively limited by the proper sk->sk_sndbuf limit.
> 
> And a socket cannot be destroyed anyway as long as at least one skb is
> in flight (with skb->sk set to this socket)
> 
> Really, I do not think vxlan should behave in a different way than other
> tunnels (GRE, IPIP, SIT, ...), which chose 1) 

Ok, agreed.
