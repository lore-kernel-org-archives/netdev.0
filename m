From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: nfnetlink_queue: zero copy support
Date: Mon, 18 Mar 2013 10:24:44 +0100
Message-ID: <20130318092444.GG7938@breakpoint.cc>
References: <1363576555.29475.122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363576555.29475.122.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> nfqnl_build_packet_message() actually copy the packet
> inside the netlink message, while it can instead use
> zero copy.
> 
> Make sure the skb 'copy' is the last component of the
> cooked netlink message, as we cant add anything after it.
> 
> Patch cooked in Copenhagen at Netfilter Workshop ;)

This is awesome.
Was there a consensus wrt. mmap'd netlink vs. your patch?

[ I ask because both get rid of one skb data copy ]

> Still to be addressed in separate patches :
>
> -GRO/GSO packets are segmented in nf_queue()
> and checksummed in nfqnl_build_packet_message().
> Proper support for GSO/GRO packets (no segmentation,
> and no checksumming) needs application cooperation, if we
> want no regressions.

Since ipqueue is gone we might be able to push the segmentation
down to nfnetlink_queue.  Then new userspace applications
could indicate a 'I won't verify checksums and will handle huge
packets'.

Are you working on something like this?
