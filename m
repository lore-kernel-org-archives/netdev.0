From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Mon, 12 Dec 2016 10:38:13 +0200
Message-ID: <20161212083812.GA19987@rapoport-lnx>
References: <20161205153132.283fcb0e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        =?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
        "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Kalman Meth <METH@il.ibm.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20161205153132.283fcb0e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hello Jesper,

On Mon, Dec 05, 2016 at 03:31:32PM +0100, Jesper Dangaard Brouer wrote:
> Hi all,
> 
> This is my design for how to safely handle RX zero-copy in the network
> stack, by using page_pool[1] and modifying NIC drivers.  Safely means
> not leaking kernel info in pages mapped to userspace and resilience
> so a malicious userspace app cannot crash the kernel.
> 
> Design target
> =============
> 
> Allow the NIC to function as a normal Linux NIC and be shared in a
> safe manor, between the kernel network stack and an accelerated
> userspace application using RX zero-copy delivery.
> 
> Target is to provide the basis for building RX zero-copy solutions in
> a memory safe manor.  An efficient communication channel for userspace
> delivery is out of scope for this document, but OOM considerations are
> discussed below (`Userspace delivery and OOM`_).

Sorry, if this reply is a bit off-topic.

I'm working on implementation of RX zero-copy for virtio and I've dedicated
some thought about making guest memory available for physical NIC DMAs.
I believe this is quite related to your page_pool proposal, at least from
the NIC driver perspective, so I'd like to share some thoughts here.
The idea is to dedicate one (or more) of the NIC's queues to a VM, e.g.
using macvtap, and then propagate guest RX memory allocations to the NIC
using something like new .ndo_set_rx_buffers method.

What is your view about interface between the page_pool and the NIC
drivers?
Have you considered using "push" model for setting the NIC's RX memory?

> 
> --
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> Above document is taken at GitHub commit 47fa7c844f48fab8b
>  https://github.com/netoptimizer/prototype-kernel/commit/47fa7c844f48fab8b
> 

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
