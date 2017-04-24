From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 10:42:04 -0400
Message-ID: <2d2ffc6d-56e4-3818-36f1-78113f24d580@mojatatu.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
 <a0d70dc5-b0cb-c54e-7d98-93099b68c247@mojatatu.com>
 <20170420142453.GF1886@nanopsycho.orion>
 <20170424091455.GA25218@vergenet.net>
 <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
 <20170424142058.GA26625@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34132 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172832AbdDXOmH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:42:07 -0400
Received: by mail-it0-f65.google.com with SMTP id c26so9769152itd.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 07:42:06 -0700 (PDT)
In-Reply-To: <20170424142058.GA26625@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 10:20 AM, Pablo Neira Ayuso wrote:
> On Mon, Apr 24, 2017 at 08:49:00AM -0400, Jamal Hadi Salim wrote:

>>
>> I am fine with the counter-Postel view of having the kernel
>> validate that appropriate bits are set as long as we dont make
>> user space to now start learning how to play acrobatics.
>
> jamal, what performance concern you have in building this error
> message? TLVs is the most flexible way. And this is error path, so we
> should build this message rarely, only if the user sends us something
> incorrect, why bother...

I have a feeling we are reffering to 2 different things.
Which error message? Are you talking about extended ACK?
I have no problem with that.

Let me sumarize for you the discussion.

My concern was was the double request needed now
which was unneeded before.

Before: You send a msg and say the kernel didnt understand.
Kernel ignores what it didnt understand and does things
you asked it to. i.e Part of Postel principle which says
"Be liberal in what you expect of others"
But the new concern is user space not abiding to the other
half of Postel principle "Be conservative in what you send".
It may set some random flags which the kernel doesnt understand.

One idea is to have the kernel totally reject anytime
it sees such flags. I am sure such a message could be
conveyed back to the user. Then the user sends the
correct one back.

The challenge i have is to enforce this trial by fire
approach to all user space apps. It is a large change.

My suggestion is for user to set flag to request the
old behavior of sending only one message.

cheers,
jamal
