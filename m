From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 18:51:10 -0400
Message-ID: <5539775E.6070704@mojatatu.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com> <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com> <55381F14.4070708@plumgrid.com> <553959E3.9070209@mojatatu.com> <55396E70.2080908@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35616 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbDWWvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 18:51:12 -0400
Received: by qkhg7 with SMTP id g7so20381263qkh.2
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 15:51:11 -0700 (PDT)
In-Reply-To: <55396E70.2080908@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/15 18:13, Alexei Starovoitov wrote:
> On 4/23/15 1:45 PM, Jamal Hadi Salim wrote:

> then it is worse mess than I thought :(
> Why call it _qdisc_ then? and have special and convoluted handling for
> it in qdisc_create, qdisc_graft and other places?

Convinience for tooling and using existing abstractions is the
historical. You can attach qdiscs to netdevs.
You can then use all sorts of well understood tools.

>  > Are you planning to queue things on ingress?
>
> I thought that was the whole purpose of ingress qdisc.
> why then we have dev->ingress_queue?
>

So you are planning to add queues? If you are that is a different
discussion (and the use case needs some clarity).

> If queueing was never a goal, may be we should kill ingress qdisc
> and replace it with a simple shim that only does cls/act.
> The code overall will get much simpler and faster.
>

Attaching to the device was considered "simpler" based on the tooling
thought process. On whether we should queue on ingress - it was not
considered useful if the packets were going to the host i.e we want to
proceed to completion likely queueing to some socket layer further
upstream.
For packets being forwarded we already had egress qdiscs which had
queues so it didnt seem to make sense to enqueue on ingress for such
use cases.
There was a use case later where multiple ingress ports had to be shared
and ifb was born - which is pseudo temporary enqueueing on ingress.


> Feels like falling into rabbit hole.
>
>> The fact that qdiscs dealt with these codes directly
>> allows for specialized handling. Moving them to a generic function
>> seems to defeat that purpose. So I am siding with Cong on this.
>
> that's not what patch 1 is doing. It is still doing specialized
> handling... but in light of what you said above, it looks like much
> bigger cleanup is needed. We'll continue arguing when I refactor
> this set and resubmit when net-next reopens.
>

Sorry - i was refereing to the patch where you agregated things after
the qdisc invokes a classifier.

cheers,
jamal
