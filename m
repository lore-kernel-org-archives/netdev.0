From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 16:45:31 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi>
References: <200403311201.i2VC13D19579@zero.aec.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <200403311201.i2VC13D19579@zero.aec.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Andi,

On Wed, 31 Mar 2004, Andi Kleen wrote:

> Most of the patch is quite straight forward, except for the change in the
> v4/v6 proxy arp code. I assume it was checking the time stamp to distingush
> locally originated packets from external packets (?). I changed it
> to use skb->sk instead. I'm not 100% sure if I guessed the intention
> correctly and don't know why it should check that anyways.
> Someone should review that change.

I suspect this breaks proxy arp/ndisc!

The arp/ndisc requests are queued up for a random time before being
processed by the proxy. Check out pneigh_enqueue() in net/core/neighbour.c
for details. The skb->stamp.tv_sec check was used to separate the locally
re-fed requests from ones received from the net.

AFAICS, skb->sk isn't set for the enqueued packets, so checking the field
doesn't make sense. One thing that instead *might* work, would be to set
skb->pkt_type = PACKET_HOST in pneigh_enqueue().

Of course skb->pkt_type = PACKET_HOST is set in other places as well, so
some falsely marked packets might bypass the required random delay. I
don't think this is a big concern, but I thought it was best to bring it
up...

> -Andi

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
