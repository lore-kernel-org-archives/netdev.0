From: Roland Dreier <roland@topspin.com>
Subject: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005
 Kernel Summit Proposed Topics)
Date: Mon, 28 Mar 2005 19:14:39 -0800
Message-ID: <52u0mvta74.fsf_-_@topspin.com>
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
	<52vf7bwo4w.fsf@topspin.com> <1112042936.5088.22.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
In-Reply-To: <1112042936.5088.22.camel@beastie> (Dmitry Yusupov's message of
 "Mon, 28 Mar 2005 12:48:56 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    Dmitry> Basically, HW offloading all kind of is a different
    Dmitry> subject.  Yes, iSER/RDMA/RNIC will help to avoid bunch of
    Dmitry> problems but at the same time will add bunch of new
    Dmitry> problems. OOM/deadlock problem we are discussing is a
    Dmitry> software, *not* hardware related.

Yes, that's why I said I was hijacking the topic to bring up something
else I was interested in :)

    Dmitry> If you have plans to start new project such as SoftRDMA
    Dmitry> than yes. lets discuss it since set of problems will be
    Dmitry> similar to what we've got with software iSCSI Initiators.

No, I don't have plans for such a project, although I would be
interesting in participating in a small way.  Unfortunately I'm
involved in too many other things on to do much real work.

My main interest comes from the InfiniBand world.  Right now we have
the beginnings of good support for IB in drivers/infiniband, but
people are always talking to me about adding support for RDMA/TCP
hardware.  I think we should be able to evolve the curent InfiniBand
API to a more generic RDMA API, and I would hope that a "SoftRDMA"
project can fit in as just another low-level device driver (soft of
the same way software iSCSI sits under the SCSI stack).

In fact I think SoftRDMA would be very good for this generalization
work, as it would force us to come up with very flexible APIs.

    Dmitry> I'm not a believer in any HW state-full protocol
    Dmitry> offloading technologies and that was one of my motivations
    Dmitry> to initiate Open-iSCSI project to prove that performance
    Dmitry> is not an issue anymore. And we succeeded, by showing
    Dmitry> comparable to iSCSI HW Initiator's numbers.

Fair enough.  I think I agree that HW offload is not really justified
if all you care about is storage, although a cheap iSCSI HBA than
handles all the transport and just lets the host queue IOs seems like
a reasonable thing to put in a server that has work to do beyond
running a storage stack.

It seems that many people are using RDMA hardware (mostly InfiniBand
now, maybe RDMA/TCP will catch on) hardware for other reasons.  In
those cases users often want to share the same fabric and NIC for
storage too.  But my main interest right now is in getting RDMA
working well on Linux for the users that are already out there -- I
know many IB clusters with hundreds and even thousands of nodes are
being built all the time, so InfiniBand must be solving some real
problems for users.

 - R.
