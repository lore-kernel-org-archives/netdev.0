From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Thu, 31 Mar 2005 19:09:23 +0200
Message-ID: <20050331170923.GA6546@g5.random>
References: <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random> <20050330153948.GE12672@muc.de> <20050330154418.GE32111@g5.random> <20050330160255.GG12672@muc.de> <20050330161522.GH32111@g5.random> <20050331115012.GP24804@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050331115012.GP24804@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2005 at 01:50:12PM +0200, Andi Kleen wrote:
> This could still starve on the RX ring level of the hardware which
> you cant control.

It may be inefficient in the recovery, but the point is that it can
recover.

> But it might be an improvement, agreed. The problem is that you
> need lots of infrastructure to tell the driver about TCP connections -
> it is pretty much near all the work needed for zero copy RX.

The driver only need to have a ring of mempools attached, OK each one is
attached to the tcp connection, but the driver won't be required to
parse the TCP/IP. After GFP_ATOMIC fails, the driver interurpt handler
will pick a skb from a random mempool.

> Even with all that work it is  not the 100% solution some people on this thread
> seem to be lusting for. 

I thought it was more than enough, all they care about is not to
deadlock anymore, I don't think anybody cares about the performance of
the deadlock-scenario.

I agree with Jamal that his suggestion to use an high-per ring is
very good (I didn't even know some card supported this feature), so if
somebody wants the deadlock scenario not to run in "degraded mode", they
will have to use some more advanced hardware the way Jamal is suggesting
(or get rid of TCP all together and use TCP/IP offload with the security
risks it introduces or RDMA or whatever other point to point high perf
DMA technology like quadrix etc..).

I suspect the deadlock scenario is infrequent enough that it won't
matter how fast it recovers as long as it eventually does.
