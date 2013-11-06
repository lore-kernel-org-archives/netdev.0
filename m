From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Wed, 6 Nov 2013 15:44:53 +0100
Message-ID: <20131106144453.GD2458@minipsycho.orion>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
 <20131105133205.GC15370@breakpoint.cc>
 <20131105134118.GA5818@macbook.localnet>
 <20131105150115.GB2438@minipsycho.orion>
 <20131105181633.GA7435@macbook.localnet>
 <20131106141845.GC2458@minipsycho.orion>
 <20131106143349.GF15370@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131106143349.GF15370@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Nov 06, 2013 at 03:33:49PM CET, fw@strlen.de wrote:
>Jiri Pirko <jiri@resnulli.us> wrote:
>> >> >So if someone wants to change this, simply *only* pass the reassembled
>> >> >packet through the netfilter hooks and drop the fragments, as in IPv4.
>> >> 
>> >> This is unfortunatelly not possible because in forwarding use case, the
>> >> fragments have to be send out as they come in.
>> >
>> >No, the IPv6 NAT patches fixed that, we still do proper refragmentation
>> >and we still respect the original fragment sizes, thus are not responsible
>> >for potentially exceeding the PMTU on the following path.
>> 
>> Can you please point where this is done. Where the original fragment
>> sizes are stored and in which code are they restored? Thanks.
>
>Patrick is probably talking about
>
>commit 4cdd34084d539c758d00c5dc7bf95db2e4f2bc70
>(netfilter: nf_conntrack_ipv6: improve fragmentation handling)
>which introduces 'frag_max_size' in inet6_skb_parm struct.

Thanks for the pointer. Interestingly though, according to my testing,
if reassembled packet would fit into outdev mtu, it is not fragmented
to the original frag size and it is send as single big packet. That is
I believe not correct.

