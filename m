From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] net: don't use in_atomic() in gfp_any()
Date: Thu, 12 Feb 2009 16:43:30 -0800 (PST)
Message-ID: <20090212.164330.59402005.davem@davemloft.net>
References: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andi@firstfloor.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756939AbZBMAng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:43:36 -0500
In-Reply-To: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 11 Feb 2009 13:27:19 -0800

> The problem is that in_atomic() will return false inside spinlocks if
> CONFIG_PREEMPT=n.  This will lead to deadlockable GFP_KERNEL allocations
> from spinlocked regions.
> 
> Secondly, if CONFIG_PREEMPT=y, this bug solves itself because networking
> will instead use GFP_ATOMIC from this callsite.  Hence we won't get the
> might_sleep() debugging warnings which would have informed us of the buggy
> callsites.
> 
> Solve both these problems by switching to in_interrupt().  Now, if someone
> runs a gfp_any() allocation from inside spinlock we will get the warning
> if CONFIG_PREEMPT=y.
> 
> I reviewed all callsites and most of them were too complex for my little
> brain and none of them documented their interface requirements.  I have no
> idea what this patch will do.
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
