From: jamal <hadi@cyberus.ca>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: 29 Mar 2005 18:00:11 -0500
Message-ID: <1112137210.1088.17.camel@jzny.localdomain>
References: <424346FE.20704@cs.wisc.edu>
	 <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org>
	 <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de>  <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, Andi Kleen <ak@muc.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@redhat.com>
In-Reply-To: <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 17:00, Rik van Riel wrote:

>   However, we often will need
> to get the packets off the network card before we can decide
> whether or not they're high priority.

True - although one could argue that with NAPI that decision would be a
few opcodes away if you install the ingress qdisc. 
So you may end up allocing only to free a few cycles later. Increased
memory traffic but the discard happens sufficiently early for a s/ware
only solution and CPU cycles not burnt as much.

OTOH, even elcheapo pacific rim nics are beginning to show up with some
classifiers in the hardware as well as multiple queues or rx 
DMA rings. So you could program ACKs or all TCP packets to show up on a
higher priority ring and only process that until theres nothing left
before processing the low priority ring (i.e dont care if low priority
data/app is starved).
Probably someone going out of their way to do high performance iSCSI
would consider such hardware. 
We dont exactly support multiple rx (or tx) DMA rings however various
people seem to be promising patches that work with their hardware
(netiron, intel?)

> Also, there can be multiple high priority sockets, and we
> need to ensure they all make progress.  Hence the mempool
> idea.

Sorry missed the early part of this thread: mempool is some
strict priority scheme for mem allocation?

For Sockets: If there was a "control" arbitrator preferably in user
space which would install - after a socket open - both network ingress
and/or egress rules for prioritization then wouldnt that suffice?
The mechanisms are already in place today.

cheers,
jamal
