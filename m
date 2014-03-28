From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] ipv6: move DAD and addrconf_verify processing
 to workqueue
Date: Fri, 28 Mar 2014 16:57:03 -0400 (EDT)
Message-ID: <20140328.165703.1925429348459340241.davem@davemloft.net>
References: <20140326061745.GE22086@order.stressinduktion.org>
	<20140327.131549.909533657131515923.davem@davemloft.net>
	<20140327172807.GB11063@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbaC1U5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:57:05 -0400
In-Reply-To: <20140327172807.GB11063@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 27 Mar 2014 18:28:07 +0100

> addrconf_join_solict and addrconf_join_anycast may cause actions which
> need rtnl locked, especially on first address creation.
> 
> A new DAD state is introduced which deferres processing of the initial
> DAD processing into a workqueue.
> 
> To get rtnl lock we need to push the code paths which depend on those
> calls up to workqueues, specifically addrconf_verify and the DAD
> processing.
> 
> (v2)
> addrconf_dad_failure needs to be queued up to the workqueue, too. This
> patch introduces a new DAD state and stop the DAD processing in the
> workqueue (this is because of the possible ipv6_del_addr processing
> which removes the solicited multicast address from the device).
> 
> addrconf_verify_lock is removed, too. After the transition it is not
> needed any more.
> 
> As we are not processing in bottom half anymore we need to be a bit more
> careful about disabling bottom half out when we lock spin_locks which are also
> used in bh.
> 
> Relevant backtrace:
 ...
> Hunks and backtrace stolen from a patch by Stephen Hemminger.
> 
> Reported-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> v3 (only minor change):
> * reword pr_notice in inet6_ifa_finish_destroy (thanks, David!)

Applied, thanks a lot Hannes.
