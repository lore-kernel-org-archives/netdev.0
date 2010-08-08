From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: disable preemption before call smp_processor_id()
Date: Sat, 07 Aug 2010 20:37:00 -0700 (PDT)
Message-ID: <20100807.203700.186284252.davem@davemloft.net>
References: <1281173162-10587-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, therbert@google.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541Ab0HHDgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Aug 2010 23:36:41 -0400
In-Reply-To: <1281173162-10587-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat,  7 Aug 2010 17:26:02 +0800

> Although netif_rx() isn't expected to be called in process context with
> preemption enabled, it'd better handle this case. And this is why get_cpu()
> is used in the non-RPS #ifdef branch. If tree RCU is selected,
> rcu_read_lock() won't disable preemption, so preempt_disable() should be
> called explictly.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks Changli.

Paul, perhaps the comment above rcu_read_lock()'s definition should
be updated in rcupdate.h?  It says blocking is not allowed inside
of a read side critical section, but obviously with tree-rcu that
is not the case.

Either we should add a mention of tree-rcu's semantics or just remote
this part of the comment altogether.
