From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Tue, 21 Sep 2004 17:04:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921210427.GB19575@kvack.org>
References: <1095714704.414f4790cd168@www.katalix.com> <20040920141704.16085067.davem@davemloft.net> <1095760525.414ffa8d111a1@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: James Chapman <jchapman@katalix.com>
Content-Disposition: inline
In-Reply-To: <1095760525.414ffa8d111a1@www.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 10:55:25AM +0100, James Chapman wrote:
> Unfortunately I haven't seen Ben's code yet either so I can't give a
> direct comparison. Ben? I did have a look at the Babylon stuff
> (1.6-pre3), although I've no idea how much of it Ben has
> changed. Here's a summary, fyi.
> 
> Babylon:-
> 
> - Architecture seems to be using char devices for communication with
>   the kernel and all the PPP datapath is handled by custom virtual
>   net_devices; the generic PPP kernel code isn't used as far as I can
>   tell. Unfortunately it is very old (linux-2.0 era I think) but Ben
>   has probably updated it.

I've updated it.  The current build is at http://www.kvack.org/~bcrl/babylon/ 
and is 1.6-pre3-bcrl8.  The L2TP support is approaching beta, with the only 
real todo items being proper retransmit with congestion control, plus the 
kernel side of multihop support, and some locking fixes for smp and preempt.  
Plus the api needs to be made into something more paletable (it abuses 
a mix of ioctl, bind & connect to create l2tp sessions).  No flames please, 
but patches that keep the scaling characteristics and make the interface 
more paletable gladly accepted.

> - Some form of L2TP support is there but it is very basic. Userspace
>   sends data through char devices (read()/write() which the kernel
>   char driver converts to skbs and passes on. Nasty.

That old code was completely tossed.

> - PPP stack supports multiple PPP sessions in one daemon (unlike pppd).
> 
> - Unlikely to integrate with the new native IPSEC stuff.

L2TP over IPSEC?  Are you insane?  You'd not be able to terminate more than 
a couple of dozen connections over it. =-)

> I think for general Linux L2TP support, a socket architecture makes
> more sense. But maybe I'm biased... :)

The current babylon code is using sockets.  The l2tp sockets passes all 
packets for a given tunnel through a single file descriptor.  This seems 
like the best tradeoff for being able to scale to decent numbers of 
sessions.

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler
