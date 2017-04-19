From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 11:43:42 -0400
Message-ID: <86c38c78-21b1-74ae-cd7b-8e83eb530cf8@mojatatu.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
 <1492566545.10587.159.camel@edumazet-glaptop3.roam.corp.google.com>
 <b00c5e30-47e9-0e71-7980-b57740ac09be@mojatatu.com>
 <1492571845.10587.161.camel@edumazet-glaptop3.roam.corp.google.com>
 <b318fd94-d4f5-d1b8-c113-a5cf374a6fee@mojatatu.com>
 <1492609668.10587.164.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36864 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965453AbdDSPoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 11:44:54 -0400
Received: by mail-it0-f45.google.com with SMTP id a140so18011322ita.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 08:44:53 -0700 (PDT)
In-Reply-To: <1492609668.10587.164.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 09:47 AM, Eric Dumazet wrote:

> Try to _not_ use 32768 bytes for the recvmsg() sizes, but 4KB
>
> You pack XXX actions until 4KB skb is full.
>
> Then code does :
>
> nla_put_u32(skb, TCAA_ACT_COUNT, cb->args[1])
>
> This might fail, then you
>
> goto out_module_put;
>
>
> Then we are stuck ?
>
> What am I missing ?
>
>

Ok, I understand you now ;->
You are saying we need make sure there is at
least 64 bits reserved so we can stick this TLV in there.
We may have to review a lot of other dumping code in general
to make sure this doesnt happen. Thanks Eric.

cheers,
jamal
