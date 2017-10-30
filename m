From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched qdisc: pass netlink message flags in event notification
Date: Mon, 30 Oct 2017 17:17:09 -0400
Message-ID: <85fua0nxnu.fsf@mojatatu.com>
References: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
        <CAM_iQpWC=JJDBnxPTmkSjqhBGqQakoWbTuBxnLSETHo7+mQvcA@mail.gmail.com>
        <85mv4atyk6.fsf@mojatatu.com>
        <CAM_iQpXm8CevNhWQV-MAP1FmN1aTy4m1tknviMphk-mR=t1=7Q@mail.gmail.com>
        <85o9ooo6g0.fsf@mojatatu.com>
        <CAM_iQpXh0sD9uFYmxkc70Bo_ABxNOh4REU3suJUnpP-rDLmdfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:46152 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753236AbdJ3VRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:17:11 -0400
Received: by mail-io0-f181.google.com with SMTP id 101so30433100ioj.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:17:11 -0700 (PDT)
In-Reply-To: <CAM_iQpXh0sD9uFYmxkc70Bo_ABxNOh4REU3suJUnpP-rDLmdfQ@mail.gmail.com>
        (Cong Wang's message of "Mon, 30 Oct 2017 12:23:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Mon, Oct 30, 2017 at 11:07 AM, Roman Mashak <mrv@mojatatu.com> wrote:
>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>
>>> On Sat, Oct 28, 2017 at 8:36 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>>
>>> Hmm, I thought you use RTM_NEWQDISC+RTM_DELQDISC to
>>> determine it is replacement, no?
>>
>> Create is RTM_NEWQDISC and NLM_F_EXCL|NLM_F_CREATE, replacement is
>> RTM_NEWQDISC and NLM_F_REPLACE in netlink flags.
>
> Is there any reason we can't use RTM_NEWQDISC+RTM_DELQDISC
> rather than NLM_F_REPLACE to determine it is replacement?
>

I'm not sure this would be valid semantics for replace operation, look at
the rfc3549:

Additional flag bits for NEW requests
          NLM_F_REPLACE   Replace existing matching config object with
                          this request.

> Note, RTM_NEWQDISC+RTM_DELQDISC are put in a same
> message not two.

Hmm, could you clarify how do you expect to put two event IDs in nlmsg_type?
