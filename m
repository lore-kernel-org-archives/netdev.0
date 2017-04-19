From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 22:32:33 -0400
Message-ID: <b00c5e30-47e9-0e71-7980-b57740ac09be@mojatatu.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
 <1492566545.10587.159.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33601 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759013AbdDSCcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 22:32:36 -0400
Received: by mail-it0-f67.google.com with SMTP id z67so1058133itb.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 19:32:36 -0700 (PDT)
In-Reply-To: <1492566545.10587.159.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 09:49 PM, Eric Dumazet wrote:
> On Tue, 2017-04-18 at 21:14 -0400, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> So there is no more limit ? How user is supposed to size the buffer for
> recvmsg() ?
>

That part doesnt change.  Ok, I believe more clarity is needed:->

Current code allows only 32 actions to be dumped at a time.
This code:

So lets i have 128 actions. I can fit them into 10K.
I do recvmsg(..., 32K). This will make about 32K space for me to fill
up the 128 actions. But the code only allows me to send 32
TCA_ACT_MAX_PRIO which takes about 2-3K.
So I will do 4 runs from kernel->user to get 128 actions ;->
User space in tc is trained to expect no more than
TCA_ACT_MAX_PRIO in every batch.

With this change I ask the kernel to fit as many actions as
possible in the 32K (all these 128 will fit in one batch).
Then it has to tell user space how many are in that batch
using TCAA_ACT_COUNT attribute.

Make sense?

cheers,
jamal
