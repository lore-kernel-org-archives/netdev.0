From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Tue, 18 Dec 2012 08:23:50 -0500
Message-ID: <50D06E66.8000600@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr> <50CE0921.7060306@mojatatu.com> <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr> <50CE307E.40304@mojatatu.com> <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr> <50CF16FE.5040300@mojatatu.com> <alpine.LNX.2.01.1212171401180.25980@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:38003 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708Ab2LRN3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 08:29:43 -0500
Received: by mail-ie0-f177.google.com with SMTP id k13so832886iea.36
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 05:29:42 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1212171401180.25980@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-17 08:28 AM, Jan Engelhardt wrote:
>
> On Monday 2012-12-17 13:58, Jamal Hadi Salim wrote:

> AFAICS, (one instance of) act_ipt today directly invokes (exactly one
> instance of) a target.

Design intent.
You can have the same target instance used by specifying the same index
on the command line.

>With act_xt2 as drafted, it instead invokes a chain, which would
>
> 1. leave the construction of the target data and calling it
>     to the subsystems they conceptually belong to - the packet filter
> 2. lets you do matches, jumps and all that.
>

I like #2. For #1 as long as it doesnt deviate from desire to have one 
or more instances of targets, we should be fine.

> Good thing you ask. Chain names are unique within a netns, and this
> act_xtables.c draft looks at the packet to get to know its netns, so
> that seems fine.

My motivation for that question:
Is it possible to ignore the hook and tablename and just use the chain
name?

> However, your question also leads to looking at whether TC Actions
> themselves are sufficiently netns-ified, and it seems this is _not_
> the case. Am I right in the observation that variables like
> "tcf_ipt_ht" are in fact global rather tha per-netns?

In general we dont need to worry about netns since actions are attached 
to the filters which are dependent on qdiscs which are dependent on 
netdevs which are per netns.
I believe actions (not filters or qdiscs) have a way where this can
be circumvented in one scenario (I can configure them bypassing the 
filter interface). Thanks for bringing this up - I will look at it.

cheers,
jamal
