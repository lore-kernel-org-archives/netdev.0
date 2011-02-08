From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6][2.6.38-rc2] panic during stress testing
Date: Tue, 08 Feb 2011 13:51:13 -0800 (PST)
Message-ID: <20110208.135113.59683468.davem@davemloft.net>
References: <1297189925.4087.8.camel@jbrandeb-mobl2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.e.pieper@intel.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082Ab1BHVuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 16:50:37 -0500
In-Reply-To: <1297189925.4087.8.camel@jbrandeb-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Tue, 08 Feb 2011 10:32:05 -0800

> We are currently testing patches and ran into this panic, doesn't
> immediately seem related to the driver.
> 
> During TCP/UDP ipv4/6 stress testing on 82574L, 2.6.38-rc2 x86_64
> (net-2.6 with e1000e patches under test) gets numerous OOM killer
> messages, followed by a bug/Oops and panic. could not reproduce the
> bug/panic on 2.6.37, but the OOM killer messages are still seen.
> 
> Could well be related somehow to testing with DEBUG_PAGEALLOC enabled.
> 
> panic dump and .config follows:
> 
> BUG: unable to handle kernel paging request at ffffffff81089738
> IP: [<ffffffff812e2139>] dst_destroy+0x4b/0xf3
> PGD 1695067 PUD 1699063 PMD 10001e1 
> Oops: 0003 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
> CPU 1 
> Modules linked in: nfsd exportfs lockd sunrpc dca e1000e [last unloaded: igb]

So some piece of freed memory is being referenced in dst_destroy(), can you
match dst_destroy+0x4b to a line in that function for your build?

You should always do this when submitting a trace like this.

Thanks.
