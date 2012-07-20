From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 20 Jul 2012 15:54:12 -0700 (PDT)
Message-ID: <20120720.155412.1512575922394612084.davem@davemloft.net>
References: <1342821959.2626.8052.camel@edumazet-glaptop>
	<1342824166.2626.8112.camel@edumazet-glaptop>
	<20120720.155021.1919200619716435427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117Ab2GTWyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 18:54:13 -0400
In-Reply-To: <20120720.155021.1919200619716435427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 20 Jul 2012 15:50:21 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 21 Jul 2012 00:42:46 +0200
> 
>> (Apparently we choke on neighbour entries count.
>> 
>> entries = atomic_inc_return(&tbl->entries) - 1;
>> 
>> We need a percpu_counter ? Or something is wrong ?
> 
> What do you mean we choke on it?  Does it exceed the thresholds
> and we start garbage-collecting?
> 
> That would indicate a leak, or we are creating new neigh entries when
> we shouldn't be, ie. we're not comparing the keys in the hash table
> entries correctly during the lookup in net/ipv4/ip_output.c

I see the problem, we get the key wrong during neigh creation for
loopback.

I'll fix this, thanks.
