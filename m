From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched filters: pass netlink message flags in event notification
Date: Tue, 22 Nov 2016 11:02:51 -0500
Message-ID: <85mvgrbiz8.fsf@mojatatu.com>
References: <1479334570-25159-1-git-send-email-mrv@mojatatu.com>
        <CAM_iQpU_ivg4eBV=88DH6qEcomrq0+G5M=c9rafLszf09PAP_w@mail.gmail.com>
        <CAM_iQpXPsDAfgGsKB7V_=+LnwnuqzgvY7amcPo7hs3VKGrviiA@mail.gmail.com>
        <58340FA2.7040006@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36818 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcKVQDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 11:03:54 -0500
Received: by mail-it0-f65.google.com with SMTP id n68so2280446itn.3
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 08:02:54 -0800 (PST)
In-Reply-To: <58340FA2.7040006@iogearbox.net> (Daniel Borkmann's message of
        "Tue, 22 Nov 2016 10:28:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <daniel@iogearbox.net> writes:

> On 11/22/2016 06:23 AM, Cong Wang wrote:
>> On Thu, Nov 17, 2016 at 1:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Wed, Nov 16, 2016 at 2:16 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>>> Userland client should be able to read an event, and reflect it back to
>>>> the kernel, therefore it needs to extract complete set of netlink flags.
>>>>
>>>> For example, this will allow "tc monitor" to distinguish Add and Replace
>>>> operations.
>>>>
>>>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>>> ---
>>>>   net/sched/cls_api.c | 5 +++--
>>>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>>> index 2b2a797..8e93d4a 100644
>>>> --- a/net/sched/cls_api.c
>>>> +++ b/net/sched/cls_api.c
>>>> @@ -112,7 +112,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
>>>>
>>>>          for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
>>>>               it_chain = &tp->next)
>>>> -               tfilter_notify(net, oskb, n, tp, 0, event, false);
>>>> +               tfilter_notify(net, oskb, n, tp, n->nlmsg_flags, event, false);
>>>
>>>
>>> I must miss something, why does it make sense to pass n->nlmsg_flags
>>> as 'fh' to tfilter_notify()??
>>
>> Ping... Any response?
>>
>> It still doesn't look correct to me. I will send a fix unless someone could
>> explain this.
>
> Sigh, I missed that this was applied already to -net (it certainly doesn't look
> like -net material, but rather -net-next stuff) ... This definitely looks buggy
> to me, the 0 as it was before was correct here (as it means we delete the whole
> chain in this case).
>
> If you could send a patch would be great. Thanks Cong!

Cong/Daniel, sorry for late response, I was distracted.
I apologize, I will send a fix today.

-- 
Roman Mashak
