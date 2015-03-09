From: David Miller <davem@redhat.com>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 09 Mar 2015 13:16:13 -0400 (EDT)
Message-ID: <20150309.131613.2015932954920552655.davem@redhat.com>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
	<20150309130253.GA6677@salvia>
	<20150309131356.GB28039@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150309131356.GB28039@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Mon, 9 Mar 2015 14:13:56 +0100

> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 
> [ CC Andy, see below for ip_fragment api discussion ]
> 
>> > Lets start untangling bridge, bridge netfilter, and the
>> > rest of the ip stack (esp. ip_fragment).
>> > 
>> > This changes ip_fragment() so that bridge netfilter
>> > can pass in the required information as arguments instead
>> > of using skb->nf_bridge to pass some extra information to it.
>> > 
>> > Another problem with br_netfilter and the way its plumbed to
>> > ip/ip6-tables (physdev match) is skb->nf_bridge.
>> > 
>> > nf_bridge is kmalloced blob with some extra information, including
>> > the bridge in and outports (mainly for iptables' physdev match).
>> > It also has various state bits so we know what manipulations
>> > have been performed by bridge netfilter on the skb (e.g.
>> > ppp header stripping).
>> >
>> > nf_bridge also provides scratch space where br_netfilter saves
>> > (and later restores) various things, e.g. ipv4 address for
>> > dnat detection, mac address to fix up ip fragmented skbs, etc.
>> > 
>> > But in almost all cases we can avoid using ->data completely.
>> 
>> I think one of the goals of this patchset is to prepare the removal of
>> that nf_bridge pointer from sk_buff which sounds as a good idea to me.
> 
> The 2nd (and last half) of the set folds nf_bridge_info into skbuff,
> at the end (where its not initialized at allocation time).
> 
> The struct is a lot smaller by then (16 bytes on 64bit, 12 on 32bit)
> so we'd increase skbuff size only by 8.

Sorry, increases in size of any kind of sk_buff are strongly discouraged.

Especially for something like nfbridge.
