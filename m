From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Tue, 29 Mar 2005 10:29:01 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503291026500.15625@chimarrao.boston.redhat.com>
References: <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
 <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
 <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
 <20050326224621.61f6d917.davem@davemloft.net>
 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
 <m1zmwn21hk.fsf@muc.de> <Pine.LNX.4.61.0503281124090.4269@chimarrao.boston.redhat.com>
 <20050329151159.GC63268@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050329151159.GC63268@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Mar 2005, Andi Kleen wrote:
> On Mon, Mar 28, 2005 at 11:24:55AM -0500, Rik van Riel wrote:
> > On Mon, 28 Mar 2005, Andi Kleen wrote:
> > 
> > > So in short using mempools on receiving is not needed.
> > 
> > It is, because you have to ensure that the memory that's
> > needed to receive network packets isn't tied up receiving
> > packets for non-critical sockets, which would leave the
> > critical sockets deadlocked.
> 
> Again the in socket queue is in no way different from all
> the tens of hundreds of limited size queues that make 
> up a network. It is quite useless to concentrate on only
> one queue in the receiver computer, while all the others
> still can lose packets.

But ... are the packets already received by the network
stack dropped if memory is really low, so we can process
the packets for the memor critical sockets ?

If packets received for non-critical sockets can exhaust
memory, we will deadlock - and that could be the critical
difference between a router (which dumps all packets after
some time) and a Linux host running iSCSI...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
