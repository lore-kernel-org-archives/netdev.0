From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH next] netfilter: nfqueue: batch verdict support
Date: Tue, 19 Jul 2011 11:45:24 +0200
Message-ID: <4E255234.3060408@trash.net>
References: <1307657659-30266-1-git-send-email-fw@strlen.de> <1309688655.2523.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, Eric Leblond <eric@regit.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1309688655.2523.16.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.07.2011 12:24, Eric Dumazet wrote:
> The real question hidden here is : "Should packet ids be monotonic" in
> current implementation and all future ones ?
> 
> Before we accept this patch, we should make sure packets id are
> monotonic, and I am afraid its not the case right now.
> 
> I suggest following patch then.
> 
> [PATCH] netfilter: nfqueue: assert monotonic packet ids
> 
> Packet identifier is currently setup in nfqnl_build_packet_message(),
> using one atomic_inc_return().
> 
> Problem is that since several cpus might concurrently call
> nfqnl_enqueue_packet() for the same queue, we can deliver packets to
> consumer in non monotonic way (packet N+1 being delivered after packet
> N)
> 
> This patch moves the packet id setup from nfqnl_build_packet_message()
> to nfqnl_enqueue_packet() to guarantee correct delivery order.
> 
> This also removes one atomic operation.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Florian Westphal <fw@strlen.de>
> CC: Pablo Neira Ayuso <pablo@netfilter.org>
> CC: Eric Leblond <eric@regit.org>

Applied, thanks Eric.
