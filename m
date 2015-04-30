From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 02:41:30 +0200
Message-ID: <55417A3A.50405@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia> <55417545.30103@iogearbox.net> <20150430003019.GE7025@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38656 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbD3Ali (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 20:41:38 -0400
In-Reply-To: <20150430003019.GE7025@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 02:30 AM, Patrick McHardy wrote:
> On 30.04, Daniel Borkmann wrote:
>>>
>>> I can also see there were also intentions to support userspace
>>> queueing at some point since TC_ACT_QUEUED has been there since the
>>> beginning.  That should be possible at some point using this
>>> infrastructure (once there are no further concerns on the
>>> netif_receive_core_finish() patch as soon as gcc 4.9 and follow up
>>> versions keep inlining this new function).
>>
>> Wrt the other mail, just thinking out loud ... do you see a longer-term
>> possibility of further generalizing the gen hooks infrastructure, so that
>> actually classifier from tc could attach (disregarding the nf_* naming
>> scheme for now) ...
>>
>>      `-> nf_hook_slow()
>>       `-> [for each entry in hook list]   <-- here as an entry
>>        `-> nf_iterate()
>>         `-> (*elemp)->hook()
>>
>> ... as well?
>
> Jumping in there since I'm probably the one thinking the TC ingress
> abstraction is wrong the strongest - yes, it's an interesting idea.
> Unlike egress qdiscs, ingress only has a single classifier chain
> anyways, so there is no qdisc internal classification structure to

Yes, exactly.

> be observed. It should be possible to skip the ingress invocation
> for classification purposes completely and only use it to expose
> it to userspace for management purposes, while invoking the chain
> directly.

That would also meet our goals to only have a single classifier
chain, eventually. ;)
