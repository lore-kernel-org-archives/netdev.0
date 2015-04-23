From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 15:13:04 -0700
Message-ID: <55396E70.2080908@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com> <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com> <55381F14.4070708@plumgrid.com> <553959E3.9070209@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36224 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030913AbbDWWNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 18:13:06 -0400
Received: by pdea3 with SMTP id a3so30009009pde.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 15:13:05 -0700 (PDT)
In-Reply-To: <553959E3.9070209@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/15 1:45 PM, Jamal Hadi Salim wrote:
>
> 1) the _XMIT semantics are useful on the egress side because in fact
> we do have queues and they can be attached to qdiscs etc.
> The TC_ACT_XXX codes were _intentional_ since ingress works as a
> classifier shell.

then it is worse mess than I thought :(
Why call it _qdisc_ then? and have special and convoluted handling for
it in qdisc_create, qdisc_graft and other places?

 > Are you planning to queue things on ingress?

I thought that was the whole purpose of ingress qdisc.
why then we have dev->ingress_queue?

If queueing was never a goal, may be we should kill ingress qdisc
and replace it with a simple shim that only does cls/act.
The code overall will get much simpler and faster.

Feels like falling into rabbit hole.

> The fact that qdiscs dealt with these codes directly
> allows for specialized handling. Moving them to a generic function
> seems to defeat that purpose. So I am siding with Cong on this.

that's not what patch 1 is doing. It is still doing specialized
handling... but in light of what you said above, it looks like much
bigger cleanup is needed. We'll continue arguing when I refactor
this set and resubmit when net-next reopens.
