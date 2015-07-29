From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] flow_dissector: remove __flow_hash_consistentify
Date: Wed, 29 Jul 2015 14:47:48 -0700
Message-ID: <CALx6S35ZmVyhX5vv15Ao459pVzWk3tRJuieBQ_dp5ymgQXM9wg@mail.gmail.com>
References: <1438202943-937619-1-git-send-email-tom@herbertland.com>
	<1438204774.20182.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34714 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451AbbG2Vrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:47:48 -0400
Received: by igk11 with SMTP id 11so145743833igk.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 14:47:48 -0700 (PDT)
In-Reply-To: <1438204774.20182.109.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 2:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-07-29 at 13:49 -0700, Tom Herbert wrote:
>> The intent of this function was to produce a consistent hash for both
>> directions of a flow. However, since we added more inputs to the flow
>> hashing (IPv6 flow labels for instance) in a lot of cases we won't get
>> the same hash computed for each direction anyway. Also, there is no
>> defined correlation between the hashes computed in each direction of a
>> flow.
>>
>> This patch removes the function since it is not providing significant
>> value and is expensive to be called for every packet. If there are
>> ever users of the flow_hash_from_keys that did require consistency
>> they can swap addresses and ports as needed in the flow_keys before
>> calling flow_hash_from_keys.
>
> Have you tested this change with conntracking and RPS enabled ?
>
> This was whole point from commit b249dcb82d327e41
>
> I guess difference is even bigger today after removal of central
> conntracking lock.
>
Hi Eric,

So the scenario you're thinking is conntrack in the forwarding path,
RPS enabled (RSS not relevant), no hash from device, no IPv6 flow
labels or any other asymmetric inputs into the flow hash? I can look
at that, but it does make me wonder if maybe conntrack should set RFS
for both sides to avoid any issue with asymmetric hashes. With more
IPv6 and flow labels (which we will enable by default), asymmetric
hashes will likely become the norm.

Thanks,
Tom


>
>
