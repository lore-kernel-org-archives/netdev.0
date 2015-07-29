From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] flow_dissector: remove __flow_hash_consistentify
Date: Wed, 29 Jul 2015 15:26:31 -0700
Message-ID: <CALx6S35dQ5AUWi4jf88+m3FgDiy7nHO6UvRfPOGrsmmfkMeFLQ@mail.gmail.com>
References: <1438202943-937619-1-git-send-email-tom@herbertland.com>
	<1438204774.20182.109.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S35ZmVyhX5vv15Ao459pVzWk3tRJuieBQ_dp5ymgQXM9wg@mail.gmail.com>
	<1438208128.20182.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38500 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386AbbG2W0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:26:32 -0400
Received: by iggf3 with SMTP id f3so22096387igg.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 15:26:31 -0700 (PDT)
In-Reply-To: <1438208128.20182.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 3:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-07-29 at 14:47 -0700, Tom Herbert wrote:
>
>> Hi Eric,
>>
>> So the scenario you're thinking is conntrack in the forwarding path,
>> RPS enabled (RSS not relevant), no hash from device, no IPv6 flow
>> labels or any other asymmetric inputs into the flow hash? I can look
>> at that, but it does make me wonder if maybe conntrack should set RFS
>> for both sides to avoid any issue with asymmetric hashes. With more
>> IPv6 and flow labels (which we will enable by default), asymmetric
>> hashes will likely become the norm.
>
> Yes, but as long as the hash was done in software in our stack we could
> use flow dissection and this swap() thing, regardless of the hashes
> computed by the NIC or derived from IPv6 flow label.
>
The IPv6 flow label is now taken as input to the software hash (along
with VLAN id, GRE keyid, MPLS label, etc.). Packets encapsulated in
UDP also cause asymmetric hashes since the source port is used for
entropy. We have no way to predict what a remote host will put into
these fields, so our only recourse would be not include them in the
hash if symmetric hashes are really a requirement.

> RFS wont fly here, as DDOS traffic will need more cache misses.
>
>
