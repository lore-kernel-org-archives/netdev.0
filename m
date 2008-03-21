From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] fib_trie: RCU optimizations
Date: Fri, 21 Mar 2008 15:50:48 -0700 (PDT)
Message-ID: <20080321.155048.14913419.davem@davemloft.net>
References: <20080321075521.49347370@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763082AbYCUWud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:50:33 -0400
In-Reply-To: <20080321075521.49347370@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Mar 2008 07:55:21 -0700

> Small performance improvements.
> 
> Eliminate unneeded barrier on deletion. The first pointer to update
> the head of the list is ordered by the second call to rcu_assign_pointer.
> See hlist_add_after_rcu or comparision.
> 
> Move rcu_derference to the loop check (like hlist_for_each_rcu), and
> add a prefetch.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Please resubmit without the prefetch unless you can prove
that it noticably improves performance.

It'd be nice to split up these two changes logically anyways
even if the prefetch is warranted, so they can be analyzed
independantly.
