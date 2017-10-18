From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Wed, 18 Oct 2017 09:43:12 -0700
Message-ID: <CAM_iQpVA2SQ4eFWEQxjQwmoxwQnQiLgREETKdQLoADWt_xD4Bg@mail.gmail.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
 <1508152718-28726-2-git-send-email-chrism@mellanox.com> <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
 <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com> <VI1PR0501MB21437552565B68DC71A7DEE1AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:47944 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750920AbdJRQne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 12:43:34 -0400
Received: by mail-pf0-f177.google.com with SMTP id z11so4363982pfk.4
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 09:43:33 -0700 (PDT)
In-Reply-To: <VI1PR0501MB21437552565B68DC71A7DEE1AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 6:03 PM, Chris Mi <chrism@mellanox.com> wrote:
>> -----Original Message-----
>> From: Cong Wang [mailto:xiyou.wangcong@gmail.com]
>> Sent: Tuesday, October 17, 2017 11:53 PM
>> To: Chris Mi <chrism@mellanox.com>
>> Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>; Jamal Hadi
>> Salim <jhs@mojatatu.com>; Lucas Bates <lucasb@mojatatu.com>; Jiri Pirko
>> <jiri@resnulli.us>; David Miller <davem@davemloft.net>
>> Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and
>> bindcnt to atomic
>>
>> On Mon, Oct 16, 2017 at 6:14 PM, Chris Mi <chrism@mellanox.com> wrote:
>> > I don't think this bug were introduced by above two commits only.
>> > Actually, this bug were introduced by several commits, at least the
>> following:
>> > 1. refcnt and bindcnt are not atomic
>>
>> Nope, it is perfectly okay with non-atomic as long as no parallel, and without
>> RCU callback they are perfectly serialized by RTNL.
> Agree.
>>
>>
>> > 2. passing actions using list instead of arrays (I think initially we
>> > are using arrays)
>>
>> We are discussing patch 1/4, this is patch 2/4, so irrelevant.
> Agree.
>>
>>
>> > 3. using RCU callbacks
>>
>> This introduces problem 1.
> I think this patch set only fixes one problem, that's the race and the panic.
> What do you mean by problem 1.


You listed 3 problems, and you think they are 3 different ones, here
I argue problem 3 (using RCU callbacks) is the cause of problem 1
(refcnt not atomic). This is why I mentioned I have been thinking about
removing RCU callbacks, because it probably could fix all of them.


>>
>>
>> > So instead of blaming the latest commit, it is better to say it is a pre-git error.
>>
>> You are wrong.
> OK, you are right. But could I know what's your suggestion for this patch set?
> 1. reject it?
> 2. change the "Fixes" as you suggested?
> 3. something else?

In my opinion we need to think about removing RCU callbacks
rather than fixing all bugs they introduce, because it is really hard
to prove we can fix all of them. In your patchset, you fix 2 bugs.
Before, we fixed 2 bugs (I already list them in the other reply to you).
In total, we have 4 bugs... Are we totally race-free even after
your patches? It seems not at all without a lock, but as I said locking
itself is hard...

I will start a new thread to discuss this and keep you Cc'ed. So
please hold your patches until we have a conclusion.

Thanks.
