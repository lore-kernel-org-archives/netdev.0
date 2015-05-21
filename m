From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: netfilter: ensure number of counters is >0 in do_replace()
Date: Thu, 21 May 2015 13:42:03 +0200
Message-ID: <20150521114203.GA5353@salvia>
References: <20150519231120.GA1761@codemonkey.org.uk>
 <20150519231950.GA30845@breakpoint.cc>
 <20150519234252.GA17307@codemonkey.org.uk>
 <20150519.202043.366626459892331717.davem@davemloft.net>
 <20150520005517.GA7998@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, David Miller <davem@davemloft.net>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150520005517.GA7998@codemonkey.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 08:55:17PM -0400, Dave Jones wrote:
> After improving setsockopt() coverage in trinity, I started triggering
> vmalloc failures pretty reliably from this code path:
> 
> warn_alloc_failed+0xe9/0x140
> __vmalloc_node_range+0x1be/0x270
> vzalloc+0x4b/0x50
> __do_replace+0x52/0x260 [ip_tables]
> do_ipt_set_ctl+0x15d/0x1d0 [ip_tables]
> nf_setsockopt+0x65/0x90
> ip_setsockopt+0x61/0xa0
> raw_setsockopt+0x16/0x60
> sock_common_setsockopt+0x14/0x20
> SyS_setsockopt+0x71/0xd0
> 
> It turns out we don't validate that the num_counters field in the
> struct we pass in from userspace is initialized.
> 
> The same problem also exists in ebtables, arptables, ipv6, and the
> compat variants.

Applied.

This also applies to -stable kernels:

3.2.x
3.4.x
3.10.x
3.12.x
3.14.x
3.18.x
4.0.x

so after some testing and a little while, I'll pass this on.

Thanks.
