From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Wed, 8 Sep 2004 08:51:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908065152.GC27886@wotan.suse.de>
References: <20040907120532.GB25051@wotan.suse.de> <1094593729.1079.32.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094593729.1079.32.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2004 at 05:53:04PM -0400, jamal wrote:
> On Tue, 2004-09-07 at 08:05, Andi Kleen wrote:
> > New version of the NETIF_F_LLTX for network devices patch. 
> > 
> > This allows network drivers to set the NETIF_F_LLTX flag
> 
> > The drivers can use try lock if they want and return -1
> > when the lock wasn't grabbed. In this case the packet
> > will be requeued. For better compatibility this is only
> > done for drivers with LLTX set, others don't give a special
> > meaning to -1.
> 
> Are you reinventing the rules or changing them?

I'm just offering the driver an additional choice .
> 
> hard_start_xmit() return codes are intepreted as follows:
> 
> 0: typically means the packet was put in the ring. 
> It is being abused by a few drivers to mean a retry depending on the
> device state (which while may work results in a longer code path). 
> 1: means packet was not put on the ring. i.e if you return
> 1, the toplayer will retry later with the same skb. 
> [of course If you stash it on the ring, the danger is tx complete will
> try to free it later while the toplayer code is still referencing it. A
> good oops].

Actually when you return 1 then the kernel prints an ugly 
message and it is considered a bug.  Here -1 is legal.
For safety -1 should be only used for locking purposes though.

-Andi
