From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 19:31:45 -0400
Message-ID: <cdebe688-7a25-8d3c-e6b4-4e34a41e779b@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
 <20160923184030.75124289@halley>
 <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
 <57E7FAC7.6090904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32986 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034211AbcIYXbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 19:31:48 -0400
Received: by mail-it0-f66.google.com with SMTP id x192so4055717itb.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 16:31:48 -0700 (PDT)
In-Reply-To: <57E7FAC7.6090904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 12:26 PM, Daniel Borkmann wrote:
> On 09/25/2016 03:05 PM, Jamal Hadi Salim wrote:

[..]

>> MAX_RED_LOOP (stands for "Maximum Redirect loop") still exists in
>> current code. The idea above was that we would increment the rttl
>> counter  once and if we saw it again upto MAX_RED_LOOP we would assume
>> a loop and drop the packet (at the time i didnt think it was wise to
>> let the actions be in charge of setting the RTTL; it had to be central
>> core code - but it may not be neccessary)
>>
>> Florian, when we discussed I said it was fine to reclaim those 3 bits
>> on tc verdict for RTTL at the time because i had taken out the
>> feature and never added it back. Your comment at the time was we can
>> add it back when someone shows up with the feature.
>> Shmulik is looking to add it.
>
> Why not just reuse xmit_recursion, which is what we did in tc cls_bpf
> programs f.e. see __bpf_tx_skb()? Would be a pity to waste 3 bits on
> this in the skb.

If it is going to work, I'd be happy to save those bits.
xmit_recursion is going to prevent recursing into
dev_xmit(), no?

In our case we want to preventing looping of a singular
skb.

cheers,
jamal
