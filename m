From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon, 2 Jan 2017 20:22:23 -0500
Message-ID: <13dfd148-6a5b-cf62-b2b9-1c13e6d31155@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <586ADAFE.1010105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35713 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756704AbdACBW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 20:22:26 -0500
Received: by mail-it0-f68.google.com with SMTP id b123so49531925itb.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 17:22:26 -0800 (PST)
In-Reply-To: <586ADAFE.1010105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-02 05:58 PM, John Fastabend wrote:
> On 17-01-02 02:21 PM, Jamal Hadi Salim wrote:


> Well having the length value avoids ending up with cookie1, cookie2, ...
> values as folks push more and more data into the cookie.
>

Unless there is good reason I dont see why it shouldnt be a fixed length
value. u64/128 should be plenty.

> I don't see any use in the kernel interpreting it. It has no use
> for it as far as I can see. It doesn't appear to be metadata which
> we use skb->mark for at the moment.
>

Like all cookie semantics it is for storing state. The receiver (kernel)
is not just store it and not intepret it. The user when reading it back
simplifies what they have to do for their processing.

>
> The tuple <ifindex:qdisc:prio:handle> really should be unique why
> not use this for system wide mappings?
>

I think on a single machine should be enough, however:
typically the user wants to define the value in a manner that
in a distributed system it is unique. It would be trickier to
do so with well defined values such as above.


> The only thing I can think to do with this that I can't do with
> the above tuple and a simple userspace lookup is stick hardware specific
> "hints" in the cookie for the firmware to consume. Which would be
> very helpful for what its worth.
>

Ok, very different from our use case with actions.
We just use those values to map to stats info without needing to
know what flow or action (graph) it is associated with.

> Its a bit strange to push it as an action when its not really an
> action in the traditional datapath.
>

The action is part of a graph pointed to by a filter.

> I suspect the OVS usage is a simple 1:1 lookup from OVS id to TC id to
> avoid a userspace map lookup.

Not that i care about OVS but it sounds like a good use case (even for
tc), no?

cheers,
jamal
