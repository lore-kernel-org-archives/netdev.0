From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Mon, 17 Dec 2012 14:28:57 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212171401180.25980@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
 <50CE0921.7060306@mojatatu.com> <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr> <50CE307E.40304@mojatatu.com> <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr> <50CF16FE.5040300@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50CF16FE.5040300@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2012-12-17 13:58, Jamal Hadi Salim wrote:
> On 12-12-16 04:21 PM, Jan Engelhardt wrote:
>
>> If you have a preexisting clone of any linux tree, you can utilize
>> `git remote add ...` to only grab the deltas.
>
>It downloaded eventually. So looking at this quickly, basic
>question: is xtables2 different API wise from what we do today in
>act_ipt?

AFAICS, (one instance of) act_ipt today directly invokes (exactly one
instance of) a target. With act_xt2 as drafted, it instead invokes a
chain, which would

1. leave the construction of the target data and calling it
   to the subsystems they conceptually belong to - the packet filter
2. lets you do matches, jumps and all that.

>Second: Are chain names unique system wide?

Good thing you ask. Chain names are unique within a netns, and this
act_xtables.c draft looks at the packet to get to know its netns, so
that seems fine.

However, your question also leads to looking at whether TC Actions
themselves are sufficiently netns-ified, and it seems this is _not_
the case. Am I right in the observation that variables like
"tcf_ipt_ht" are in fact global rather tha per-netns?

