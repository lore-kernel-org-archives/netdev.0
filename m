From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 18:18:42 -0400
Message-ID: <ebfe9e52-f130-3733-9348-aac022a18748@mojatatu.com>
References: <20170420142453.GF1886@nanopsycho.orion>
 <20170424091455.GA25218@vergenet.net>
 <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
 <20170424.163033.797679814568299306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, tom@herbertland.com, pablo@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35505 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978561AbdDXWSp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 18:18:45 -0400
Received: by mail-it0-f66.google.com with SMTP id 70so684408ita.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 15:18:44 -0700 (PDT)
In-Reply-To: <20170424.163033.797679814568299306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 04:30 PM, David Miller wrote:

> Which is fine.  But two things:
>
> 1) Again, bits you aren't using now, make sure userspace doesn't
>    set them.  And if it does, reject.
>

I meet those goals on the bit checks but i went a slightly different
path with a patch I posted[1]

With the posted patch: unknow bits set will result in a kernel rejection
unless the user space explicitly ask the kernel to ignore flags it
doesnt understand and just handles what it knows. This reduces the
amount of work in tc.

If this ok I will resend tomorrow.

> 2) If you are worried about performance, we're talking about a TLV in
>    the request here not the dump response itself so performance isn't
>    a real issue as Pablo mentioned.

doesnt make much of a difference for a simple request, true; i was more
worried about how we pack similar things for dumps or for large
set requests in general. And note it makes no difference if i make the
bitmask u32 or u16 - the TLV still eats 32 + 32 bits. So using a u32
is sensible.

cheers,
jamal

[1]
This is because i worry about making large changes to
the behavior of user space apps like tc. If I reject I will need to
change tc to detect this rejection and retry (and I dont think
extended ACKs in their current shape are ready to provide any
meaningful detail).
