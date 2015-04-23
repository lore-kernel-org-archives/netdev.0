From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 15:33:31 -0700
Message-ID: <CAHA+R7OS_GxDS4BCj8ppM03mnimGAYJYU4qAqOasfxz_NQO-jg@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-3-git-send-email-ast@plumgrid.com>
	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
	<55381F14.4070708@plumgrid.com>
	<553959E3.9070209@mojatatu.com>
	<55396E70.2080908@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35096 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbbDWWdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 18:33:33 -0400
Received: by widdi4 with SMTP id di4so1460967wid.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 15:33:32 -0700 (PDT)
In-Reply-To: <55396E70.2080908@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2015 at 3:13 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 4/23/15 1:45 PM, Jamal Hadi Salim wrote:
>>
>>
>> 1) the _XMIT semantics are useful on the egress side because in fact
>> we do have queues and they can be attached to qdiscs etc.
>> The TC_ACT_XXX codes were _intentional_ since ingress works as a
>> classifier shell.
>
>
> then it is worse mess than I thought :(
> Why call it _qdisc_ then? and have special and convoluted handling for
> it in qdisc_create, qdisc_graft and other places?

It needs to glue into qdisc layer, unify the abstractions.

>
>> Are you planning to queue things on ingress?
>
> I thought that was the whole purpose of ingress qdisc.

There is no queue for ingress qdisc.

> why then we have dev->ingress_queue?

Glue layer, qdisc ties too much with txq, which is what I want to solve.

We have struct netdev_rx_queue too, but look at it, there is nothing
but some sysfs stuffs needed by RPS.

>
> If queueing was never a goal, may be we should kill ingress qdisc
> and replace it with a simple shim that only does cls/act.
> The code overall will get much simpler and faster.
>

As I said in response to your patch for skb->data, we need to align
ingress with egress, rather than making more differences, this includes
qdisc's too. We do have per-cpu queues for ingress, at least in theory
we have a queue for ingress to use.

Of course, RX is naturally different from TX, which is the root cause
why we have so many differences here.
