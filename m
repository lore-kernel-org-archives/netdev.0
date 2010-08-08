From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: disable preemption before call smp_processor_id()
Date: Sat, 07 Aug 2010 22:25:43 -0700 (PDT)
Message-ID: <20100807.222543.235673802.davem@davemloft.net>
References: <1281173162-10587-1-git-send-email-xiaosuo@gmail.com>
	<20100807.203700.186284252.davem@davemloft.net>
	<20100808045751.GF19600@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732Ab0HHFZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 01:25:24 -0400
In-Reply-To: <20100808045751.GF19600@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Sat, 7 Aug 2010 21:57:51 -0700

> If I cover preemptible RCU's semantics, a first cut comes out like this:
> 
>  * In non-preemptible RCU implementations (TREE_RCU and TINY_RCU), it
>  * is illegal to block while in an RCU read-side critical section.  In
>  * preemptible RCU implementations (TREE_PREEMPT_RCU and TINY_PREEMPT_RCU)
>  * in CONFIG_PREEMPT kernel builds, RCU read-side critical sections may
>  * be preempted, but explicit blocking is illegal.  Finally, in preemptible
>  * RCU implementations in real-time (CONFIG_PREEMPT_RT) kernel builds,
>  * RCU read-side critical sections may be preempted and they may also
>  * block, but only when acquiring spinlocks that are subject to priority
>  * inheritance.
> 
> Does that seem reasonable?

Sounds good to me.
