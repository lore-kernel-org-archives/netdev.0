From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched qdisc: pass netlink message flags
 in event notification
Date: Mon, 30 Oct 2017 09:23:12 -0700
Message-ID: <CAM_iQpXm8CevNhWQV-MAP1FmN1aTy4m1tknviMphk-mR=t1=7Q@mail.gmail.com>
References: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
 <CAM_iQpWC=JJDBnxPTmkSjqhBGqQakoWbTuBxnLSETHo7+mQvcA@mail.gmail.com> <85mv4atyk6.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:47560 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932126AbdJ3QXd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 12:23:33 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so11413595pfk.4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 09:23:33 -0700 (PDT)
In-Reply-To: <85mv4atyk6.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 28, 2017 at 8:36 PM, Roman Mashak <mrv@mojatatu.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> On Thu, Oct 26, 2017 at 2:40 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>> Userland client should be able to read an event, and reflect it back to
>>> the kernel, therefore it needs to extract complete set of netlink flags.
>>>
>>> For example, this will allow "tc monitor" to distinguish Add and Replace
>>> qdisc operations.
>>>
>>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>> ---
>>>  net/sched/sch_api.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>>> index a9ac912..e3e29be 100644
>>> --- a/net/sched/sch_api.c
>>> +++ b/net/sched/sch_api.c
>>> @@ -859,7 +859,7 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
>>>         }
>>>         if (new && !tc_qdisc_dump_ignore(new, false)) {
>>>                 if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
>>> -                                 old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
>>> +                                 n->nlmsg_flags, RTM_NEWQDISC) < 0)
>>
>>
>> Don't you want to change the other tc_fill_qdisc() in the same function
>> too? ;)
>
> The other tc_fill_qdisc generates RTM_DELQDISC event, in that case
> netlink flags for user don't matter.

Hmm, I thought you use RTM_NEWQDISC+RTM_DELQDISC to
determine it is replacement, no?
