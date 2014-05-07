From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: clean up snmp stats code
Date: Wed, 07 May 2014 16:06:37 -0400 (EDT)
Message-ID: <20140507.160637.784739838834354060.davem@davemloft.net>
References: <1399330555-4572-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cl@linux.com, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbaEGUGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:06:39 -0400
In-Reply-To: <1399330555-4572-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  5 May 2014 15:55:55 -0700

> commit 8f0ea0fe3a036a47767f9c80e (snmp: reduce percpu needs by 50%)
> reduced snmp array size to 1, so technically it doesn't have to be
> an array any more. What's more, after the following commit:
> 
> 	commit 933393f58fef9963eac61db8093689544e29a600
> 	Date:   Thu Dec 22 11:58:51 2011 -0600
> 
> 	    percpu: Remove irqsafe_cpu_xxx variants
> 	    
> 	    We simply say that regular this_cpu use must be safe regardless of
> 	    preemption and interrupt state.  That has no material change for x86
> 	    and s390 implementations of this_cpu operations.  However, arches that
> 	    do not provide their own implementation for this_cpu operations will
> 	    now get code generated that disables interrupts instead of preemption.
> 
> probably no arch wants to have SNMP_ARRAY_SZ == 2. At least after
> almost 3 years, no one complains.
> 
> So, just convert the array to a single pointer and remove snmp_mib_init()
> and snmp_mib_free() as well.
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This is a very nice cleanup, applied to net-next, thanks.
