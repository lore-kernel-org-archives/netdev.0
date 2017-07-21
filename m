From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 1/2] net-next: add a dma_desc element to struct
 skb_shared_info
Date: Fri, 21 Jul 2017 22:37:53 +0200
Message-ID: <20170721203753.GA26175@breakpoint.cc>
References: <20170721152035.6645-1-john@phrozen.org>
 <20170721152035.6645-2-john@phrozen.org>
 <1500652599.3924.10.camel@redhat.com>
 <6bcc6463-c2e7-5f56-22b0-f49bb369ce1c@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6bcc6463-c2e7-5f56-22b0-f49bb369ce1c@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Crispin <john@phrozen.org> wrote:
> When the flow offloading engine forwards a packet to the DMA it will send
> additional info to the sw path. this includes
> * physical switch port
> * internal flow hash - this is required to populate the correct flow table
> entry
> * ppe state - this indicates what state the PPEs internal table is in for
> the flow
> * the reason why the packet was forwarde - these are things like bind,
> unbind, timed out, ...
> 
> once the flow table offloading patches are ready and upstream, the netfilter
> layer will see the SKB and pass it o to the flow table offloading code,

If this is about conntrack offloading, then I prefer if this is done
without changing any core network structure.

What about adding a new conntrack extension to hold whatever info
you need, and then allocate a conntrack entry in the driver?

This would obviously need core changes in conntrack (such as allowing
calls into conntrack from drivers without hard module dependencies,
and a thorough check if this causes backwards problems (e.g.
right now a "-m conntrack" check in the raw table can only succeed for
packets from lo interface).

But I think that could be worked around, esp. if we assume that we
won't see such entries a lot (assuming sw is slowpath and hw handles
most packets).

Thanks,
Florian
