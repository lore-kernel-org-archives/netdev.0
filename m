From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 05 Sep 2008 13:54:29 +0200
Message-ID: <48C11DF5.9040207@netfilter.org>
References: <20080821220432.GT31136@x200.localdomain> <48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain> <48C11918.8020508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C11918.8020508@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> On Thu, Sep 04, 2008 at 06:54:16PM +0200, Patrick McHardy wrote:
>>> adobriyan@gmail.com wrote:
>>>> Make untracked conntrack per-netns. Compare conntracks with relevant
>>>> untracked one.
>>>>
>>>> The following code you'll start laughing at this code:
>>>>
>>>>     if (ct == ct->ct_net->ct.untracked)
>>>>         ...
>>>>
>>>> let me remind you that ->ct_net is set in only one place, and never
>>>> overwritten later.
>>>>
>>>> All of this requires some surgery with headers, otherwise horrible
>>>> circular
>>>> dependencies. And we lost nf_ct_is_untracked() as function, it
>>>> became macro.
>>> I think you could avoid this mess by using a struct nf_conntrack
>>> for the untracked conntrack instead of struct nf_conn. It shouldn't
>>> make any difference since its ignored anyways.
>>
>> Ewww, can I?
> 
> I hope so :) A different possiblity suggest by Pablo some time ago
> would be to mark untracked packets in skb->nfctinfo and not
> attach a conntrack at all.

Indeed, I remember that :). I left that patch of the table time ago [1].
There's a nf_reset call missing as Patrick said at that time. I can
recover it if you like the idea.

[1]
http://lists.netfilter.org/pipermail/netfilter-devel/2005-June/020171.html

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
