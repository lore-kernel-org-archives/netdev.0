From: Roland Dreier <roland@topspin.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Mon, 28 Mar 2005 11:45:19 -0800
Message-ID: <52vf7bwo4w.fsf@topspin.com>
References: <4241D106.8050302@cs.wisc.edu>
	<20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	<1111628393.1548.307.camel@beastie>
	<20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	<1111633846.1548.318.camel@beastie>
	<20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu>
	<20050324233921.GZ14202@opteron.random>
	<20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
	<20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
	<20050326224621.61f6d917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050326224621.61f6d917.davem@davemloft.net> (David S.
 Miller's message of "Sat, 26 Mar 2005 22:46:21 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Let me slightly hijack this thread to throw out another topic that I
think is worth talking about at the kernel summit: handling remote DMA
(RDMA) network technologies.

As some of you might know, I'm one of the main authors of the
InfiniBand support in the kernel, and I think we have things fairly
well in hand there, although handling direct userspace access to RDMA
capabilities may raise some issues worth talking about.

However, there is also RDMA-over-TCP hardware beginning to be used,
based on the specs from the IETF rddp working group and the RDMA
Consortium.  I would hope that we can abstract out the common pieces
for InfiniBand and RDMA NIC (RNIC) support and morph
drivers/infiniband into a more general drivers/rdma.

This is not _that_ offtopic, since RDMA NICs provide another way of
handling OOM for iSCSI.  By having the NIC handle the network
transport through something like iSER, you avoid a lot of the issues
in this thread.  Having to reconnect to a target while OOM is still a
problem, but it seems no worse in principal than the issues with a
dump FC card that needs the host driver to handling fabric login.

I know that in the InfiniBand world, people have been able to run
stress tests of storage over SCSI RDMA Protocol (SRP) with very heavy
swapping going on and no deadlocks.  SRP is in effect network storage
with the transport handled by the IB hardware.

However there are some sticky points that I would be interested in
discussing.  For example, the IETF rddp drafts envisage what they call
a "dual stack" model: TCP connections are set up by the usual network
stack and run for a while in "streaming" mode until the application is
ready to start using RDMA.  At that point there is an "MPA"
negotiation and then the socket is handed over to the RNIC.  Clearly
moving the state from the kernel's stack to the RNIC is not trivial.

Other developers who have more direct experience with RNIC hardware or
perhaps just strong opinions may have other things in this area that
they'd like to talk about.

Thanks,
  Roland
