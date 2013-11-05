From: Florian Westphal <fw@strlen.de>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Tue, 5 Nov 2013 16:39:21 +0100
Message-ID: <20131105153921.GD15370@breakpoint.cc>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
 <20131105133205.GC15370@breakpoint.cc>
 <20131105134118.GA5818@macbook.localnet>
 <20131105150115.GB2438@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Florian Westphal <fw@strlen.de>,
	netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49501 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750732Ab3KEPjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 10:39:33 -0500
Content-Disposition: inline
In-Reply-To: <20131105150115.GB2438@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Nov 05, 2013 at 02:41:19PM CET, kaber@trash.net wrote:
> >executing the rules on the reassembled packet multiple times, one
> >for each fragment.
> 
[..]
> End even though, the matching is now done for each fragment skb anyway. The
> change is only to do it on different skb. I see no erformance or any
> other problem in that.

One problem that comes to mind is that nfacct or quota match will
now account num_of_fragments * length_of_reassemled_skb bytes.
