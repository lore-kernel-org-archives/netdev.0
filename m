From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 00:59:09 -0700 (PDT)
Message-ID: <20080828.005909.215643947.davem@davemloft.net>
References: <20080827.164535.150037784.davem@davemloft.net>
	<48B5F3E2.2000909@cosmosbay.com>
	<20080828074536.GK26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753413AbYH1H7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:59:13 -0400
In-Reply-To: <20080828074536.GK26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 28 Aug 2008 09:45:36 +0200

> > When scanning route cache hash table, we can avoid taking locks for empty 
> > buckets.
> 
> I'm not sure it's worth it in this case.  A rcu_read_lock() is a nop
> (on non preemptible kernel) to very cheap (non atomic increment/decrement in 
> cached task_struct) 

It's not one, it's at least two such increments, plus function calls,
state checks, etc. since this is rcu_read_lock_bh().
