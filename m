From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Tue, 29 Mar 2005 09:03:32 -0800
Message-ID: <20050329170332.GI15453@waste.org>
References: <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <Pine.LNX.4.61.0503281124090.4269@chimarrao.boston.redhat.com> <20050329151159.GC63268@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        andrea@suse.de, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050329151159.GC63268@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 05:11:59PM +0200, Andi Kleen wrote:
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
> one queue in the receiver computer, while all the others still can lose 
> packets.
> 
> The only way to solve such problems in the TCP/IP model
> is to retransmit at the source. This means the TCP write
> path needs to be reliable, but receiving does not need to be.

You don't seem to understand the deadlock yet. Host is OOM. Host must
flush pages to target to free memory. Host manages to draw skbs from
private reserve to do its writes. Target acknowledges writes, but host
is _still OOM_ and there is no memory including GFP_ATOMIC to allocate
receive buffers. Retransmission doesn't help because the
acknowledgements will always be dropped.

So it seems we need a way to receive such acknowledgements and quickly
discard everything else when we're pushed up against OOM.

-- 
Mathematics is the supreme nostalgia of our time.
