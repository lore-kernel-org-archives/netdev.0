From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 19:41:43 -0500 (EST)
Message-ID: <20130122.194143.1205292712415183747.davem@davemloft.net>
References: <1358892924.12374.157.camel@edumazet-glaptop>
	<CAEP_g=_AebncQ6_tHDA0rN=ya4tAqpN2i8FuQ1hqa8mOgj_AJA@mail.gmail.com>
	<1358894653.12374.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab3AWAlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 19:41:47 -0500
In-Reply-To: <1358894653.12374.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jan 2013 14:44:13 -0800

> On Tue, 2013-01-22 at 14:38 -0800, Jesse Gross wrote:
> 
>> 
>> We're currently enforcing this assumption in the rest of the network
>> stack - it's why we mask out scatter/gather capability in the NIC if
>> it isn't capable of checksumming the packet.
>> 
>> Packets with asynchronous changes may come from VMs, so it isn't
>> necessarily reasonable to tell people that they need to disable
>> offloads with certain use cases.
>> 
>> As Pravin said, pushing down the GSO to the lowest layer is the best
>> way to solve the problem.  However, I would argue that the current
>> behavior is not correct.
> 
> You do understand this problem is generic to GSO ?
> 
> You basically are saying GSO should be removed.
> 
> If you really care, please find another way to address the problem.
> 
> Frames build by tcp_sendmsg() are fine : their content cannot be changed
> by the user.

We don't emit crap onto the wire knowingly.  Jesse is right.

If you want to do software GSO in situations where we know that the
paged data cannot be modified asynchronously, you'll have to
explicitly support that.

I will not accept us saying that allowing the emission of bad
checksums is OK.  It never is.  That's terrible behavior, and creates
impossible to disagnose problems.
