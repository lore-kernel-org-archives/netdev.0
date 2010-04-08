From: David Miller <davem@davemloft.net>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Thu, 08 Apr 2010 00:05:57 -0700 (PDT)
Message-ID: <20100408.000557.180546976.davem@davemloft.net>
References: <1270702774.8141.49.camel@edumazet-laptop>
	<1270705153.8141.58.camel@edumazet-laptop>
	<1270710019.2215.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, cl@linux-foundation.org,
	penberg@cs.helsinki.fi, netdev@vger.kernel.org, tj@kernel.org,
	alex.shi@intel.com, linux-kernel@vger.kernel.org,
	ling.ma@intel.com, tim.c.chen@intel.com, akpm@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270710019.2215.4.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Apr 2010 09:00:19 +0200

> If run individually, the tests results are more what we would expect
> (slow), but if machine runs the two set of process concurrently, each
> group runs much faster...

BTW, I just discovered (thanks to the function graph tracer, woo hoo!)
that loopback TCP packets get fully checksum validated on receive.

I'm trying to figure out why skb->ip_summed ends up being
CHECKSUM_NONE in tcp_v4_rcv() even though it gets set to
CHECKSUM_PARTIAL in tcp_sendmsg().

I wonder how much this accounts for some of the hackbench
oddities... and other regressions in loopback tests we've seen.
:-)

Just FYI...
