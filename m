From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 23:37:37 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0512142318410.7197@w-sridhar.beaverton.ibm.com>
References: <20051214092228.GC18862@brahms.suse.de>
 <1134582945.8698.17.camel@w-sridhar2.beaverton.ibm.com> <20051215033937.GC11856@waste.org>
 <20051214.203023.129054759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mpm@selenic.com, sri@us.ibm.com, ak@suse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965163AbVLOHhn@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20051214.203023.129054759.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Dec 2005, David S. Miller wrote:

> From: Matt Mackall <mpm@selenic.com>
> Date: Wed, 14 Dec 2005 19:39:37 -0800
>
> > I think we need a global receive pool and per-socket send pools.
>
> Mind telling everyone how you plan to make use of the global receive
> pool when the allocation happens in the device driver and we have no
> idea which socket the packet is destined for?  What should be done for
> non-local packets being routed?  The device drivers allocate packets
> for the entire system, long before we know who the eventually received
> packets are for.  It is fully anonymous memory, and it's easy to
> design cases where the whole pool can be eaten up by non-local
> forwarded packets.
>
> I truly dislike these patches being discussed because they are a
> complete hack, and admittedly don't even solve the problem fully.  I
> don't have any concrete better ideas but that doesn't mean this stuff
> should go into the tree.
>
> I think GFP_ATOMIC memory pools are more powerful than they are given
> credit for.  There is nothing preventing the implementation of dynamic
> GFP_ATOMIC watermarks, and having "critical" socket behavior "kick in"
> in response to hitting those water marks.

Does this mean that you are OK with having a mechanism to mark the
sockets as critical and dropping the non critical packets under
emergency, but you do not like having a separate critical page pool.

Instead, you seem to be suggesting in_emergency to be set dynamically
when we are about to run out of ATOMIC memory. Is this right?

Thanks
Sridhar
