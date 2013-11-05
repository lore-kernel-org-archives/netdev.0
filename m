From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Tue, 5 Nov 2013 18:19:24 +0000
Message-ID: <20131105181923.GB7435@macbook.localnet>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
 <20131105133205.GC15370@breakpoint.cc>
 <20131105134118.GA5818@macbook.localnet>
 <20131105150115.GB2438@minipsycho.orion>
 <20131105153921.GD15370@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
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
In-Reply-To: <20131105153921.GD15370@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 05, 2013 at 04:39:21PM +0100, Florian Westphal wrote:
> Jiri Pirko <jiri@resnulli.us> wrote:
> > Tue, Nov 05, 2013 at 02:41:19PM CET, kaber@trash.net wrote:
> > >executing the rules on the reassembled packet multiple times, one
> > >for each fragment.
> > 
> [..]
> > End even though, the matching is now done for each fragment skb anyway. The
> > change is only to do it on different skb. I see no erformance or any
> > other problem in that.
> 
> One problem that comes to mind is that nfacct or quota match will
> now account num_of_fragments * length_of_reassemled_skb bytes.

indeed. The easiest way to fix all this (and, btw, also the
pskb_expand_head() oops which is currently reported by multiple people)
is to get rid of all the fragmentation handling and simply use the
reassembled skb.
