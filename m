From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 15:29:59 +0100
Message-ID: <20160128142959.GB30994@breakpoint.cc>
References: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.or,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> Thanks Eric for your review and advice.
> 
> I think hackers chould build a malicious h323 packet to overflow
> the pointer p which will panic during the memcpy(addr, p, len)
> 
> For example, he may fabricate a very large taddr->ipAddress.ip;

Can you be more specific?

h323_buffer is backend storage for skb_header_pointer, i.e.
this will error out early when we ask for more data than is available in
packet.

I don't understand how this could overflow anything.
Even assuming 64k packet we'd still have enough room in h323_buffer
for an ipv6 address, no? (we skip the l3/l4 header when extracting
packet payload).

