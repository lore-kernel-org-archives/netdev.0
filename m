From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Tue, 18 Dec 2012 14:58:56 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212181426590.24597@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
 <50CE0921.7060306@mojatatu.com> <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr> <50CE307E.40304@mojatatu.com> <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr> <50CF16FE.5040300@mojatatu.com> <alpine.LNX.2.01.1212171401180.25980@nerf07.vanv.qr>
 <50D06E66.8000600@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D06E66.8000600@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2012-12-18 14:23, Jamal Hadi Salim wrote:
> On 12-12-17 08:28 AM, Jan Engelhardt wrote:
>>
>> With act_xt2 as drafted, it instead invokes a chain, which would
>>
>> 1. leave the construction of the target data and calling it
>>    to the subsystems they conceptually belong to - the packet filter
>> 2. lets you do matches, jumps and all that.
>
>I like #2. For #1 as long as it doesnt deviate from desire to have
>one or more instances of targets, we should be fine.

Chains can store multiple targets, so no loss.

>> Good thing you ask. Chain names are unique within a netns, and this
>> act_xtables.c draft looks at the packet to get to know its netns, so
>> that seems fine.
>
> My motivation for that question:
> Is it possible to ignore the hook and tablename and just use the chain
> name?

1. table

First, I think some targets need to relax their restrictions, such as
with xt_DSCP.

Then, only a handful of extensions remain: CT, <all NATs>,
TPROXY and REJECT. Would anyone want to call these from act_ipt?
I doubt it. :)

2. hooks

Extensions with hook limit: <NAT>, TPROXY, REJECT, CLASSIFY.
Again, I don't quite see the value of attempting to NAT from act_ipt.
CLASSIFY {c|sh?}ould be relaxed, unless I am missing something.
