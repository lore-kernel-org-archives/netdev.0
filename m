From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 03:04:00 +0200
Message-ID: <55417F80.4000506@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia> <20150430003740.GF7025@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39616 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbD3BEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:04:04 -0400
In-Reply-To: <20150430003740.GF7025@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 02:37 AM, Patrick McHardy wrote:
> On 30.04, Pablo Neira Ayuso wrote:
>> On the bugfix front, the illegal mangling of shared skb from actions
>> like stateless nat and bpf look also important to be addressed to me.
>> David already suggested to propagate some state object that keeps a
>> pointer to the skb that is passed to the action. Thus, the action can
>> clone it and get the skb back to the ingress path. I started a
>> patchset to do so here, it's a bit large since it requires quite a lot
>> of function signature adjustment.
>
> Jumping in on this point - the fact that roughly 2/3 of TC actions will
> simply BUG under not unlikely circumstances when used in ingress (I went
> through them one by one with Pablo a week ago) is also telling. Nobody
> seems to be using that. All packet mangling actions will BUG while any
> tap is active. Its nothing easily fixed, but apparently nobody has cared
> in ten years. ipt is trivial to crash differently, connmark is as well.
>
> So I'm wondering what are we actually arguing about here. Whether we are
> affecting the performance how fast TC will crash? We *do* actually care
> about these thing, in TC apparently nobody has for the past ten years.

Totally agree with you that the situation is quite a mess. From tc ingress/
egress side, at least my use case is to have an as minimal as possible entry
point for cls_bpf/act_bpf, which is what we were working on recently. That
is rather ``fresh'' compared to the remaining history of cls/act in tc.

Cheers,
Daniel
