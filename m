From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Tue, 5 May 2015 00:21:31 +0200
Message-ID: <20150504222131.GA4348@salvia>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
 <20150504155639.GA14367@Alexeis-MBP.westell.com>
 <20150504161956.GK22481@breakpoint.cc>
 <5547AA9C.3030300@mojatatu.com>
 <20150504174358.GN22481@breakpoint.cc>
 <5547BEC4.4090400@mojatatu.com>
 <20150504185941.GA17061@breakpoint.cc>
 <20150504200506.GA14604@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150504200506.GA14604@Alexeis-MacBook-Pro.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 01:05:08PM -0700, Alexei Starovoitov wrote:
> [...] TC critical path becomes slower with extra dereference and
> indirect jump.

You complained on the performance impact of the initial generic hook
infrastructure that allows qdisc ingress and nft to co-exist, fair
enough.

I came back with an even more simple hook infrastructure, to address
performance concerns, and you indicate that an *extra dereference and
indirect jump* makes this slowier and that both cannot co-exist with
this.

Well, any kind of hook generalization will need at least those minimal
changes. And that allows us to move code that belongs to sch_ingress.
That got embedded into net/core/dev.c because at the time this code
was made when there was no RCU around.

This sounds as an excuse to me.
