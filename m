From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched qdisc: pass netlink message flags
 in event notification
Date: Tue, 31 Oct 2017 17:55:00 -0700
Message-ID: <CAM_iQpUvO3XPOsMNV13LZ-ZKzQ1ya9a+ONVv_UpcT1xT8N2JFQ@mail.gmail.com>
References: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
 <CAM_iQpWC=JJDBnxPTmkSjqhBGqQakoWbTuBxnLSETHo7+mQvcA@mail.gmail.com>
 <85mv4atyk6.fsf@mojatatu.com> <CAM_iQpXm8CevNhWQV-MAP1FmN1aTy4m1tknviMphk-mR=t1=7Q@mail.gmail.com>
 <85o9ooo6g0.fsf@mojatatu.com> <CAM_iQpXh0sD9uFYmxkc70Bo_ABxNOh4REU3suJUnpP-rDLmdfQ@mail.gmail.com>
 <85fua0nxnu.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:52135 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753908AbdKAAzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 20:55:21 -0400
Received: by mail-pg0-f47.google.com with SMTP id p9so689293pgc.8
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 17:55:21 -0700 (PDT)
In-Reply-To: <85fua0nxnu.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 2:17 PM, Roman Mashak <mrv@mojatatu.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> On Mon, Oct 30, 2017 at 11:07 AM, Roman Mashak <mrv@mojatatu.com> wrote:
>>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>>
>>>> On Sat, Oct 28, 2017 at 8:36 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>>>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>>>
>>>> Hmm, I thought you use RTM_NEWQDISC+RTM_DELQDISC to
>>>> determine it is replacement, no?
>>>
>>> Create is RTM_NEWQDISC and NLM_F_EXCL|NLM_F_CREATE, replacement is
>>> RTM_NEWQDISC and NLM_F_REPLACE in netlink flags.
>>
>> Is there any reason we can't use RTM_NEWQDISC+RTM_DELQDISC
>> rather than NLM_F_REPLACE to determine it is replacement?
>>
>
> I'm not sure this would be valid semantics for replace operation, look at
> the rfc3549:
>
> Additional flag bits for NEW requests
>           NLM_F_REPLACE   Replace existing matching config object with
>                           this request.
>

I am not saying NLM_F_REPLACE is not correct, I am saying the
RTM_NEWQDISC+RTM_DELQDISC in a same message probably
exists for a reason.


>> Note, RTM_NEWQDISC+RTM_DELQDISC are put in a same
>> message not two.
>
> Hmm, could you clarify how do you expect to put two event IDs in nlmsg_type?

Looking at qdisc_notify(), it is essentially two skb_put() on a same
skb, right? So two nlmsghdr in one skb? Or I read it wrong?
