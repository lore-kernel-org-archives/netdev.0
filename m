From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 31 Mar 2005 13:50:12 +0200
Message-ID: <20050331115012.GP24804@muc.de>
References: <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random> <20050330153948.GE12672@muc.de> <20050330154418.GE32111@g5.random> <20050330160255.GG12672@muc.de> <20050330161522.GH32111@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 31 Mar 2005 13:50:12 +0200
To: Andrea Arcangeli <andrea@suse.de>
Content-Disposition: inline
In-Reply-To: <20050330161522.GH32111@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 06:15:22PM +0200, Andrea Arcangeli wrote:
> On Wed, Mar 30, 2005 at 06:02:55PM +0200, Andi Kleen wrote:
> > On Wed, Mar 30, 2005 at 05:44:18PM +0200, Andrea Arcangeli wrote:
> > > On Wed, Mar 30, 2005 at 05:39:48PM +0200, Andi Kleen wrote:
> > > > An unsolveable one IMHO. You can just try to be good enough. For that
> > > 
> > > I think it's solvable with an algorithm I outlined several emails ago.
> > 
> > The problem with you algorithm is that you cannot control
> > how to NIC puts incoming packets into RX rings (and then 
> > actually if the packets you are interested in do actually arrive from
> > the net ,-)
> 
> All I care about is to assign a mempool ID to the skb (ID being unique
> identifier for the tcp connection I don't care how the implementation
> is). If while moving up the stack the skb data doesn't match to the
> sock->mempool id, we'll just free the packet and put it back in the
> mempool.

This could still starve on the RX ring level of the hardware which
you cant control.

But it might be an improvement, agreed. The problem is that you
need lots of infrastructure to tell the driver about TCP connections -
it is pretty much near all the work needed for zero copy RX.

Even with all that work it is  not the 100% solution some people on this thread
seem to be lusting for. 

-Andi
