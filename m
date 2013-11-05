From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Tue, 5 Nov 2013 22:02:23 +0000
Message-ID: <20131105220222.GA9115@macbook.localnet>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
 <20131105133205.GC15370@breakpoint.cc>
 <20131105134118.GA5818@macbook.localnet>
 <20131105150115.GB2438@minipsycho.orion>
 <20131105181633.GA7435@macbook.localnet>
 <20131105205520.GD2438@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51320 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab3KEWC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 17:02:29 -0500
Content-Disposition: inline
In-Reply-To: <20131105205520.GD2438@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 09:55:20PM +0100, Jiri Pirko wrote:
> Tue, Nov 05, 2013 at 07:16:33PM CET, kaber@trash.net wrote:
>
> >> I'm a bit lost. What "nfct_frag" are you reffering to here?
> >
> >I meant nfct_reasm of course.
> 
> The patch is not moving this to struct sk_buff. It is already there.

Right again, sorry, I was replying to Florian's mail without the
quoted patch, so I seem to have mixed up things in between :)

> >> >So if someone wants to change this, simply *only* pass the reassembled
> >> >packet through the netfilter hooks and drop the fragments, as in IPv4.
> >> 
> >> This is unfortunatelly not possible because in forwarding use case, the
> >> fragments have to be send out as they come in.
> >
> >No, the IPv6 NAT patches fixed that, we still do proper refragmentation
> >and we still respect the original fragment sizes, thus are not responsible
> >for potentially exceeding the PMTU on the following path.
> 
> Ok. So the plan is to remove net/ipv6/netfilter/nf_conntrack_reasm.c
> code entirely and use net/ipv6/reassembly.c code directly from
> nf_defrag_ipv6. This would result in very similar code currently ipv4
> has. 

If its possible to use net/ipv6/reassembly.c directly, even better,
so far I was thinking of just getting rid of the fragment replay,
but you're most likely right that this is the proper way to do it.
