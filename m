From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Sat, 26 Mar 2005 22:46:21 -0800
Message-ID: <20050326224621.61f6d917.davem@davemloft.net>
References: <4241D106.8050302@cs.wisc.edu>
	<20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	<1111628393.1548.307.camel@beastie>
	<20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	<1111633846.1548.318.camel@beastie>
	<20050324215922.GT14202@opteron.random>
	<424346FE.20704@cs.wisc.edu>
	<20050324233921.GZ14202@opteron.random>
	<20050325034341.GV32638@waste.org>
	<20050327035149.GD4053@g5.random>
	<20050327054831.GA15453@waste.org>
	<1111905181.4753.15.camel@mylaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, James.Bottomley@HansenPartnership.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
In-Reply-To: <1111905181.4753.15.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 22:33:01 -0800
Dmitry Yusupov <dmitry_yus@yahoo.com> wrote:

> i.e. TCP stack should call NIC driver's callback after all SKB data
> been successfully copied to the user space. At that point NIC driver
> will safely replenish HW ring. This way we could avoid most of memory
> allocations on receive.

How does this solve your problem?  This is just simple SKB recycling,
and it's a pretty old idea.

TCP packets can be held on receive for arbitrary amounts of time.

This is especially true if data is received out of order or when
packets are dropped.  We can't even wake up the user until the
holes in the sequence space are filled.

Even if data is received properly and in order, there are no hard
guarentees about when the user will get back onto the CPU to
get the data copied to it.

During these gaps in time, you will need to keep your HW receive
ring populated with packets.
