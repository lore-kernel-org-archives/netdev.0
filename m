From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 4 May 2015 20:59:41 +0200
Message-ID: <20150504185941.GA17061@breakpoint.cc>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
 <20150504155639.GA14367@Alexeis-MBP.westell.com>
 <20150504161956.GK22481@breakpoint.cc>
 <5547AA9C.3030300@mojatatu.com>
 <20150504174358.GN22481@breakpoint.cc>
 <5547BEC4.4090400@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5547BEC4.4090400@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/04/15 13:43, Florian Westphal wrote:
> >Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> >Please don't accuse anyone of being 'evil'.
> >
> 
> It is a figure of speech and was intended to be humorous.
> I consider Pablo a friend, sorry if that came out wrong.

Ugh.  I'm sorry Jamal, seems I lack a sense of humor.
In any case, no offense taken.

> >I think that tc and netfilter are both broken by design in the sense
> >that we have two different systems with partially overlapping
> >functionality while interaction between them consists of hacks.
> >
> >It works both ways, iptables CLASSIFY target is also not very
> >elegant from a design point of view, it bolts the packet/connection matching
> >functionality provided by iptables to qdisc hierarchy.
> >
> 
> Well, from the tc perspective the angle has been one of laziness
> and avoiding to rewrite any features that netfilter has. Essentially
> a gateway-to-iptables. It has not been easy.

Right, I can imagine that.

> It does look silly if we copy things netfilter does in our view.

Sure, that would not be good either (perhaps even worse).

> >>think is that distros which ship with iptables rules and conntracking
> >>on are going to not even turn on tc and my scripts now have to go
> >>unload one.
> >
> >You mean add 'rmmod nft_ingress' or something similar?
> >
> >That might be a problem.  One possible way out would be to
> >make 'tc qdisc add dev eth0 ingress' silently unregister nft ingress
> >on kernel side (but not vice versa).
> >
> >Not nice, but it would keep compatibility with tc ingress scripts.
> >
> 
> Assuming there is something else using the nft side, now they break
> because tc has taken over.

Well, thats true.  But I would not care at this point (in the 'nft
ingress breaks when tc takes over') case.

I'd first like to see what distros would do (by default, that is).

I'd prefer to not base a 'we need to support both at same time' decision
on speculation as to what some distribution might do at some point.

Anything that makes sure that tc ingress doesn't break is fine.
If that turns out to be 'two hooks' then, alas, so be it.

I'd just like some evidence first 8-)
