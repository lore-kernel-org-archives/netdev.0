From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 17:33:17 +0200
Message-ID: <20150430153317.GA3230@salvia>
References: <20150429233205.GA3416@salvia>
 <55417545.30103@iogearbox.net>
 <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
 <20150430004839.GG7025@acer.localdomain>
 <20150430011633.GA12674@Alexeis-MBP.westell.com>
 <20150430013452.GA7956@acer.localdomain>
 <554191F9.3010301@mojatatu.com>
 <20150430031138.GA8950@acer.localdomain>
 <5542182A.800@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5542182A.800@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi jamal,

On Thu, Apr 30, 2015 at 07:55:22AM -0400, Jamal Hadi Salim wrote:
[...]
> Start with a zero rules. Add them logarithmically (with and without
> traffic running). i.e in order of {0, 1, 10, 100, 1000, ...}
> With a single rule you dont notice much difference. Start adding rules
> and it becomes very obvious.

I think the days of linear ruleset performance competitions are over,
we have better data structures to allow users to arrange the ruleset
through the multidimensional dictionaries and the arbitrary state
flows that minimize the number of inspections, which is what it harms
performance when it comes to packet classification.

> ... but now your answer is essentially to subsume tc into netfilter
> ;-> Great.

We're not subsuming anything under netfilter, that hook infrastructure
is generic, and qdisc ingress will not depend on layer 3 hooks. It's
just a bit more code to allow more than one single chain from ingress
and potentially support more features from that entry point in an
optional fashion.

> ... IOW, the logic of "there are bugs
> in there, lets burn down the house" is not how we operate.

We're not burning down any house, after this patchset Qdisc ingress
will still be there. Qdisc ingress can keep going with it, fix the
bugs, improve its performance, there is way a lot room for it from its
own nice, through the flexibility that the generic hook infrastructure
provides.

> Netfilter is a lot more usable - no doubt about it. It has always
> been very good. But there are caveats.
> At one point i think we were thankful all the crackheads were using
> netfilter instead of tc because tc was harder to understand ;->.
> In retrospect i think that was wrong;->
> 
> So let me see if i can summarize your arguement:
> Hardware is faster than 1975 therefore lets just use netfilter
> for usability reasons. [...]

You keep saying that qdisc ingress outperforms, that's only right for
just a very slight difference when comparing it with no rules on
single CPU (when ported to the common playground of the generic hook
infrastructure). On SMP nftables will outperform, even more if the
ruleset is arranged in a non-linear list fashion, with all the new
tricks that we got.

Anyway, let's take this "nftables vs. qdisc ingress" discussion to an
end. I think the main point of this discussion is to provide a generic
entry point to ingress filtering (for both qdisc ingress and nftables)
that, if unused, doesn't harm performance of the critical path
netif_receive_core() path at all. Thus, users can choose what they
want, I have heard you saying several times: "To each their poison"
and I like that.

Thanks.
