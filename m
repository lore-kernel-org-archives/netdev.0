From: David Miller <davem@davemloft.net>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Thu, 08 Apr 2010 00:20:11 -0700 (PDT)
Message-ID: <20100408.002011.121977482.davem@davemloft.net>
References: <1270705153.8141.58.camel@edumazet-laptop>
	<1270710019.2215.4.camel@edumazet-laptop>
	<20100408.000557.180546976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, cl@linux-foundation.org,
	penberg@cs.helsinki.fi, netdev@vger.kernel.org, tj@kernel.org,
	alex.shi@intel.com, linux-kernel@vger.kernel.org,
	ling.ma@intel.com, tim.c.chen@intel.com, akpm@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758507Ab0DHHUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 03:20:08 -0400
In-Reply-To: <20100408.000557.180546976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 08 Apr 2010 00:05:57 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 08 Apr 2010 09:00:19 +0200
> 
>> If run individually, the tests results are more what we would expect
>> (slow), but if machine runs the two set of process concurrently, each
>> group runs much faster...
> 
> BTW, I just discovered (thanks to the function graph tracer, woo hoo!)
> that loopback TCP packets get fully checksum validated on receive.
> 
> I'm trying to figure out why skb->ip_summed ends up being
> CHECKSUM_NONE in tcp_v4_rcv() even though it gets set to
> CHECKSUM_PARTIAL in tcp_sendmsg().

Ok, it looks like it's only ACK packets that have this problem,
but still :-)

It's weird that we have a special ip_dev_loopback_xmit() for for
ip_mc_output() NF_HOOK()s, which forces skb->ip_summed to
CHECKSUM_UNNECESSARY, but the actual normal loopback xmit doesn't
do that...
