From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mpls: Add missing RCU-bh read side critical section
 locking in output path
Date: Thu, 23 Jun 2016 12:00:55 -0400 (EDT)
Message-ID: <20160623.120055.541092448348137374.davem@davemloft.net>
References: <20160620180527.GU20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbcFWQBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 12:01:03 -0400
In-Reply-To: <20160620180527.GU20238@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 20 Jun 2016 21:05:27 +0300

> From: David Barroso <dbarroso@fastly.com>
> 
> When locally originated IP traffic hits a route that says to push
> MPLS labels, we'll get a call chain dst_output() -> lwtunnel_output()
> -> mpls_output() -> neigh_xmit() -> ___neigh_lookup_noref() where the
> last function in this chain accesses a RCU-bh protected struct
> neigh_table pointer without us ever having declared an RCU-bh read
> side critical section.
> 
> As in case of locally originated IP traffic we'll be running in process
> context, with softirqs enabled, we can be preempted by a softirq at any
> time, and RCU-bh considers the completion of a softirq as signaling
> the end of any pending read-side critical sections, so if we do get a
> softirq here, we can end up with an unexpected RCU grace period and
> all the nastiness that that comes with.
> 
> This patch makes neigh_xmit() take rcu_read_{,un}lock_bh() around the
> code that expects to be treated as an RCU-bh read side critical section.
> 
> Signed-off-by: David Barroso <dbarroso@fastly.com>
> Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>

Whilst the case that was used to discover this problem was MPLS, that
is not the subsystem where the bug exists and is being fixed.

Therefore please fix your Subject line.

Thanks.
