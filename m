From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: do not hold qdisc lock while allocating
 memory
Date: Sat, 08 Mar 2014 19:10:32 -0500 (EST)
Message-ID: <20140308.191032.101129109368547659.davem@davemloft.net>
References: <1394175472.20149.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140307.170450.1316250102185751283.davem@davemloft.net>
	<1394233362.20149.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaCIAKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 19:10:33 -0500
In-Reply-To: <1394233362.20149.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Mar 2014 15:02:42 -0800

> On Fri, 2014-03-07 at 17:04 -0500, David Miller wrote:
> 
>> Eric I think you can simplify things a little further, and in fact I
>> think it makes these functions easier to understand.
>> 
>> The fq_resize() part should just grab the lock around the rehash and
>> the update of q->fq_root and q->fq_trees_log.
>> 
>> fq_change() should only grab the lock around the fq_dequeue() loop
>> and the call to qdisc_tree_descrease_qlen().  The rest of this
>> function is just validating netlink attributes and looking at state
>> that cannot change while we hold RTNL.
> 
> Hmm, but all these parameters we change in fq_change() are read by other
> cpus doing enqueue()/dequeue().
> 
> They are integers, so a race would be not a big deal I guess, but better
> add a fat comment then ;)

Good point, this patch as-is is fine, so applied.
