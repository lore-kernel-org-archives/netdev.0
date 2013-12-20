From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH next v2] nf-nat: don't use per destination incrementing
 ports in nat random mode
Date: Fri, 20 Dec 2013 09:01:18 +0100
Message-ID: <20131220080118.GA4234@localhost>
References: <20131219134007.GA24118@order.stressinduktion.org>
 <52B37F6B.9010105@redhat.com>
 <20131220004822.GC32129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131220004822.GC32129@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 01:48:22AM +0100, Hannes Frederic Sowa wrote:
> We currently use prandom_u32 for allocation of ports in tcp bind(0)
> and udp code. In case of plain SNAT we try to keep the ports as is or
> increment on collision.
> 
> SNAT --random mode does use per-destination incrementing port
> allocation. As a recent paper pointed out that this mode of port
> allocation makes it possible an attacker to find the randomly
> allocated ports. So NF_NAT_RANGE_PROTO_RANDOM actually weakens the port
> randomization in regard to the attack in this paper.
> 
> You can find details in this paper:
> <https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf>.
> 
> The idea is to send burts of packets to a socket to overflow its receive
> queue and measure the latency to detect a possible retransmit when the
> port is found. Because of increasing ports to given destination and port
> further allocations can be predicted.
> 
> So switch NF_NAT_RANGE_PROTO_RANDOM to prandom_u32, too.

I think that we should be a bit more conservative and add a new option
for this and document this new behaviour, so the user can select what
approach is better according to their needs.

There are protocols that rely on consecutive port allocation to work,
eg. RTP/RCTP, I'm afraid that this full randomization approach will
break them.
