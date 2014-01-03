From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 -next] netfilter: don't use per-destination
 incrementing ports in nat random mode
Date: Fri, 3 Jan 2014 23:52:36 +0100
Message-ID: <20140103225236.GA18357@localhost>
References: <20131219134007.GA24118@order.stressinduktion.org>
 <52B37F6B.9010105@redhat.com>
 <20131220004822.GC32129@order.stressinduktion.org>
 <20131220080118.GA4234@localhost>
 <20131220214029.GB14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131220214029.GB14073@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 10:40:29PM +0100, Hannes Frederic Sowa wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> 
> We currently use prandom_u32() for allocation of ports in tcp bind(0)
> and udp code. In case of plain SNAT we try to keep the ports as is
> or increment on collision.
> 
> SNAT --random mode does use per-destination incrementing port
> allocation. As a recent paper pointed out in [1] that this mode of
> port allocation makes it possible to an attacker to find the randomly
> allocated ports through a timing side-channel in a socket overloading
> attack conducted through an off-path attacker.
> 
> So, NF_NAT_RANGE_PROTO_RANDOM actually weakens the port randomization
> in regard to the attack described in this paper. As we need to keep
> compatibility, add another flag called NF_NAT_RANGE_PROTO_RANDOM_FULLY
> that would replace the NF_NAT_RANGE_PROTO_RANDOM hash-based port
> selection algorithm with a simple prandom_u32() in order to mitigate
> this attack vector. Note that the lfsr113's internal state is
> periodically reseeded by the kernel through a local secure entropy
> source.
> 
> More details can be found in [1], the basic idea is to send bursts
> of packets to a socket to overflow its receive queue and measure
> the latency to detect a possible retransmit when the port is found.
> Because of increasing ports to given destination and port, further
> allocations can be predicted. This information could then be used by
> an attacker for e.g. for cache-poisoning, NS pinning, and degradation
> of service attacks against DNS servers [1]:
> 
>   The best defense against the poisoning attacks is to properly
>   deploy and validate DNSSEC; DNSSEC provides security not only
>   against off-path attacker but even against MitM attacker. We hope
>   that our results will help motivate administrators to adopt DNSSEC.
>   However, full DNSSEC deployment make take significant time, and
>   until that happens, we recommend short-term, non-cryptographic
>   defenses. We recommend to support full port randomisation,
>   according to practices recommended in [2], and to avoid
>   per-destination sequential port allocation, which we show may be
>   vulnerable to derandomisation attacks.
> 
> Joint work between Hannes Frederic Sowa and Daniel Borkmann.

Applied, thanks.

I have renamed the title of this patch to: "add full port
randomization support" which I though a bit more descriptive with the
final patch that has settled down, just in case you look for it in the
nf-next tree.
