From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: avoid taking locks at socket dismantle
Date: Wed, 05 Dec 2012 16:21:50 -0500 (EST)
Message-ID: <20121205.162150.1116416856345924607.davem@davemloft.net>
References: <1354735090.31222.21.camel@edumazet-glaptop>
	<OF525F8BC1.196D90F1-ON85257ACB.0073BE61-85257ACB.007403D3@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab2LEVVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:21:53 -0500
In-Reply-To: <OF525F8BC1.196D90F1-ON85257ACB.0073BE61-85257ACB.007403D3@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 5 Dec 2012 16:07:16 -0500

>> From: Eric Dumazet <edumazet@google.com>
>> 
>> ipv6_sock_mc_close() is called for ipv6 sockets at close time, and most
>> of them don't use multicast.
>> 
>> Add a test to avoid contention on a shared spinlock.
>> 
>> Same heuristic applies for ipv6_sock_ac_close(), to avoid contention
>> on a shared rwlock.
> 
>         What prevents a different thread from racing with the
> tests for NULL on these?

The socket is being torn apart, which means that operations on it's
FD are no longer possible, which means that no other thread can add
entries to these lists.
