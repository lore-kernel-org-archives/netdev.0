From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 20 Jul 2012 15:50:21 -0700 (PDT)
Message-ID: <20120720.155021.1919200619716435427.davem@davemloft.net>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
	<1342821959.2626.8052.camel@edumazet-glaptop>
	<1342824166.2626.8112.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab2GTWuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 18:50:23 -0400
In-Reply-To: <1342824166.2626.8112.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 21 Jul 2012 00:42:46 +0200

> (Apparently we choke on neighbour entries count.
> 
> entries = atomic_inc_return(&tbl->entries) - 1;
> 
> We need a percpu_counter ? Or something is wrong ?

What do you mean we choke on it?  Does it exceed the thresholds
and we start garbage-collecting?

That would indicate a leak, or we are creating new neigh entries when
we shouldn't be, ie. we're not comparing the keys in the hash table
entries correctly during the lookup in net/ipv4/ip_output.c
